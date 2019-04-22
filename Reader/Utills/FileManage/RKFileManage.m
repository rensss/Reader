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
        // 先判断目录是否存在，不存在才创建
        if  (![fileManager fileExistsAtPath:kBookSavePath isDirectory:&isDir]) {
            BOOL res = [fileManager createDirectoryAtPath:kBookSavePath withIntermediateDirectories:YES attributes:nil error:nil];
            if (res) {
                RKLog(@"文件已创建\nkBookSavePath:%@",kBookSavePath);
            }
        } else {
            RKLog(@"文件已存在\nkBookSavePath:%@",kBookSavePath);
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
    [self bookAnalysis];
}

/// 解析书籍
- (void)bookAnalysis {
    
}


@end
