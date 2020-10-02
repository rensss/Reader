//
//  RKPinViewController.m
//  Reader
//
//  Created by Rzk on 2020/8/6.
//  Copyright © 2020 Rzk. All rights reserved.
//

#import "RKPinViewController.h"
#import "RKPinView.h"
#import "UIImage+ImageEffects.h"

@interface RKPinViewController () <RKPinViewDelegate>


@property (nonatomic, strong) RKPinView *pinView; /**< view*/

@property (nonatomic, strong) UIView *blurView;
@property (nonatomic, strong) NSArray *blurViewContraints;

@end

@implementation RKPinViewController

#pragma mark - init
- (instancetype)initWithDelegate:(id<RKPinViewControllerDelegate>)delegate {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        _delegate = delegate;
        _backgroundColor = [UIColor whiteColor];
        _translucentBackground = NO;
        _promptTitle = @"Enter PIN";
    }
    return self;
}

- (nonnull instancetype)initWithNibName:(nullable NSString *)nibNameOrNil bundle:(nullable NSBundle *)nibBundleOrNil {
    return [self initWithDelegate:nil];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    return [self initWithDelegate:nil];
}

- (void)dealloc {
//    NSLog(@"---> %@ 销毁了",[self class]);
}

#pragma mark - lifeCycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (self.translucentBackground) {
        self.view.backgroundColor = [UIColor clearColor];
        [self addBlurView];
    } else {
        self.view.backgroundColor = self.backgroundColor;
    }
        
    [self.view addSubview:self.pinView];
    [self.pinView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(self.view);
        make.left.right.mas_equalTo(self.view);
    }];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (!self.disableAutoAuthentication) {
        [self.pinView requestBiometricAuth];
    }
}

#pragma mark - 事件
- (void)closeClick {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - delegate
- (NSUInteger)pinLengthForPinView:(RKPinView *)pinView {
    return [self.delegate pinLengthForPinViewController:self];
}

- (BOOL)pinView:(RKPinView *)pinView isPinValid:(NSString *)pin {
    return [self.delegate pinViewController:self isPinValid:pin];
}

- (void)cancelButtonTappedInPinView:(RKPinView *)pinView {
    DDLogVerbose(@"---- cancelButtonTappedInPinView");
    [self closeClick];
}

- (void)correctPinWasEnteredInPinView:(RKPinView *)pinView {
    if ([self.delegate respondsToSelector:@selector(pinViewControllerWillDismissAfterPinEntryWasSuccessful:)]) {
        [self.delegate pinViewControllerWillDismissAfterPinEntryWasSuccessful:self];
    }
    [self dismissViewControllerAnimated:!_disableDismissAniamtion completion:^{
        if ([self.delegate respondsToSelector:@selector(pinViewControllerDidDismissAfterPinEntryWasSuccessful:)]) {
            [self.delegate pinViewControllerDidDismissAfterPinEntryWasSuccessful:self];
        }
    }];
}

- (void)incorrectPinWasEnteredInPinView:(RKPinView *)pinView {
    if ([self.delegate userCanRetryInPinViewController:self]) {
        if ([self.delegate respondsToSelector:@selector(incorrectPinEnteredInPinViewController:)]) {
            [self.delegate incorrectPinEnteredInPinViewController:self];
        }
    } else {
        if ([self.delegate respondsToSelector:@selector(pinViewControllerWillDismissAfterPinEntryWasUnsuccessful:)]) {
            [self.delegate pinViewControllerWillDismissAfterPinEntryWasUnsuccessful:self];
        }
        [self dismissViewControllerAnimated:!_disableDismissAniamtion completion:^{
            if ([self.delegate respondsToSelector:@selector(pinViewControllerDidDismissAfterPinEntryWasUnsuccessful:)]) {
                [self.delegate pinViewControllerDidDismissAfterPinEntryWasUnsuccessful:self];
            }
        }];
    }
}

#pragma mark - Blur
- (void)addBlurView {
    self.blurView = [[UIImageView alloc] initWithImage:[self blurredContentImage]];
    [self.view insertSubview:self.blurView belowSubview:self.pinView];
    [self.blurView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.bottom.right.mas_equalTo(self.view);
    }];
}

- (void)removeBlurView {
    [self.blurView removeFromSuperview];
    self.blurView = nil;
    self.blurViewContraints = nil;
}

- (UIImage*)blurredContentImage {
    UIView *contentView = [[UIApplication sharedApplication].keyWindow viewWithTag:RKPinViewControllerContentViewTag];
    if (!contentView) {
        return nil;
    }
    UIGraphicsBeginImageContext(self.view.bounds.size);
    [contentView drawViewHierarchyInRect:self.view.bounds afterScreenUpdates:NO];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return [image applyBlurWithRadius:20.0f tintColor:[UIColor colorWithWhite:1.0f alpha:0.25f] saturationDeltaFactor:1.8f maskImage:nil];
}

#pragma mark - getting
- (RKPinView *)pinView {
    if (!_pinView) {
        _pinView = [[RKPinView alloc] initWithDelegate:self];
        _pinView.promptTitle = self.promptTitle;
        _pinView.promptColor = self.promptColor;
    }
    return _pinView;
}

#pragma mark - setting
- (void)setBackgroundColor:(UIColor *)backgroundColor {
    if ([self.backgroundColor isEqual:backgroundColor]) return;
    
    _backgroundColor = backgroundColor;
    if (!self.translucentBackground) {
        self.view.backgroundColor = self.backgroundColor;
        self.pinView.backgroundColor = self.backgroundColor;
    }
}

- (void)setTranslucentBackground:(BOOL)translucentBackground {
    if (self.translucentBackground == translucentBackground) return;
    
    _translucentBackground = translucentBackground;
    if (self.translucentBackground) {
        self.view.backgroundColor = [UIColor clearColor];
        self.pinView.backgroundColor = [UIColor clearColor];
        [self addBlurView];
    } else {
        self.view.backgroundColor = self.backgroundColor;
        self.pinView.backgroundColor = self.backgroundColor;
        [self removeBlurView];
    }
}

- (void)setPromptTitle:(NSString *)promptTitle {
    if ([self.promptTitle isEqualToString:promptTitle]) return;
    
    _promptTitle = [promptTitle copy];
    self.pinView.promptTitle = self.promptTitle;
}

- (void)setPromptColor:(UIColor *)promptColor {
    if ([self.promptColor isEqual:promptColor]) return;
    
    _promptColor = promptColor;
    self.pinView.promptColor = self.promptColor;
}

- (void)setHideLetters:(BOOL)hideLetters {
    if (self.hideLetters == hideLetters) return;
    
    _hideLetters = hideLetters;
    self.pinView.hideLetters = self.hideLetters;
}

- (void)setDisableCancel:(BOOL)disableCancel {
    if (self.disableCancel == disableCancel) return;
    
    _disableCancel = disableCancel;
    self.pinView.disableCancel = self.disableCancel;
}

- (void)setDisableAuthentication:(BOOL)disableAuthentication {
    if (self.disableAuthentication == disableAuthentication) return;
    
    _disableAuthentication = disableAuthentication;
    self.pinView.disableAuthentication = disableAuthentication;
}

- (void)setDisableAutoAuthentication:(BOOL)disableAutoAuthentication {
    if (self.disableAutoAuthentication == disableAutoAuthentication) return;
    
    _disableAutoAuthentication = disableAutoAuthentication;
}

@end
