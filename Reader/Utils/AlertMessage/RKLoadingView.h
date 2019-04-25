//
//  RKLoadingView.h
//  RKReader
//
//  Created by MBP on 2018/9/4.
//  Copyright © 2018年 Rzk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MBProgressHUD.h"

@interface RKLoadingView : NSObject

@property (nonatomic, strong) NSString *message;

/// 初始化信息
- (instancetype)initWithMessage:(NSString *)message;
/// 显示等待弹窗
- (void)showInView:(UIView *)view;
/// 停止显示
- (void)stop;

@end
