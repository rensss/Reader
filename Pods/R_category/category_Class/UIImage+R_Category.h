//
//  UIImage+R_Category.h
//  R_category
//
//  Created by rzk on 2017/10/10.
//  Copyright © 2017年 rzk. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (R_Category)

/**
 根据颜色 大小 生成图片
 @param color 颜色
 @param size 尺寸
 @return 图片
 */
+ (UIImage *)imageWithColor:(UIColor *)color andSize:(CGSize)size;

/**
 根据颜色 生成图片 默认 1x1
 @param color 图片的背景颜色
 @return UIImage对象
 */
+ (UIImage *)imageWithColor:(UIColor *)color;


/**
 *  获取启动图
 *
 *  @return 启动图
 */
//+ (UIImage *)getTheLaunchImage;

@end
