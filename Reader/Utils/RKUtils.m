//
//  RKUtils.m
//  Reader
//
//  Created by Rzk on 2020/6/4.
//  Copyright © 2020 Rzk. All rights reserved.
//

#import "RKUtils.h"

@implementation RKUtils

+ (UIViewController *)topMostController {
    UIViewController*topController = [UIApplication sharedApplication].keyWindow.rootViewController;
    while(topController.presentedViewController) {
        topController = topController.presentedViewController;
    }
    return topController;
}

@end
