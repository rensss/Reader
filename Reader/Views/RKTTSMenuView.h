//
//  RKTTSMenuView.h
//  Reader
//
//  Created by Rzk on 2021/7/15.
//  Copyright © 2021 RK. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class RKTTSMenuView;
@protocol RKTTSMenuViewDelegate <NSObject>

@required
- (void)sliderValueChangeForTTSMenuView:(RKTTSMenuView *)menuView;
- (void)stopButtonClickForTTSMenuView:(RKTTSMenuView *)menuView;

@optional

@end

@interface RKTTSMenuView : UIView

@property (nonatomic, weak) id<RKTTSMenuViewDelegate> delegate; /**<  代理*/

- (instancetype)initWithFrame:(CGRect)frame withSuperview:(UIView *)superView;

/// 显示
- (void)show;

/// 消失
- (void)dismiss;

/// 消失回调
- (void)dismissWithHandler:(void(^)(void))handler;

/// 关闭回调
- (void)closeBlock:(void(^)(void))handler;
@end

NS_ASSUME_NONNULL_END
