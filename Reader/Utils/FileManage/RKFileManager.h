//
//  RKFileManage.h
//  Reader
//
//  Created by RZK on 2019/4/20.
//  Copyright © 2019 RZK. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RKBook.h" // book对象

@interface RKFileManager : NSObject

@property (nonatomic, assign) BOOL isNeedRefresh; /**< 是否需要刷新数据*/

/// 文件管理单例
+ (instancetype)shareInstance;

#pragma mark - 增
/// 添加书籍
- (void)saveBookWithPath:(NSString *)path;

/// 解析书籍
- (NSString *)bookAnalysisWithFilePath:(NSString *)path;

#pragma mark - 删
/// 删除书籍
- (void)deleteBookWithName:(NSString *)name;

/// 删除全部书籍
- (void)clearAllBooksWithResult:(void(^)(BOOL isSuccess))handler;

#pragma mark - 改
/**
 保存首页列表
 @param bookList 首页列表
 */
- (void)saveBookList:(NSMutableArray *)bookList;

/**
 更新列表数据
 @param book 书籍
 @return 首页列表
 */
- (NSMutableArray *)updateWithBook:(RKBook *)book;

#pragma mark - 查
/// 获取首页书籍列表
- (NSMutableArray *)getHomeList;

#pragma mark - func
/// 书籍解码 返回内容
- (NSString *)encodeWithFilePath:(NSString *)path;

/**
 计算文件的大小，单位为 M
 @param path 文件路径
 @return 大小(M)
 */
- (CGFloat)getFileSize:(NSString *)path;


// 系统磁盘信息相关
+ (long long)freeDiskSpaceInBytes;
+ (long long)totalDiskSpaceInBytes;
+ (NSString *)humanReadableStringFromBytes:(unsigned long long)byteCount;
@end
