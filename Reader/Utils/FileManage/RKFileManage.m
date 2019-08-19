//
//  RKFileManager.m
//  Reader
//
//  Created by RZK on 2019/4/20.
//  Copyright © 2019 RZK. All rights reserved.
//

#import "RKFileManager.h"
#include <sys/param.h>
#include <sys/mount.h>

@interface RKFileManager ()



@end

@implementation RKFileManager

static RKFileManager *_fileManager;

#pragma mark - 单例
+ (instancetype)shareInstance {
    
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        _fileManager = [[RKFileManager alloc] init];
    });
    
    return _fileManager;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        NSFileManager *fileManager = [NSFileManager defaultManager];
        BOOL isDir;
        RKLog(@"书籍列表\n%@",kHomeBookListsPath);
        
        // 先判断目录是否存在，不存在才创建
        if  (![fileManager fileExistsAtPath:kBookSavePath isDirectory:&isDir]) {
            BOOL res = [fileManager createDirectoryAtPath:kBookSavePath withIntermediateDirectories:YES attributes:nil error:nil];
            
            if (res) {
                RKLog(@"文件已创建\nkBookSavePath:%@",kBookSavePath);
            }
        } else {
            RKLog(@"文件已存在\nkBookSavePath:%@",kBookSavePath);
        }
        
        if (![fileManager fileExistsAtPath:kBookAnalysisPath isDirectory:&isDir]) {
            BOOL res = [fileManager createDirectoryAtPath:kBookAnalysisPath withIntermediateDirectories:YES attributes:nil error:nil];
            if (res) {
                RKLog(@"文件已创建\nkBookAnalysisPath:%@",kBookAnalysisPath);
            }
        } else {
            RKLog(@"文件已存在\nkBookAnalysisPath:%@",kBookAnalysisPath);
        }
    }
    return self;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _fileManager = [super allocWithZone:zone];
    });
    
    return _fileManager;
}

- (id)copyWithZone:(NSZone *)zone {
    return _fileManager;
}

#pragma mark - func
#pragma mark - 增
/// 添加书籍
- (void)saveBookWithPath:(NSString *)path {
    
    RKBook *book = [RKBook new];
    book.name = path;
    book.coverImage = [NSString stringWithFormat:@"cover%d",arc4random()%10+1];
    book.path = path;
    book.size = [self getFileSize:[kBookSavePath stringByAppendingString:[NSString stringWithFormat:@"/%@",path]]];
    book.addDate = [[NSDate date] timeIntervalSince1970];
    book.bookID = [NSString stringWithFormat:@"%@_%f",[book.name md5Encrypt],book.addDate];
    
    // 开线程解析
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        // 计算代码运行时间
        CFAbsoluteTime startTime = CFAbsoluteTimeGetCurrent();
        
        book.content = [self bookAnalysisWithFilePath:path];

        CFAbsoluteTime linkTime = (CFAbsoluteTimeGetCurrent() - startTime);
        // 打印运行时间
        NSLog(@"---- bookAnalysisWithFilePath Linked in %f ms", linkTime * 1000.0);
        
        // 计算代码运行时间
        startTime = CFAbsoluteTimeGetCurrent();
        
        NSMutableArray *chapters = [NSMutableArray array];
        [self separateChapter:&chapters content:book.content];
        book.chapters = chapters;
        book.allChapters = chapters.count;
        
        linkTime = (CFAbsoluteTimeGetCurrent() - startTime);
        // 打印运行时间
        RKLog(@"---- separateChapter ---- Linked in %f ms", linkTime * 1000.0);
        
        [self saveChaptersWithBook:book];
        [self addHomeListWithBook:book];
    });
}

/// 首页列表添加数据
- (void)addHomeListWithBook:(RKBook *)book {
    
    NSMutableArray *bookList = [[NSMutableArray alloc] initWithContentsOfFile:kHomeBookListsPath];
    if (!bookList) {
        bookList = [NSMutableArray array];
    }
    
    NSMutableDictionary *bookDict = book.mj_keyValues;
    if ([[bookDict allKeys] containsObject:@"content"]) {
        [bookDict removeObjectForKey:@"content"];
    }
    if ([[bookDict allKeys] containsObject:@"chapters"]) {
        [bookDict removeObjectForKey:@"chapters"];
    }
    if ([[bookDict allKeys] containsObject:@"chapter"]) {
        [bookDict removeObjectForKey:@"chapter"];
    }
    [bookList addObject:bookDict];
    [bookList writeToFile:kHomeBookListsPath atomically:YES];
    
    RKLog(@"---- %@\n%lu",bookDict,(unsigned long)[bookList count]);
    
    // 首页刷新
    self.isNeedRefresh = YES;
}

/// 解析书籍
- (NSString *)bookAnalysisWithFilePath:(NSString *)path {
    
    NSString *content = [self encodeWithFilePath:path];
    
    return content;
}

/// 保存书籍章节
- (void)saveChaptersWithBook:(RKBook *)book {
    //计算代码运行时间
    CFAbsoluteTime startTime = CFAbsoluteTimeGetCurrent();
    
    // plist 名称
    NSString *path = [NSString stringWithFormat:@"%@/%@.plist",kBookAnalysisPath,book.bookID];
    
    NSMutableArray *chapters = [NSMutableArray array];
    for (RKChapter *chapter in book.chapters ) {
        [chapters addObject:chapter.mj_keyValues];
    }
    [chapters writeToFile:path atomically:YES];
    
    CFAbsoluteTime linkTime = (CFAbsoluteTimeGetCurrent() - startTime);
    //打印运行时间
    RKLog(@"---- Linked in %f ms", linkTime * 1000.0);
}

#pragma mark - 删
/// 删除书籍
- (void)deleteBookWithName:(NSString *)name {
    // 删除解析文件
    [self deleteAnalysisWithName:name];
    
    // 删除首页列表数据
    NSMutableArray *bookList = [[NSMutableArray alloc] initWithContentsOfFile:kHomeBookListsPath];
    for (NSInteger i = 0; i < bookList.count; i++) {
        NSDictionary *dict = bookList[i];
        if ([dict[@"path"] isEqualToString:name]) {
            [bookList removeObjectAtIndex:i];
            break;
        }
    }
    [bookList writeToFile:kHomeBookListsPath atomically:YES];
    
    // 删除文件
    [self deleteBookFileWithName:name];
    
    // 首页刷新
    self.isNeedRefresh = YES;
}

/// 删除解析文件
- (void)deleteAnalysisWithName:(NSString *)name {
    NSMutableArray *arr = [self getHomeList];
    RKBook *deleteBook;
    for (RKBook *book in arr) {
        if ([book.name isEqualToString:name]) {
            deleteBook = book;
            break;
        }
    }
    if (deleteBook) {
        NSString *path = [NSString stringWithFormat:@"%@/%@.plist",kBookAnalysisPath,deleteBook.bookID];
        NSFileManager *manager = [NSFileManager defaultManager];
        NSError *error;
        [manager removeItemAtPath:path error:&error];
        if (error) {
            RKLog(@"---- %@",error);
        }
    }
}

/// 删除全部书籍
- (void)clearAllBooksWithResult:(void(^)(BOOL isSuccess))handler {
    // 删除首页列表数据
    NSFileManager *manager = [NSFileManager defaultManager];
    NSError *error = nil;
    if ([manager fileExistsAtPath:kHomeBookListsPath]) {
        [manager removeItemAtPath:kHomeBookListsPath error:&error];
    }
    if (error) {
        RKLog(@"---- %@",error);
        if (handler) {
            handler(NO);
            return;
        }
    }
    
    // 删除所有书籍缓存 BookAnalysis
    NSDirectoryEnumerator *dirEnum = [[NSFileManager defaultManager] enumeratorAtPath:kBookAnalysisPath];
    NSString *fileName;
    while (fileName = [dirEnum nextObject]) {
        [manager removeItemAtPath:[NSString stringWithFormat:@"%@/%@",kBookAnalysisPath,fileName] error:&error];
        if (error && handler) {
            handler(NO);
            return;
        }
    }
    
    // 删除Books下所有数据
    dirEnum = [[NSFileManager defaultManager] enumeratorAtPath:kBookSavePath];
    while (fileName = [dirEnum nextObject]) {
        [manager removeItemAtPath:[NSString stringWithFormat:@"%@/%@",kBookSavePath,fileName] error:&error];
        if (error) {
            RKLog(@"---- %@",error);
            if (handler) {
                handler(NO);
                return;
            }
        }
    }
    
    if (handler) {
        handler(YES);
    }
}

/// 删除书籍文件
- (void)deleteBookFileWithName:(NSString *)name {
    NSString *path = [NSString stringWithFormat:@"%@/%@",kBookSavePath,name];
    NSFileManager *manager = [NSFileManager defaultManager];
    NSError *error;
    [manager removeItemAtPath:path error:&error];
    if (error) {
        RKLog(@"---- %@",error);
    }
}

#pragma mark - 改
/**
 更新列表数据
 @param book 书籍
 @return 首页列表
 */
- (NSMutableArray *)updateWithBook:(RKBook *)book {
    NSMutableArray *bookList = [self getHomeList];
    NSInteger index = 0;
    for (RKBook *subBook in bookList) {
        index++;
        if ([subBook.bookID isEqualToString:book.bookID]) {
            break;
        }
    }
    
    [bookList replaceObjectAtIndex:index withObject:book];
    
    return bookList;
}

/**
 保存首页列表
 @param bookList 首页列表
 */
- (void)saveBookList:(NSMutableArray<RKBook *> *)bookList {
    
    [bookList sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        
        RKBook *book1 = obj1;
        RKBook *book2 = obj2;
        
        if (book1.isTop && book2.isTop) {
            return NSOrderedSame;
        }
        if (book1.isTop && !book2.isTop) {
            return NSOrderedAscending;
        }
        if (!book1.isTop && book2.isTop) {
            return NSOrderedDescending;
        }
        if (book1.lastReadDate > book2.lastReadDate) {
            return NSOrderedAscending;
        } else {
            return NSOrderedDescending;
        }
    }];
    
    NSMutableArray *bookDicts = [NSMutableArray array];
    for (RKBook *book in bookList) {
        NSMutableDictionary *bookDict = book.mj_keyValues;
        if ([[bookDict allKeys] containsObject:@"content"]) {
            [bookDict removeObjectForKey:@"content"];
        }
        if ([[bookDict allKeys] containsObject:@"chapters"]) {
            [bookDict removeObjectForKey:@"chapters"];
        }
        if ([[bookDict allKeys] containsObject:@"chapter"]) {
            [bookDict removeObjectForKey:@"chapter"];
        }
        [bookDicts addObject:bookDict];
    }
    
    [bookDicts writeToFile:kHomeBookListsPath atomically:YES];
//    RKLog(@"---- save:%@",bookDicts);
}
#pragma mark - 查
/// 获取首页书籍列表
- (NSMutableArray *)getHomeList {
    NSMutableArray *bookList = [[NSMutableArray alloc] initWithContentsOfFile:kHomeBookListsPath];
    if (!bookList) {
        bookList = [NSMutableArray array];
    } else {
        NSMutableArray *books = [NSMutableArray array];
        for (NSDictionary *dict in bookList) {
            RKBook *book = [RKBook mj_objectWithKeyValues:dict];
            [books addObject:book];
        }
        return books;
    }
    return bookList;
}

#pragma mark - func
#pragma mark -- 解码
- (NSString *)encodeWithFilePath:(NSString *)path {
    
//    path = [path stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]];
    
    // 拼接路径
    path = [kBookSavePath stringByAppendingString:[NSString stringWithFormat:@"/%@",path]];
    
    NSError *error = NULL;
    NSString *content = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&error];
    if (!content) {
        if (error) {
            RKLog(@"---- NSUTF8StringEncoding -- 解码错误 -- %@",error.domain);
            content = nil;
            error = NULL;
        } else {
            RKLog(@"---- NSUTF8StringEncoding -- 解码成功");
        }
    }
    if (!content) {
        content = [NSString stringWithContentsOfFile:path encoding:0x80000632 error:&error];
        if (error) {
            RKLog(@"---- GBK -- 解码错误 -- %@",error.domain);
            content = nil;
            error = NULL;
        } else {
            RKLog(@"---- GBK -- 解码成功");
        }
    }
    if (!content) {
        NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
        // 文件内容转换成字符串类型
        content = [NSString stringWithContentsOfFile:path encoding:enc error:&error];
        if (error) {
            RKLog(@"---- kCFStringEncodingGB_18030_2000 -- 解码错误 -- %@",error.domain);
            content = nil;
            error = NULL;
        } else {
            RKLog(@"---- kCFStringEncodingGB_18030_2000 -- 解码成功");
        }
    }
    if (!content) {
        return @"";
    }
    return content;
}

/// 拆分章节 章节放入数组
- (void)separateChapter:(NSMutableArray * __autoreleasing *)chapters content:(NSString *)content {
    [*chapters removeAllObjects];
    
    // 正则匹配
    NSString *parten;
//    parten = @"(\\s)*[第]{0,1}[0-9一二三四五六七八九十百千万]+[章回节卷集幕计][ \t]*(\\S)+?";
    parten = @"(\\s)+[第]{0,1}[0-9一二三四五六七八九十百千万]+[章回节卷集幕计][ \t]*(\\S)*";
//    parten = @"(\\s)*[第]{0,1}[0-9一二三四五六七八九十百千万]+[章回节卷集幕计][ \t]*(\\S)*";
//    parten = @"^.{0,6}(第[0-9一两二三四五六七八九十零百千]{1,6}(章|节|集|卷|部|篇|回)|楔子|前言|引子)([ \\s:]{0,2}|:)([^\\s]{0,36})$";
//    parten = @"(\\s)*([第]{0,1}[0-9一两二三四五六七八九十零百千]{1,6}(章|节|集|卷|部|篇|回)|楔子|前言|引子)([ \\s:]{0,2}|:)([^\\s]{0,36})$";
    
    NSError *error = NULL;
    NSRegularExpression *reg = [NSRegularExpression regularExpressionWithPattern:parten options:NSRegularExpressionCaseInsensitive error:&error];
    
    NSArray *match = [reg matchesInString:content options:NSMatchingReportCompletion range:NSMakeRange(0, [content length])];
    RKLog(@"---- 章节个数 -- %lu",(unsigned long)match.count);
    
    // 第一章
    NSRange firstRange = ((NSTextCheckingResult *)match.firstObject).range;
    
    // 初始
    RKChapter *model = [[RKChapter alloc] init];
    model.title = @"开始";
    model.location = 0;
    model.length = firstRange.location;
    [*chapters addObject:model];
    
    if (match.count != 0) {
        NSRange currentRange = [(NSTextCheckingResult *)match[0] range];

        NSUInteger count = [match count];
        for (int i = 0; i < count; i++) {
            if (i < count - 1) {
                NSRange nextRange = [(NSTextCheckingResult *)match[i+1] range];
                NSInteger local = nextRange.location;
                
                RKChapter *model = [[RKChapter alloc] init];
                model.title = [[content substringWithRange:currentRange] stringByTrimmingWhitespaceAndAllNewLine];
                model.location = currentRange.location;
                model.length = local - model.location;
                [*chapters addObject:model];
                
                currentRange = nextRange;
            }
        }
        
        RKChapter *model = [[RKChapter alloc] init];
        model.title = [content substringWithRange:[(NSTextCheckingResult *)match.lastObject range]];
        model.location = [(NSTextCheckingResult *)match.lastObject range].location;
        model.length = content.length - model.location;
        [*chapters addObject:model];
        
//        RKLog(@"---- %ld",(long)[*chapters count]);
    } else {// 没找出章节
        RKChapter *model = [[RKChapter alloc] init];
        model.title = @"开始";
        [*chapters addObject:model];
    }
}

#pragma mark -- other
/**
 计算文件的大小，单位为 M
 @param path 文件路径
 @return 大小(M)
 */
- (CGFloat)getFileSize:(NSString *)path {
    // 转码
    NSString *filePath = [path stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]];
    RKLog(@"---- 转码\npath:%@\nfilePath:%@",path,filePath);
    NSFileManager *fileManager = [NSFileManager defaultManager];
    float filesize = -1.0f;
    if ([fileManager fileExistsAtPath:path]) {
        NSDictionary *fileDic = [fileManager attributesOfItemAtPath:path error:nil];//获取文件的属性
        unsigned long long size = [[fileDic objectForKey:NSFileSize] longLongValue];
        filesize = size/1000.0/1000.0;
    }
    if (filesize == -1.0f) {
        if ([fileManager fileExistsAtPath:filePath]) {
            NSDictionary *fileDic = [fileManager attributesOfItemAtPath:filePath error:nil];//获取文件的属性
            unsigned long long size = [[fileDic objectForKey:NSFileSize] longLongValue];
            filesize = size/1000.0/1000.0;
        }
    }
    RKLog(@"---- 文件大小 -- %f",filesize);
    return filesize;
}

/// 手机剩余空间
+ (long long)freeDiskSpaceInBytes {
    struct statfs buf;
    long long freespace = -1;
    if(statfs("/var", &buf) >= 0){
        freespace = (long long)(buf.f_bsize * buf.f_bfree);
    }
    return freespace;
}

/// 手机总空间
+ (long long)totalDiskSpaceInBytes {
    struct statfs buf;
    long long freespace = 0;
    if (statfs("/", &buf) >= 0) {
        freespace = (long long)buf.f_bsize * buf.f_blocks;
    }
    if (statfs("/private/var", &buf) >= 0) {
        freespace += (long long)buf.f_bsize * buf.f_blocks;
    }
    return freespace;
}

/// 计算文件大小
+ (NSString *)humanReadableStringFromBytes:(unsigned long long)byteCount {
    float numberOfBytes = byteCount;
    int multiplyFactor = 0;
    
    NSArray *tokens = [NSArray arrayWithObjects:@"bytes",@"KB",@"MB",@"GB",@"TB",@"PB",@"EB",@"ZB",@"YB",nil];
    
    while (numberOfBytes > 1024) {
        numberOfBytes /= 1024;
        multiplyFactor++;
    }
    
    return [NSString stringWithFormat:@"%4.2f %@",numberOfBytes, [tokens objectAtIndex:multiplyFactor]];
}

@end
