//
//  RKTTSMenuView.m
//  Reader
//
//  Created by Rzk on 2021/7/15.
//  Copyright © 2021 RK. All rights reserved.
//

#import "RKTTSMenuView.h"

#define kSliderTag 5000
#define kSliderHeight 50
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

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
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
    [bgButton addSubview:bottomView];
    bottomView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.8f];
    CGFloat height = kSafeAreaBottom + kBottomViewHeight;
    [bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(bgButton.mas_bottom);
        make.left.right.mas_equalTo(bgButton);
        make.height.mas_equalTo(height);
    }];
    
    [bottomView addSubview:self.rateSlider];
    [self.rateSlider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(bottomView);
        make.bottom.mas_equalTo(bottomView).mas_offset(- kSliderPadding);
        make.height.mas_equalTo(kSliderHeight);
        make.width.mas_equalTo(bottomView.mas_width).mas_offset(-60);
    }];
    
    [bottomView addSubview:self.volumeSlider];
    [self.volumeSlider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(self.rateSlider);
        make.height.mas_equalTo(kSliderHeight);
        make.center.mas_equalTo(bottomView);
        make.bottom.mas_equalTo(self.rateSlider.mas_top).mas_offset(-kSliderPadding);
    }];
    
    [bottomView addSubview:self.pitchMultiplierSlider];
    [self.pitchMultiplierSlider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(kSliderHeight);
        make.width.mas_equalTo(self.rateSlider);
        make.centerX.mas_equalTo(bottomView);
        make.bottom.mas_equalTo(self.volumeSlider.mas_top).mas_offset(-kSliderPadding);
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
    switch (slider.tag - kSliderTag) {
        case 0:
        {
            RKUserConfig.sharedInstance.pitchMultiplier = slider.value;
        }
            break;
        case 1:
        {
            RKUserConfig.sharedInstance.rate = slider.value;
        }
            break;
        case 2:
        {
            RKUserConfig.sharedInstance.volume = slider.value;
        }
            break;
            
        default:
            break;
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
        _pitchMultiplierSlider.backgroundColor = [UIColor colorWithRandom];
        _pitchMultiplierSlider.tag = kSliderTag;
        _pitchMultiplierSlider.minimumTrackTintColor = [UIColor clearColor];
        _pitchMultiplierSlider.maximumTrackTintColor = [UIColor clearColor];
        _pitchMultiplierSlider.maximumValue = 0.5;
        _pitchMultiplierSlider.minimumValue = 2.0;
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
        _rateSlider.backgroundColor = [UIColor colorWithRandom];
        _rateSlider.tag = kSliderTag + 1;
        _rateSlider.minimumTrackTintColor = [UIColor clearColor];
        _rateSlider.maximumTrackTintColor = [UIColor clearColor];
        _rateSlider.maximumValue = AVSpeechUtteranceMinimumSpeechRate;
        _rateSlider.minimumValue = AVSpeechUtteranceMaximumSpeechRate;
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
        _volumeSlider.backgroundColor = [UIColor colorWithRandom];
        _volumeSlider.tag = kSliderTag + 2;
        _volumeSlider.minimumTrackTintColor = [UIColor clearColor];
        _volumeSlider.maximumTrackTintColor = [UIColor clearColor];
        _volumeSlider.maximumValue = 0.0;
        _volumeSlider.minimumValue = 1.0;
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
