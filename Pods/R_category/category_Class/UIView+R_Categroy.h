//
//  UIView+R_Categroy.h
//  R_category
//
//  Created by rzk on 2017/10/10.
//  Copyright © 2017年 rzk. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 UIView 的扩展
 */
@interface UIView (R_Categroy)

@property (nonatomic, assign) CGFloat x; /**< UIView的x*/
@property (nonatomic, assign) CGFloat y; /**< UIView的y*/
@property (nonatomic, assign) CGFloat maxX; /**< UIView最大的x*/
@property (nonatomic, assign) CGFloat maxY; /**< UIView最大的y*/
@property (nonatomic, assign) CGFloat centerX; /**< UIView中心x*/
@property (nonatomic, assign) CGFloat centerY; /**< UIView中心y*/
@property (nonatomic, assign) CGFloat width; /**< UIView的宽*/
@property (nonatomic, assign) CGFloat height; /**< UIView的高*/
@property (nonatomic, assign) CGSize size; /**< UIView的尺寸*/

/**
 *  当前view的controller
 *
 *  @return UIViewController
 */
- (UIViewController *)viewController;

/**
 旋转
 @param duration 一圈时长
 @param clockwise 是否顺时针
 */
- (void)startRotating:(double)duration withClockwise:(BOOL)clockwise;

/**
 停止旋转
 */
- (void)stopRotating;

@end
