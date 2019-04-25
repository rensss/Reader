//
//  RKFileManage.h
//  Reader
//
//  Created by RZK on 2019/4/20.
//  Copyright © 2019 RZK. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RKFileManager : NSObject

/// 文件管理单例
+ (instancetype)shareInstance;


#pragma mark - 增
/// 添加书籍
- (void)saveBookWithPath:(NSString *)path;

/// 解析书籍
- (NSString *)bookAnalysisWithFilePath:(NSString *)path;

#pragma mark - 删


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

@end
