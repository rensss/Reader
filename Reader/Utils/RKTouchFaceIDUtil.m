//
//  RKTouchFaceIDUtil.m
//  Reader
//
//  Created by Rzk on 2020/6/4.
//  Copyright © 2020 Rzk. All rights reserved.
//

#import "RKTouchFaceIDUtil.h"
#import <LocalAuthentication/LocalAuthentication.h>

@implementation RKTouchFaceIDUtil

+ (BOOL)canUseTouchID {
    LAContext *context = [[LAContext alloc] init];
    if ([context canEvaluatePolicy:LAPolicyDeviceOwnerAuthentication error:nil]) {
        if(@available(iOS 11.0, *)) {
            return context.biometryType == LABiometryTypeTouchID;
        }
        return YES;
    }
    return NO;
}


+ (BOOL)canUseFaceID {
    LAContext *context = [[LAContext alloc] init];
    if ([context canEvaluatePolicy:LAPolicyDeviceOwnerAuthentication error:nil]) {
        if(@available(iOS 11.0, *)) {
            return context.biometryType == LABiometryTypeFaceID;
        }
    }
    return NO;
}


/// 验证权限
/// @param canUse 验证时是否可用密码
/// @param localizedReason 验证界面显示理由
/// @param back 回调
+ (void)requestAuthenticationEvaluatePolicy:(BOOL)canUse
                            localizedReason:(NSString *)localizedReason
                                     result:(void (^)(BOOL success))back {
    LAContext *context = [[LAContext alloc] init];
    LAPolicy policyType;
    if (canUse) {
        policyType = LAPolicyDeviceOwnerAuthentication;
    } else {
        policyType = LAPolicyDeviceOwnerAuthenticationWithBiometrics;
    }
    if ([context canEvaluatePolicy:policyType error:nil]) {
        [context evaluatePolicy:policyType localizedReason:localizedReason reply:^(BOOL success, NSError * _Nullable error) {
            RKLog(@"---- %d, %@", success, error);
            if (back) {
                back(success);
            }
        }];
    }
}

@end
