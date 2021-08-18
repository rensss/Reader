//
//  RKTTSMenuView.m
//  Reader
//
//  Created by Rzk on 2021/7/15.
//  Copyright © 2021 RK. All rights reserved.
//

#import "RKTTSMenuView.h"

#define kSliderTag 5000
#define kSliderHeight 30
#define kSliderPadding 20

@interface RKTTSMenuView ()

@property (nonatomic, strong) UIButton *bgButton; /**< 大Button*/
@property (nonatomic, strong) UIView *bottomView; /**< 底部 view*/

@property (nonatomic, strong) UISlider *pitchMultiplierSlider; /**< 语调*/
@property (nonatomic, strong) UISlider *rateSlider; /**< 语速*/
@property (nonatomic, strong) UISlider *volumeSlider; /**< 音量*/

@property (nonatomic, strong) UIButton *stopBtn; /**< 停止 按钮*/

@property (nonatomic, copy) void(^dismissBlock)(void); /**< 消失回调*/
@property (nonatomic, copy) void(^closeBlock)(void); /**< 关闭回调*/

@end

@implementation RKTTSMenuView

- (instancetype)initWithFrame:(CGRect)frame withSuperview:(UIView *)superView {
    self = [super initWithFrame:frame];
    if (self) {
        [superView addSubview:self];
        [self initUI];
    }
    return self;
}

#pragma mark - func
- (void)initUI {
    UIButton *bgButton = [UIButton new];
    self.bgButton = bgButton;
    [self addSubview:bgButton];
    [bgButton addTarget:self action:@selector(bgClick) forControlEvents:UIControlEventTouchUpInside];
    [bgButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self).insets(UIEdgeInsetsZero);
    }];
    
    // 底部view
    UIView *bottomView = [UIView new];
    self.bottomView = bottomView;
    [self addSubview:bottomView];
    bottomView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.8f];
    CGFloat height = kSafeAreaBottom + kBottomViewHeight;
    [bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(bgButton.mas_bottom);
        make.left.right.mas_equalTo(bgButton);
        make.height.mas_equalTo(height);
    }];
    
    [bottomView addSubview:self.pitchMultiplierSlider];
    [bottomView addSubview:self.volumeSlider];
    [bottomView addSubview:self.rateSlider];
    
    UILabel *pitch = [[UILabel alloc] init];
    [bottomView addSubview:pitch];
    pitch.text = @"语调:";
    pitch.textColor = [UIColor whiteColor];
    pitch.font = [UIFont systemFontOfSize:16];
    
    UILabel *volume = [[UILabel alloc] init];
    [bottomView addSubview:volume];
    volume.text = @"音量:";
    volume.textColor = [UIColor whiteColor];
    volume.font = [UIFont systemFontOfSize:16];
    
    UILabel *rate = [[UILabel alloc] init];
    [bottomView addSubview:rate];
    rate.text = @"语速:";
    rate.textColor = [UIColor whiteColor];
    rate.font = [UIFont systemFontOfSize:16];
    
    [self.pitchMultiplierSlider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(bottomView).mas_offset(-(kSafeAreaBottom+kSliderPadding));
        make.height.mas_equalTo(kSliderHeight);
        make.left.mas_equalTo(pitch.mas_right).mas_offset(20);
        make.right.mas_equalTo(bottomView).mas_offset(-(30+kViewSafeAreaInsets.right));
    }];
    
    [self.volumeSlider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(volume.mas_right).mas_offset(20);
        make.width.mas_equalTo(self.pitchMultiplierSlider);
        make.height.mas_equalTo(kSliderHeight);
        make.bottom.mas_equalTo(self.pitchMultiplierSlider.mas_top).mas_offset(-kSliderPadding);
    }];
    
    [self.rateSlider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(rate.mas_right).mas_offset(20);
        make.height.mas_equalTo(kSliderHeight);
        make.width.mas_equalTo(self.pitchMultiplierSlider);
        make.bottom.mas_equalTo(self.volumeSlider.mas_top).mas_offset(-kSliderPadding);
    }];
    
    [pitch mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_offset(kViewSafeAreaInsets.left + 30);
        make.centerY.mas_equalTo(self.pitchMultiplierSlider.mas_centerY);
    }];
    
    [volume mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_offset(kViewSafeAreaInsets.left + 30);
        make.centerY.mas_equalTo(self.volumeSlider.mas_centerY);
    }];
    
    [rate mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_offset(kViewSafeAreaInsets.left + 30);
        make.centerY.mas_equalTo(self.rateSlider.mas_centerY);
    }];
    
    [self layoutIfNeeded];
}

/// 显示
- (void)show {
    [UIView animateWithDuration:0.25f animations:^{
        CGFloat height = kSafeAreaBottom + kBottomViewHeight ;
        [self.bottomView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(self.bgButton.mas_bottom);
            make.left.right.mas_equalTo(self.bgButton);
            make.height.mas_equalTo(height);
        }];
        // 注意需要再执行一次更新约束
        [self layoutIfNeeded];
    }];
}

/// 消失
- (void)dismiss {
    [UIView animateWithDuration:0.25f animations:^{
        CGFloat height = kSafeAreaBottom + kBottomViewHeight;
        [self.bottomView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.bgButton.mas_bottom);
            make.left.right.mas_equalTo(self.bgButton);
            make.height.mas_equalTo(height);
        }];
        // 注意需要再执行一次更新约束
        [self layoutIfNeeded];
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
        if (self.dismissBlock) {
            self.dismissBlock();
        }
    }];
}

/// 消失回调
- (void)dismissWithHandler:(void(^)(void))handler {
    self.dismissBlock = handler;
}

/// 关闭回调
- (void)closeBlock:(void(^)(void))handler {
    self.closeBlock = handler;
}

#pragma mark - 点击事件
/// 消失
-  (void)bgClick {
    [self dismiss];
}

- (void)sliderValueChange:(UISlider *)slider {
    DDLogInfo(@"---- slider%ld  value %f", slider.tag, slider.value);
    switch (slider.tag - kSliderTag) {
        case 0:
            RKUserConfig.sharedInstance.pitchMultiplier = slider.value;
            break;
        case 1:
            RKUserConfig.sharedInstance.rate = slider.value;
            break;
        case 2:
            RKUserConfig.sharedInstance.volume = slider.value;
            break;
            
        default:
            break;
    }
    
    if ([self.delegate respondsToSelector:@selector(sliderValueChangeForTTSMenuView:)]) {
        [self.delegate sliderValueChangeForTTSMenuView:self];
    }
}

- (void)stopClick:(UIButton *)btn {
    
}

#pragma mark - lazy Init
- (UIButton *)stopBtn {
    if (!_stopBtn) {
        _stopBtn = [[UIButton alloc] init];
        [_stopBtn setImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
        
        [_stopBtn addTarget:self action:@selector(stopClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _stopBtn;
}

- (UISlider *)pitchMultiplierSlider {
    if (!_pitchMultiplierSlider) {
        _pitchMultiplierSlider = [[UISlider alloc] init];
        _pitchMultiplierSlider.tag = kSliderTag;
        _pitchMultiplierSlider.maximumValue = 1.0;
        _pitchMultiplierSlider.minimumValue = 0.0;
        _pitchMultiplierSlider.value = RKUserConfig.sharedInstance.pitchMultiplier;
        _pitchMultiplierSlider.minimumTrackTintColor = [UIColor whiteColor];      // 滑轮左边颜色，如果设置了左边的图片就不会显示
        _pitchMultiplierSlider.maximumTrackTintColor = [UIColor blackColor];      // 滑轮右边颜色，如果设置了右边的图片就不会显示
        _pitchMultiplierSlider.thumbTintColor = [UIColor whiteColor];             // 设置了滑轮的颜色，如果设置了滑轮的样式图片就不会显示
        
        [_pitchMultiplierSlider setContinuous:NO];
        [_pitchMultiplierSlider addTarget:self action:@selector(sliderValueChange:) forControlEvents:UIControlEventValueChanged];
    }
    return _pitchMultiplierSlider;
}

- (UISlider *)rateSlider {
    if (!_rateSlider) {
        _rateSlider = [[UISlider alloc] init];
        _rateSlider.tag = kSliderTag + 1;
        _rateSlider.maximumValue = 1.0;
        _rateSlider.minimumValue = 0.0;
        _rateSlider.value = RKUserConfig.sharedInstance.rate;
        _rateSlider.minimumTrackTintColor = [UIColor whiteColor];      // 滑轮左边颜色，如果设置了左边的图片就不会显示
        _rateSlider.maximumTrackTintColor = [UIColor blackColor];      // 滑轮右边颜色，如果设置了右边的图片就不会显示
        _rateSlider.thumbTintColor = [UIColor whiteColor];             // 设置了滑轮的颜色，如果设置了滑轮的样式图片就不会显示
        
        [_rateSlider setContinuous:NO];
        [_rateSlider addTarget:self action:@selector(sliderValueChange:) forControlEvents:UIControlEventValueChanged];
    }
    return _rateSlider;
}

- (UISlider *)volumeSlider {
    if (!_volumeSlider) {
        _volumeSlider = [[UISlider alloc] init];
        _volumeSlider.tag = kSliderTag + 2;
        _volumeSlider.maximumValue = 1.0;
        _volumeSlider.minimumValue = 0.0;
        _volumeSlider.value = RKUserConfig.sharedInstance.volume;
        _volumeSlider.minimumTrackTintColor = [UIColor whiteColor];      // 滑轮左边颜色，如果设置了左边的图片就不会显示
        _volumeSlider.maximumTrackTintColor = [UIColor blackColor];      // 滑轮右边颜色，如果设置了右边的图片就不会显示
        _volumeSlider.thumbTintColor = [UIColor whiteColor];             // 设置了滑轮的颜色，如果设置了滑轮的样式图片就不会显示
        
        [_volumeSlider setContinuous:NO];
        [_volumeSlider addTarget:self action:@selector(sliderValueChange:) forControlEvents:UIControlEventValueChanged];
    }
    return _volumeSlider;
}

@end
