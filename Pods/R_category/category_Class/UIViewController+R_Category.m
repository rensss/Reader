//
//  UIViewController+R_Category.m
//  R_category
//
//  Created by MBP on 2017/11/14.
//  Copyright © 2017年 rzk. All rights reserved.
//

#import "UIViewController+R_Category.h"

@implementation UIViewController (R_Category)

- (CGFloat)statusBarHeight {
    return [UIApplication sharedApplication].statusBarFrame.size.height;
}

- (CGFloat)navigationBarHeight {
    return self.navigationController.navigationBar.frame.size.height;
}

- (CGFloat)tabBarHeight {
    return self.tabBarController.tabBar.frame.size.height;
}

- (UIEdgeInsets)safeAreaInsets {
    if (@available(iOS 11.0, *)) {
        return [UIApplication sharedApplication].keyWindow.safeAreaInsets;
    } else {
        return UIEdgeInsetsZero;
    }
}

- (UIViewController *)topMostController {
    UIViewController *topController = [UIApplication sharedApplication].windows.firstObject.rootViewController;
    while(topController.presentedViewController) {
        topController = topController.presentedViewController;
    }
    return topController;
}

@end
