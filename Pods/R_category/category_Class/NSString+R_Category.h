//
//  NSString+R_Category.h
//  R_category
//
//  Created by rzk on 2017/10/10.
//  Copyright © 2017年 rzk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface NSString (R_Category)

/**
 *  去除字符串两端的空白和换行
 *
 *  @return 去除空白和换行后的字符串
 */
- (NSString *)stringByTrimmingCharactersInSet;

/**
 *  去除字符串 两端空白 和所有的换行
 *
 *  @return NSString
 */
- (NSString *)stringByTrimmingWhitespaceAndAllNewLine;

/**
 *  字符串首字母转拼音,返回大写拼音首字母
 *
 *  @return 字符串首字母拼音大写
 */
- (NSString *)stringToFirstCharactor;

#pragma mark - 字符串验证
/**
 *  验证字符串是否是邮箱格式
 *
 *  @return BOOL
 */
- (BOOL)isEmail;

/**
 *  验证字符串是否是手机号码格式
 *
 *  @return BOOL
 */
- (BOOL)isMobile;

/**
 *  验证是字符串是否是URL格式
 *
 *  @return BOOL
 */
- (BOOL)isURL;

#pragma mark - MD5加密
/**
 md5加密方法
 @return 加密过的字符串
 */
- (NSString *)md5Encrypt;

#pragma mark - 计算文字大小
/**
 根据尺寸求文字高低
 @param maxSize 最大尺寸(限高/限宽)
 @param font 字体
 @return 尺寸
 */
- (CGSize)sizeWithMaxSize:(CGSize)maxSize andFont:(UIFont *)font;

/**
 匹配字符串中得链接  并返回链接字符串数组
 @return 返回一个标准url格式的数组
 */
- (NSArray *)matchLinks;

/**
 格式化时间字符串
 @return 间隔
 */
- (NSString *)formatterDateString;

/**
 验证生份证号码是否符合规则
 @return yes or no
 */
- (BOOL)judgeIdentityStringValid;

@end
