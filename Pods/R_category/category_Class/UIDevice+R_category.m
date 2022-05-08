//
//  UIDevice+R_category.m
//  R_category
//
//  Created by MBP on 2018/10/27.
//  Copyright © 2018年 rzk. All rights reserved.
//

#import "UIDevice+R_category.h"

@implementation UIDevice (R_category)

+ (void)switchNewOrientation:(UIInterfaceOrientation)interfaceOrientation {
    
    NSNumber *resetOrientationTarget = [NSNumber numberWithInt:UIInterfaceOrientationUnknown];
    
    [[UIDevice currentDevice] setValue:resetOrientationTarget forKey:@"orientation"];
    
    NSNumber *orientationTarget = [NSNumber numberWithInteger:interfaceOrientation];
    
    [[UIDevice currentDevice] setValue:orientationTarget forKey:@"orientation"];
}

/**
 获取磁盘剩余大小(MB 单位:1MB = 1000Byte)
 @return 大小
 */
+ (float)getSystemFreeSize {
    // 剩余大小
    float freesize = 0.0;
    // 错误
    NSError *error = nil;
    if (@available(iOS 11.0, *)) {
        NSURL *fileURL = [[NSURL alloc] initFileURLWithPath:NSTemporaryDirectory()];
        NSDictionary *results = [fileURL resourceValuesForKeys:@[NSURLVolumeAvailableCapacityForImportantUsageKey] error:&error];
        if (results) {
            NSNumber *free = results[NSURLVolumeAvailableCapacityForImportantUsageKey];
            freesize = [free unsignedLongLongValue]*1.0/(1000*1000*1000);
        } else {
            NSLog(@"获取SystemFreeSize失败!");
        }
    } else {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSDictionary *dictionary = [[NSFileManager defaultManager] attributesOfFileSystemForPath:[paths lastObject] error: &error];
        if (dictionary) {
            NSNumber *free = [dictionary objectForKey:NSFileSystemFreeSize];
            freesize = [free unsignedLongLongValue]*1.0/(1000*1000*1000);
        } else {
            NSLog(@"获取SystemFreeSize失败!");
        }
    }
    
    return freesize;
}

/**
 获取磁盘总大小(MB 单位:1MB = 1000Byte)
 @return 大小
 */
+ (float)getSystemTotleSize {
    // 总大小
    float totalsize = 0.0;
    // 错误
    NSError *error = nil;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSDictionary *dictionary = [[NSFileManager defaultManager] attributesOfFileSystemForPath:[paths lastObject] error: &error];
    if (dictionary) {
        NSNumber *_free = [dictionary objectForKey:NSFileSystemSize];
        totalsize = [_free unsignedLongLongValue]*1.0/(1000*1000*1000);
    } else {
        NSLog(@"获取SystemFreeSize失败!");
    }
    return totalsize;
}

@end
