//
//  UIColor+R_Category.h
//  R_category
//
//  Created by rzk on 2017/10/10.
//  Copyright © 2017年 rzk. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (R_Category)
/**
 *  生成一个随机色
 *
 *  @return UIColor
 */
+ (UIColor *)colorWithRandom;

/**
 *  生成一个随机色，alpha也是随机色
 *
 *  @param alpha 透明度
 *
 *  @return 透明度随机的颜色
 */
+ (UIColor *)colorWithRandomWithAlpha:(CGFloat) alpha;

/**
 *  根据十六进制字符串生成一个UIColor
 *
 *  @param hexString 十六进制字符串
 *
 *  @return UIColor
 */
+ (UIColor *)colorWithHexString:(NSString *)hexString;

/**
 *  根据十六进制字符串生成一个UIColor
 *
 *  @param hexString 十六进制字符串
 *  @param alpha a value from 0.0 to 1.0. 零到一
 
 *  @return UIColor
 */
+ (UIColor *)colorWithHexString:(NSString *)hexString withAlpha:(CGFloat)alpha;

/**
 *  根据红绿蓝三色的(0~255)值生成一个UIColor
 *
 *  @param red   红 0~255
 *  @param green 绿 0~255
 *  @param blue  蓝 0~255
 *  @param alpha 透明度 0~1
 *
 *  @return UIColor
 */
+ (UIColor *)colorWithR:(CGFloat)red g:(CGFloat)green b:(CGFloat)blue alpha:(CGFloat)alpha;
@end
