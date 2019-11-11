//
//  NSString+R_Category.m
//  R_category
//
//  Created by rzk on 2017/10/10.
//  Copyright © 2017年 rzk. All rights reserved.
//

#import "NSString+R_Category.h"
#import "CommonCrypto/CommonDigest.h"

@implementation NSString (R_Category)

/**
 去除字符串两端的空白和换行
 @return 去除空白和换行后的字符串
 */
- (NSString *)stringByTrimmingCharactersInSet {
    //去除 字符串两端的空格 和 回车
    NSString *temp = [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    return temp;
}

/**
 去除字符串 两端空白 和所有的换行
 @return NSString
 */
- (NSString *)stringByTrimmingWhitespaceAndAllNewLine {
    NSArray *words = [self componentsSeparatedByCharactersInSet :[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *temp = [words componentsJoinedByString:@""];
    return temp;
}

/**
 字符串首字母转拼音,返回大写拼音首字母
 @return 字符串首字母拼音大写
 */
- (NSString *)stringToFirstCharactor {
    NSString *charactor = @"#";
    
    NSMutableString *source = [NSMutableString stringWithString:self];
    CFStringTransform((__bridge CFMutableStringRef)source, NULL, kCFStringTransformMandarinLatin, NO);
    CFStringTransform((__bridge CFMutableStringRef)source, NULL, kCFStringTransformStripDiacritics, NO);
    
    char ch = (char)[source characterAtIndex:0];
    
    if ((ch >= 'a' && ch <= 'z') || (ch >= 'A' && ch <= 'Z')) {
        if (ch >= 'a' && ch <= 'z') {
            charactor = [NSString stringWithFormat:@"%c",ch - 32];
            return charactor;
        } else {
            charactor = [NSString stringWithFormat:@"%c",ch];
            return charactor;
        }
    } else {
        return charactor;
    }
    
    return charactor;
}

/**
 验证字符串是否是邮箱格式
 @return BOOL
 */
- (BOOL)isEmail {
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    
    return [emailTest evaluateWithObject:self];
}

/**
 验证字符串是否是手机号码
 @return BOOL
 */
- (BOOL)isMobile {
    NSString *mobilePredicate = @"^1(3[0-9]|4[57]|5[0-35-9]|7[0135678]|8[0-9])\\d{8}$";
    NSPredicate *mobile = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", mobilePredicate];
    
    return [mobile evaluateWithObject:self];
}

/**
 验证是字符串是否是URL格式
 @return BOOL
 */
- (BOOL)isURL {
    NSString *regex = @"^(http://|https://)?((?:[A-Za-z0-9]+-[A-Za-z0-9]+|[A-Za-z0-9]+)\\.)+([A-Za-z]+)[/\?\\:]?.*$";
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    
    return [predicate evaluateWithObject:self];
}

#pragma mark - MD5加密
/**
 md5加密方法
 @return 加密过的字符串
 */
- (NSString *)md5Encrypt {
    const char *cStr = [self UTF8String];
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    CC_MD5( cStr, (unsigned int)strlen(cStr), digest ); // This is the md5 call
    
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", digest[i]];
    
    return output;
}

#pragma mark -计算文字高度
/**
 根据尺寸求文字高低
 @param maxSize 最大尺寸(限高/限宽)
 @param font 字体
 @return 尺寸
 */
- (CGSize)sizeWithMaxSize:(CGSize)maxSize andFont:(UIFont *)font {
    return [self boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : font} context:nil].size;
}

/**
 匹配字符串中得链接  并返回链接字符串数组
 @return 返回一个标准url格式的数组
 */
- (NSArray *)matchLinks {
    //匹配链接
    NSError *error;
    NSString *regulaStr = @"(http|ftp|https)://[\\w\\-_]+(\\.[\\w\\-_]+)+([\\w\\-\\.,@?^=%&amp;:/~+#]*[\\w\\-\\@?^=%&amp;/~\\+#])?";
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regulaStr
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:&error];
    NSArray *arrayOfAllMatches = [regex matchesInString:self options:0 range:NSMakeRange(0, [self length])];
    
    //存放匹配到的 链接字符串
    NSMutableArray *urls = [NSMutableArray array];
    for (NSTextCheckingResult *match in arrayOfAllMatches) {
        NSString* substringForMatch = [self substringWithRange:match.range];
        [urls addObject:substringForMatch];
    }
    
    return urls;
}

/**
 *  格式化时间字符串
 *
 *  @return 间隔
 */
- (NSString *)formatterDateString; {
    if (!self) {
        return @"刚刚";
    }
    
    //格式化 时间
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setTimeZone:[NSTimeZone localTimeZone]];
    [formatter setDateFormat : @"YYYY-MM-dd HH:mm:ss SSS"];
    NSDate *date = [formatter dateFromString: self];
    
    if (!date) {
        return @"刚刚";
    }
    
    //创建时间
    NSDateComponents *dateComponents = [[NSCalendar currentCalendar] componentsInTimeZone:[NSTimeZone localTimeZone] fromDate:date];
    //当前时间
    NSDateComponents *currentComponents = [[NSCalendar currentCalendar] componentsInTimeZone:[NSTimeZone localTimeZone] fromDate:[NSDate new]];
    
    //判断年是否相同
    if (dateComponents.year != currentComponents.year) {
        [formatter setDateFormat : @"YY-MM-dd HH:mm"];
        return [formatter stringFromDate:date];
    }
    
    //判断月是否相同
    if (dateComponents.month != currentComponents.month) {
        [formatter setDateFormat : @"MM-dd HH:mm"];
        return [formatter stringFromDate:date];
    }
    
    //判断日是否相同
    if (dateComponents.day != currentComponents.day) {
        return [NSString stringWithFormat:@"%ld天前",(long)currentComponents.day-dateComponents.day];
    }
    
    //判断时是否相同
    if (dateComponents.hour != currentComponents.hour) {
        return [NSString stringWithFormat:@"%ld小时前",(long)currentComponents.hour-dateComponents.hour];
    }
    
    //判断分是否相同
    if (dateComponents.minute != currentComponents.minute) {
        return [NSString stringWithFormat:@"%ld分钟前",(long)currentComponents.minute-dateComponents.minute];
    }
    return @"刚刚";
}

#pragma mark - 身份证号码验证
/**
 验证生份证号码是否符合规则
 @return yes or no
 */
- (BOOL)judgeIdentityStringValid {
    
    if (self.length != 18) return NO;
    // 正则表达式判断基本 身份证号是否满足格式
    NSString *regex2 = @"^(^[1-9]\\d{7}((0\\d)|(1[0-2]))(([0|1|2]\\d)|3[0-1])\\d{3}$)|(^[1-9]\\d{5}[1-9]\\d{3}((0\\d)|(1[0-2]))(([0|1|2]\\d)|3[0-1])((\\d{4})|\\d{3}[Xx])$)$";
    NSPredicate *identityStringPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regex2];
    //如果通过该验证，说明身份证格式正确，但准确性还需计算
    if(![identityStringPredicate evaluateWithObject:self]) return NO;
    
    //** 开始进行校验 *//
    //将前17位加权因子保存在数组里
    NSArray *idCardWiArray = @[@"7", @"9", @"10", @"5", @"8", @"4", @"2", @"1", @"6", @"3", @"7", @"9", @"10", @"5", @"8", @"4", @"2"];
    //这是除以11后，可能产生的11位余数、验证码，也保存成数组
    NSArray *idCardYArray = @[@"1", @"0", @"10", @"9", @"8", @"7", @"6", @"5", @"4", @"3", @"2"];
    
    //用来保存前17位各自乘以加权因子后的总和
    NSInteger idCardWiSum = 0;
    for ( int i = 0;i < 17;i++ ) {
        NSInteger subStrIndex = [[self substringWithRange:NSMakeRange(i, 1)] integerValue];
        NSInteger idCardWiIndex = [[idCardWiArray objectAtIndex:i] integerValue];
        idCardWiSum+= subStrIndex * idCardWiIndex;
    }
    
    //计算出校验码所在数组的位置
    NSInteger idCardMod=idCardWiSum%11;
    //得到最后一位身份证号码
    NSString *idCardLast= [self substringWithRange:NSMakeRange(17, 1)];
    //如果等于2，则说明校验码是10，身份证号码最后一位应该是X
    if (idCardMod == 2) {
        if(![idCardLast isEqualToString:@"X"]||[idCardLast isEqualToString:@"x"]) {
            return NO;
        }
    } else {
        //用计算出的验证码与最后一位身份证号码匹配，如果一致，说明通过，否则是无效的身份证号码
        if (![idCardLast isEqualToString: [idCardYArray objectAtIndex:idCardMod]]) {
            return NO;
        }
    }
    return YES;
}


/**
 时间转换  date转成xx years ago xx months ago
 @param date 一个时间
 @return 字符串
 */
- (NSString *)relativeDateStringForDate:(NSDate *)date {
    NSCalendarUnit units = NSCalendarUnitDay | NSCalendarUnitWeekOfYear |
    NSCalendarUnitMonth | NSCalendarUnitYear;
    
    // if `date` is before "now" (i.e. in the past) then the components will be positive
    NSDateComponents *components = [[NSCalendar currentCalendar] components:units
                                                                   fromDate:date
                                                                     toDate:[NSDate date]
                                                                    options:0];
    
    if (components.year > 0) {
        return [NSString stringWithFormat:@"%ld years ago", (long)components.year];
    } else if (components.month > 0) {
        return [NSString stringWithFormat:@"%ld months ago", (long)components.month];
    } else if (components.weekOfYear > 0) {
        return [NSString stringWithFormat:@"%ld weeks ago", (long)components.weekOfYear];
    } else if (components.day > 0) {
        if (components.day > 1) {
            return [NSString stringWithFormat:@"%ld days ago", (long)components.day];
        } else {
            return @"Yesterday";
        }
    } else {
        return @"Today";
    }
}

@end
