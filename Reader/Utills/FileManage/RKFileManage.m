//
//  RKFileManage.m
//  Reader
//
//  Created by RZK on 2019/4/20.
//  Copyright © 2019 RZK. All rights reserved.
//

#import "RKFileManage.h"

@interface RKFileManage ()



@end

@implementation RKFileManage

static RKFileManage *_fileManage;

#pragma mark - 单例
+ (instancetype)shareInstance {
	
	static dispatch_once_t onceToken;
	
	dispatch_once(&onceToken, ^{
		_fileManage = [[RKFileManage alloc] init];
	});
	
	return _fileManage;
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
		_fileManage = [super allocWithZone:zone];
	});
	
	return _fileManage;
}

- (id)copyWithZone:(NSZone *)zone {
	return _fileManage;
}

#pragma mark - func
#pragma mark - 增
/// 添加书籍
- (void)saveBookWithPath:(NSString *)path {
	
}


@end
