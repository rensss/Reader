//
//  UIColor+R_Category.m
//  R_category
//
//  Created by rzk on 2017/10/10.
//  Copyright © 2017年 rzk. All rights reserved.
//

#import "UIColor+R_Category.h"

@implementation UIColor (R_Category)
/**
 *  生成一个随机色
 *
 *  @return UIColor
 */
+ (UIColor *)colorWithRandom {
    return [UIColor colorWithRed:arc4random_uniform(256) / 255.0 green:arc4random_uniform(256) / 255.0 blue:arc4random_uniform(256) / 255.0 alpha:1];
}

+ (UIColor *)colorWithRandomWithAlpha:(CGFloat) alpha {
    return [UIColor colorWithRed:arc4random_uniform(256) / 255.0 green:arc4random_uniform(256) / 255.0 blue:arc4random_uniform(256) / 255.0 alpha:alpha];
}

/**
 *  根据十六进制字符串生成一个UIColor
 *  @param hexString 十六进制字符串
 *  @return UIColor
 */
+ (UIColor *)colorWithHexString:(NSString *)hexString {
    return [UIColor colorWithHexString:hexString withAlpha:1.0f];
}

/**
 *  根据十六进制字符串生成一个UIColor
 *  @param hexString 十六进制字符串
 *  @param alpha a value from 0.0 to 1.0. 零到一
 *  @return UIColor
 */
+ (UIColor *)colorWithHexString:(NSString *)hexString withAlpha:(CGFloat)alpha {
    if ([hexString length] <6){//长度不合法
        return [UIColor blackColor];
    }
    NSString *tempString=[hexString lowercaseString];
    if ([tempString hasPrefix:@"0x"]){//检查开头是0x
        tempString = [tempString substringFromIndex:2];
    }else if ([tempString hasPrefix:@"#"]){//检查开头是#
        tempString = [tempString substringFromIndex:1];
    }
    if ([tempString length] !=6){
        return [UIColor blackColor];
    }
    //分解三种颜色的值
    NSRange range;
    range.location =0;
    range.length =2;
    NSString *rString = [tempString substringWithRange:range];
    range.location =2;
    NSString *gString = [tempString substringWithRange:range];
    range.location =4;
    NSString *bString = [tempString substringWithRange:range];
    //取三种颜色值
    unsigned int r, g, b;
    [[NSScanner scannerWithString:rString]scanHexInt:&r];
    [[NSScanner scannerWithString:gString]scanHexInt:&g];
    [[NSScanner scannerWithString:bString]scanHexInt:&b];
    return [UIColor colorWithRed:((float) r /255.0f)
                           green:((float) g /255.0f)
                            blue:((float) b /255.0f)
                           alpha:alpha];
}

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
+ (UIColor *)colorWithR:(CGFloat)red g:(CGFloat)green b:(CGFloat)blue alpha:(CGFloat)alpha {
    return [UIColor colorWithRed:(red)/255.0f green:(green)/255.0f blue:(blue)/255.0f alpha:(alpha)];
}
@end
