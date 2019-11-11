//
//  UIButton+R_Category.h
//  R_category
//
//  Created by rzk on 2017/10/10.
//  Copyright © 2017年 rzk. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIButton (R_Category)

/** 点击区域*/
@property (nonatomic, assign) UIEdgeInsets hitTestEdgeInsets;

/**
 *  button垂直上下显示
 */
- (void)setImageAndTitleLabelVertical;

/**
 button 图片在title 右边 间距默认 5
 */
- (void)setImageToRight;

/**
 左图右文
 @param padding 间距
 */
- (void)setImageToRightWithPadding:(CGFloat)padding;

@end
