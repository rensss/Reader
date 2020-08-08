//
//  RKTouchFaceIDUtil.h
//  Reader
//
//  Created by Rzk on 2020/6/4.
//  Copyright © 2020 Rzk. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface RKTouchFaceIDUtil : NSObject

+ (BOOL)canUseTouchID;
+ (BOOL)canUseFaceID;

/// 验证权限
/// @param canUse 验证时是否可用密码
/// @param localizedReason 验证界面显示理由
/// @param back 回调
+ (void)requestAuthenticationEvaluatePolicy:(BOOL)canUse
                            localizedReason:(NSString *)localizedReason
                                     result:(void (^)(BOOL success))back;

@end

NS_ASSUME_NONNULL_END
