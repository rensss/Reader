//
//  RKAlertMessage.m
//  RKReader
//
//  Created by MBP on 2018/9/4.
//  Copyright © 2018年 Rzk. All rights reserved.
//

#import "RKAlertMessage.h"

@implementation RKAlertMessage {
    MBProgressHUD *_hud;
}

- (instancetype)initWithMessage:(NSString *)message {
    self = [[RKAlertMessage alloc] init];
    self.message = message;
    return self;
}

- (instancetype)initWithAttributeMessage:(NSAttributedString *)msgAttributeStr;
{
    self = [[RKAlertMessage alloc] init];
    self.attributeMsg = msgAttributeStr;
    return self;
}

- (void)showInView:(UIView *)view dismiss:(void (^)(void))dismiss {
    
    CGFloat delay = 1.5;
    
    if (_message.length > 10) {
        delay = 1.8;
    }
    
    if (_message.length > 15) {
        delay = 2.0;
    }
    
    if (_message.length > 20) {
        delay = 2.2;
    }
    
    [self showInView:view andDelay:delay dismiss:dismiss];
}

- (void)showInView:(UIView *)view andDelay:(float)delay dismiss:(void (^)(void))dismiss {
    if (!view) {
        return;
    }
    
    if (self.attributeMsg && self.attributeMsg.string > 0) {
        _message = self.attributeMsg.string;
    }
    
    if (!self.message && self.message.length <= 0) {
        return;
    }
    
    _hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    _hud.bezelView.color = [UIColor colorWithHexString:@"222222"];
    _hud.contentColor = [UIColor whiteColor];
    _hud.mode = MBProgressHUDModeText;
    _hud.detailsLabel.font = [UIFont systemFontOfSize:18.0f];
    if (self.attributeMsg) {
        _hud.detailsLabel.attributedText = self.attributeMsg;
    }else {
        _hud.detailsLabel.text = self.message;
    }
    
    [_hud hideAnimated:YES afterDelay:delay];
    
    if (dismiss) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            dismiss();
        });
    }
}

@end
