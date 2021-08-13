//
//  RKAlertMessage.h
//  RKReader
//
//  Created by MBP on 2018/9/4.
//  Copyright © 2018年 Rzk. All rights reserved.
//

#import <Foundation/Foundation.h>


#import "MBProgressHUD.h"

#define RKAlertMessageShowInWindow(message) RKAlertMessage *alertMessage = [[RKAlertMessage alloc] initWithMessage:(message)];\
[alertMessage showInView:[[UIApplication sharedApplication].delegate window] dismiss:nil];

#define RKAlertMessageShowInWindowAndDelay(message, delay) RKAlertMessage *alertMessage = [[RKAlertMessage alloc] initWithMessage:(message)];\
[alertMessage showInView:[[UIApplication sharedApplication].delegate window] andDelay:(delay) dismiss:nil];

#define RKAlertMessage(message, view) RKAlertMessage *alertMessage = [[RKAlertMessage alloc] initWithMessage:(message)];\
[alertMessage showInView:(view) dismiss:nil];

#define RKAlertMessageAndDelay(message, view, delay) RKAlertMessage *alertMessage = [[RKAlertMessage alloc] initWithMessage:(message)];\
[alertMessage showInView:(view) andDelay:(delay) dismiss:nil];

#define RKAlertAttributeMessage(message, view) RKAlertMessage *alertMessage = [[RKAlertMessage alloc] initWithAttributeMessage:(message)];\
[alertMessage showInView:(view) dismiss:nil];

#define RKAlertAttributeMessageAndDelay(message, view, delay) RKAlertMessage *alertMessage = [[RKAlertMessage alloc] initWithAttributeMessage:(message)];\
[alertMessage showInView:(view) andDelay:(delay) dismiss:nil];

/// 自定义弹出提醒
@interface RKAlertMessage : NSObject

// 提示信息
@property (copy,nonatomic) NSString *message;

// 富文本提示
@property (nonatomic, strong) NSAttributedString *attributeMsg;

// 初始化信息
- (instancetype)initWithMessage:(NSString *)message;

/// 富文本提示
/// @param msgAttributeStr 富文本
- (instancetype)initWithAttributeMessage:(NSAttributedString *)msgAttributeStr;

/// 根据View显示弹窗 -- 带回调
/// @param view view
/// @param dismiss 消失回调
- (void)showInView:(UIView *)view dismiss:(void(^)(void))dismiss;

/// 根据View显示弹窗 -- 带回调
/// @param view view
/// @param delay 间隔
/// @param dismiss 消失回调
- (void)showInView:(UIView *)view andDelay:(float)delay dismiss:(void (^)(void))dismiss;

@end
