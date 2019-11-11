//
//  UILabel+R_Category.m
//  R_category
//
//  Created by rzk on 2017/10/10.
//  Copyright © 2017年 rzk. All rights reserved.
//

#import "UILabel+R_Category.h"
#import <objc/runtime.h>

static void *imgStringKey = &imgStringKey;

@implementation UILabel (R_Category)

- (NSString *)imgString {
    return objc_getAssociatedObject(self, &imgStringKey);
}

- (void)setImgString:(NSString *)imgString {
    [self setAttributedWithImgString:imgString];
    objc_setAssociatedObject(self, &imgStringKey, imgString, OBJC_ASSOCIATION_COPY);
}


/**
 使用特定字符添加图片
 @param str 包含"{}"的字符串
 */
- (void)setAttributedWithImgString:(NSString *)str {
    
    NSRegularExpression *regx = [[NSRegularExpression alloc] initWithPattern:@"\\{[^}]+\\}" options:NSRegularExpressionCaseInsensitive error:nil];
    NSArray *matchs = [regx matchesInString:str options:NSMatchingReportCompletion range:NSMakeRange(0, str.length)];
    
    // 富文本
    NSMutableAttributedString *atrributeString = [[NSMutableAttributedString alloc] initWithString:str];
    
    // 倒序替换range
    for (NSInteger i = [matchs count] - 1; i >= 0; i--) {
        NSTextCheckingResult *match = matchs[i];
        
        // 大括号所在的位置
        NSRange range = [match range];
        // 替换大括号
        [atrributeString replaceCharactersInRange:NSMakeRange(range.location, 1) withString:@" "];
        
        [atrributeString replaceCharactersInRange:NSMakeRange(range.location + range.length - 1, 1) withString:@" "];
        
        // 创建图片Attachment
        NSTextAttachment *attachment = [[NSTextAttachment alloc] init];
        NSString *imageName = [str substringWithRange:NSMakeRange(range.location + 1, range.length - 2)];
        attachment.image = [UIImage imageNamed:imageName];
        attachment.bounds = CGRectMake(0, 0, self.font.lineHeight, self.font.lineHeight);
        
        // 添加图片Attachment
        NSAttributedString *text = [NSAttributedString attributedStringWithAttachment:attachment];
        [atrributeString replaceCharactersInRange:range withAttributedString:text];
    }
    
    self.attributedText = atrributeString;
}

@end
