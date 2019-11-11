//
//  UIAlertController+R_Category.m
//  R_category
//
//  Created by rzk on 2017/10/10.
//  Copyright © 2017年 rzk. All rights reserved.
//

#import "UIAlertController+R_Category.h"
#import <objc/runtime.h>

@implementation UIAlertController (R_Category)
/**
 根据otherActionTitles数组创建UIAlertController
 
 @param title title
 @param message message
 @param cancelActionTitle 取消Action标题
 @param otherActionTitles 其他Action标题
 @param handle 点击回调 -1 取消Action点击 0~n 其他Action点击
 @return UIAlertController
 */
+ (instancetype)alertControllerWithTitle:(NSString *)title message:(NSString *)message cancelActionTitle:(NSString *)cancelActionTitle otherActionTitles:(NSArray<NSString *> *)otherActionTitles handle:(void (^)(NSInteger))handle {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleActionSheet];
    
    //如果有取消按钮
    if (cancelActionTitle) {
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:cancelActionTitle style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            if (handle) {
                handle(-1);
            }
        }];
        [alertController addAction:cancelAction];
    }
    
    if (otherActionTitles.count > 0) {
        [otherActionTitles enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            UIAlertAction *otherAction = [UIAlertAction actionWithTitle:obj style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                if (handle) {
                    handle(idx);
                }
            }];
            [alertController addAction:otherAction];
        }];
    }
    
    return alertController;
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    //按钮统一颜色
    if (self.tintColor) {
        for (UIAlertAction *action in self.actions) {
            if (!action.textColor || action.style != UIAlertActionStyleDestructive) {
                action.textColor = self.tintColor;
            }
        }
    }
}

- (UIColor *)tintColor {
    return objc_getAssociatedObject(self, @selector(tintColor));
}

- (void)setTintColor:(UIColor *)tintColor {
    
    objc_setAssociatedObject(self, @selector(tintColor), tintColor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIColor *)titleColor {
    return objc_getAssociatedObject(self, @selector(titleColor));
}

- (void)setTitleColor:(UIColor *)titleColor {
    unsigned int count = 0;
    Ivar *ivars = class_copyIvarList([UIAlertController class], &count);
    for(int i = 0;i < count;i ++){
        Ivar ivar = ivars[i];
        NSString *ivarName = [NSString stringWithCString:ivar_getName(ivar) encoding:NSUTF8StringEncoding];
        // 标题颜色
        if ([ivarName isEqualToString:@"_attributedTitle"] && self.title && titleColor) {
            NSMutableAttributedString *attr = [[NSMutableAttributedString alloc]initWithString:self.title attributes:@{NSForegroundColorAttributeName:titleColor,NSFontAttributeName:[UIFont boldSystemFontOfSize:14.0]}];
            [self setValue:attr forKey:@"attributedTitle"];
        }
    }
    
    free(ivars);
    
    objc_setAssociatedObject(self, @selector(titleColor), titleColor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIColor *)messageColor {
    return objc_getAssociatedObject(self, @selector(messageColor));
}

- (void)setMessageColor:(UIColor *)messageColor {
    unsigned int count = 0;
    Ivar *ivars = class_copyIvarList([UIAlertController class], &count);
    for (int i = 0;i < count;i++ ){
        Ivar ivar = ivars[i];
        NSString *ivarName = [NSString stringWithCString:ivar_getName(ivar) encoding:NSUTF8StringEncoding];
        //描述颜色
        if ([ivarName isEqualToString:@"_attributedMessage"] && self.message && messageColor) {
            NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] initWithString:self.message attributes:@{NSForegroundColorAttributeName:messageColor,NSFontAttributeName:[UIFont systemFontOfSize:14.0]}];
            [self setValue:attr forKey:@"attributedMessage"];
        }
    }
    free(ivars);
    objc_setAssociatedObject(self, @selector(messageColor), messageColor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end

@implementation UIAlertAction (Color)
- (UIColor *)textColor {
    return objc_getAssociatedObject(self, @selector(textColor));
}

//按钮标题的字体颜色
- (void)setTextColor:(UIColor *)textColor {
    if (self.style == UIAlertActionStyleDestructive) {
        return;
    }
    
    unsigned int count = 0;
    Ivar *ivars = class_copyIvarList([UIAlertAction class], &count);
    for (int i = 0;i < count;i++ ){
        
        Ivar ivar = ivars[i];
        NSString *ivarName = [NSString stringWithCString:ivar_getName(ivar) encoding:NSUTF8StringEncoding];
        
        if ([ivarName isEqualToString:@"_titleTextColor"]) {
            [self setValue:textColor forKey:@"titleTextColor"];
        }
    }
    free(ivars);
    objc_setAssociatedObject(self, @selector(textColor), textColor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
