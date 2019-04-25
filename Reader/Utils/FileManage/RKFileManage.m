//
//  RKFileManager.m
//  Reader
//
//  Created by RZK on 2019/4/20.
//  Copyright © 2019 RZK. All rights reserved.
//

#import "RKFileManager.h"

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
    // 书名 带扩展名
    NSString *name = [path componentsSeparatedByString:@"/"].lastObject;
    book.name = [name componentsSeparatedByString:@"."].firstObject;
    book.coverImage = [NSString stringWithFormat:@"cover%d",arc4random()%10+1];
    book.path = path;
    book.size = [self getFileSize:path];
    book.addDate = [[NSDate dateWithTimeIntervalSinceNow:0] timeIntervalSince1970];
    book.bookID = [NSString stringWithFormat:@"%@_%f",[book.name md5Encrypt],book.addDate];
    
    // 开线程解析
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        book.content = [self bookAnalysisWithFilePath:path];
        
        // 计算代码运行时间
        CFAbsoluteTime startTime = CFAbsoluteTimeGetCurrent();
        
        NSMutableArray *chapters = [NSMutableArray array];
        [self separateChapter:&chapters content:book.content];
        book.chapters = chapters;
        book.allChapters = chapters.count;
        
        CFAbsoluteTime linkTime = (CFAbsoluteTimeGetCurrent() - startTime);
        // 打印运行时间
        RKLog(@"separateChapter ----- Linked in %f ms", linkTime * 1000.0);
        
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
    
    RKLog(@"%@\n%@",bookDict,bookList);
    
    // 首页刷新
    self.isNeedRefresh = YES;
}

/// 解析书籍
- (NSString *)bookAnalysisWithFilePath:(NSString *)path {
    
    //计算代码运行时间
    CFAbsoluteTime startTime = CFAbsoluteTimeGetCurrent();
    
    NSString *content = [self encodeWithFilePath:path];
    
    CFAbsoluteTime linkTime = (CFAbsoluteTimeGetCurrent() - startTime);
    //打印运行时间
    RKLog(@"encodeWithFilePath ----- Linked in %f ms", linkTime * 1000.0);
    
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
    RKLog(@"saveChaptersWithBook ----- Linked in %f ms", linkTime * 1000.0);
}

#pragma mark - 删
/// 删除书籍
- (void)deleteBookWithPath:(NSString *)path {
    // 删除解析文件
    [self deleteAnalysisWithPath:path];
    // 删除首页列表数据
    NSMutableArray *bookList = [[NSMutableArray alloc] initWithContentsOfFile:kHomeBookListsPath];
    for (NSInteger i = 0; i < bookList.count; i++) {
        NSDictionary *dict = bookList[i];
        if ([dict[@"path"] isEqualToString:path]) {
            [bookList removeObjectAtIndex:i];
            break;
        }
    }
    [bookList writeToFile:kHomeBookListsPath atomically:YES];
    // 首页刷新
    self.isNeedRefresh = YES;
}

- (void)deleteAnalysisWithPath:(NSString *)path {
    NSMutableArray *arr = [self getHomeList];
    RKBook *deleteBook;
    for (RKBook *book in arr) {
        if ([book.path isEqualToString:path]) {
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
            RKLog(@"%@",error);
        }
    }
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
- (NSString *)encodeWithFilePath:(NSString *)path {
    
    NSError *error = NULL;
    NSString *content = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&error];
    if (!content) {
        if (error) {
            RKLog(@"NSUTF8StringEncoding -- 解码错误 -- %@",error.domain);
            content = nil;
            error = NULL;
        }
    }
    if (!content) {
        content = [NSString stringWithContentsOfFile:path encoding:0x80000632 error:&error];
        if (error) {
            RKLog(@"GBK -- 解码错误 -- %@",error.domain);
            content = nil;
            error = NULL;
        }
    }
    if (!content) {
        NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
        // 文件内容转换成字符串类型
        content = [NSString stringWithContentsOfFile:path encoding:enc error:&error];
        if (error) {
            RKLog(@"kCFStringEncodingGB_18030_2000 -- 解码错误 -- %@",error.domain);
            content = nil;
            error = NULL;
        }
    }
    if (!content) {
        return @"";
    }
    return content;
}

/**
 计算文件的大小，单位为 M
 @param path 文件路径
 @return 大小(M)
 */
- (CGFloat)getFileSize:(NSString *)path {
    // 转码
    NSString *filePath = [path stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]];
    RKLog(@"转码\npath:%@\nfilePath:%@",path,filePath);
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
    RKLog(@"文件大小 -- %f",filesize);
    return filesize;
}

/// 拆分章节 章节放入数组
- (void)separateChapter:(NSMutableArray * __autoreleasing *)chapters content:(NSString *)content {
    [*chapters removeAllObjects];
    
    // 正则匹配
    NSString *parten = @"(\\s)+[第]{0,1}[0-9一二三四五六七八九十百千万]+[章回节卷集幕计][ \t]*(\\S)*";
    NSError *error = NULL;
    NSRegularExpression *reg = [NSRegularExpression regularExpressionWithPattern:parten options:NSRegularExpressionCaseInsensitive error:&error];
    
    NSArray* match = [reg matchesInString:content options:NSMatchingReportCompletion range:NSMakeRange(0, [content length])];
    RKLog(@"章节个数 -- %lu",(unsigned long)match.count);
    if (match.count != 0) {
        __block NSRange lastRange = NSMakeRange(0, 0);
        [match enumerateObjectsUsingBlock:^(NSTextCheckingResult * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSRange range = [obj range];
            NSInteger local = range.location;
            if (idx == 0) {
                RKChapter *model = [[RKChapter alloc] init];
                model.title = @"开始";
                NSUInteger len = local;
                model.location = 0;
                model.length = len;
//                model.content = [content substringWithRange:NSMakeRange(0, len)];
                [*chapters addObject:model];
            }
            
            if (idx > 0 ) {
                RKChapter *model = [[RKChapter alloc] init];
                model.title = [content substringWithRange:lastRange];
                NSUInteger len = local-lastRange.location;
                model.location = local;
                model.length = len;
//                model.content = [content substringWithRange:NSMakeRange(lastRange.location, len)];
                [*chapters addObject:model];
            }
            
            if (idx == match.count-1) {
                RKChapter *model = [[RKChapter alloc] init];
                model.title = [content substringWithRange:range];
                model.location = local;
                model.length = content.length-local;
//                model.content = [content substringWithRange:NSMakeRange(local, content.length-local)];
                [*chapters addObject:model];
            }
            lastRange = range;
        }];
    } else {// 没找出章节
        RKChapter *model = [[RKChapter alloc] init];
        model.title = @"开始";
//        model.content = content;
        [*chapters addObject:model];
    }
}

@end
