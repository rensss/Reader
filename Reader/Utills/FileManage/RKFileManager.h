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
- (void)bookAnalysis;

#pragma mark - 删
#pragma mark - 改
#pragma mark - 查


@end