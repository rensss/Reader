//
//  RKLoadingView.m
//  RKReader
//
//  Created by MBP on 2018/9/4.
//  Copyright © 2018年 Rzk. All rights reserved.
//

#import "RKLoadingView.h"

@implementation RKLoadingView {
    MBProgressHUD *hud;
}

- (instancetype)initWithMessage:(NSString *)message {
    self = [[RKLoadingView alloc] init];
    _message = message;
    return self;
}

- (void)showInView:(UIView *)view {
    
    hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.bezelView.color = [UIColor colorWithHexString:@"222222"];
    hud.contentColor = [UIColor whiteColor];
    hud.label.text = self.message;
}

/// 停止显示
- (void)stop {
    [hud hideAnimated:YES];
}


- (void)setMessage:(NSString *)message{
    _message = message;
    hud.label.text = message;
}

@end
