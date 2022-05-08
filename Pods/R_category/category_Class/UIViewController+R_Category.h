//
//  UIViewController+R_Category.h
//  R_category
//
//  Created by MBP on 2017/11/14.
//  Copyright © 2017年 rzk. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (R_Category)

@property (nonatomic, assign, readonly) CGFloat statusBarHeight; /** 电池条的高度*/

@property (nonatomic, assign, readonly) CGFloat navigationBarHeight; /**< navigationBar的高*/

@property (nonatomic, assign, readonly) CGFloat tabBarHeight; /**< tabBar的高*/

@property (nonatomic, assign, readonly) UIEdgeInsets safeAreaInsets; /**< 安全区域*/

/// 当前最顶部 VC
- (UIViewController *)topMostController;
@end
