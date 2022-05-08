//
//  UIImage+R_Category.m
//  R_category
//
//  Created by rzk on 2017/10/10.
//  Copyright © 2017年 rzk. All rights reserved.
//

#import "UIImage+R_Category.h"

@implementation UIImage (R_Category)

/**
 根据颜色 大小 生成图片
 @param color 颜色
 @param size 尺寸
 @return 图片
 */
+ (UIImage *)imageWithColor:(UIColor *)color andSize:(CGSize)size {
    CGFloat imageW = size.width;
    CGFloat imageH = size.height;
    
    // 1.开启基于位图的图形上下文
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(imageW, imageH), NO, 0.0);
    // 2.画一个color颜色的矩形框
    [color set];
    UIRectFill(CGRectMake(0, 0, imageW, imageH));
    // 3.拿到图片
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    // 4.关闭上下文
    UIGraphicsEndImageContext();
    // 返回图片
    return image;
}

/**
 根据颜色 生成图片 默认 1x1
 @param color 图片的背景颜色
 @return UIImage对象
 */
+ (UIImage *)imageWithColor:(UIColor *)color {
    return [UIImage imageWithColor:color andSize:CGSizeMake(1, 1)];
}

/**
 *  获取启动图
 *
 *  @return 启动图
 */
//+ (UIImage *)getTheLaunchImage {
//    CGSize viewSize = [UIScreen mainScreen].bounds.size;
//    
//    NSString *viewOrientation = nil;
//    if (([[UIApplication sharedApplication] statusBarOrientation] == UIInterfaceOrientationPortraitUpsideDown) || ([[UIApplication sharedApplication] statusBarOrientation] == UIInterfaceOrientationPortrait)) {
//        viewOrientation = @"Portrait";
//    } else {
//        viewOrientation = @"Landscape";
//    }
//    
//    NSString *launchImage = nil;
//    
//    NSArray* imagesDict = [[[NSBundle mainBundle] infoDictionary] valueForKey:@"UILaunchImages"];
//    for (NSDictionary* dict in imagesDict) {
//        CGSize imageSize = CGSizeFromString(dict[@"UILaunchImageSize"]);
//        if (CGSizeEqualToSize(imageSize, viewSize) && [viewOrientation isEqualToString:dict[@"UILaunchImageOrientation"]]) {
//            launchImage = dict[@"UILaunchImageName"];
//        }
//    }
//    
//    return [UIImage imageNamed:launchImage];
//}

@end
