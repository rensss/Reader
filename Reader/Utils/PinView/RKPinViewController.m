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

#pragma mark - lifeCycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (self.translucentBackground) {
        self.view.backgroundColor = [UIColor clearColor];
        [self addBlurView];
    } else {
        self.view.backgroundColor = self.backgroundColor;
    }
    
    self.pinView = [[RKPinView alloc] initWithDelegate:self];
    self.pinView.promptTitle = @"Enter PIN";
    self.pinView.promptColor = [UIColor blackColor];
    [self.view addSubview:self.pinView];
    [self.pinView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(self.view);
        make.left.right.mas_equalTo(self.view);
    }];
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
    DDLogInfo(@"---- cancelButtonTappedInPinView");
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
//    [self.view insertSubview:self.blurView belowSubview:self.pinView];
    [self.view addSubview:self.blurView];
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
    return [image applyBlurWithRadius:20.0f tintColor:[UIColor colorWithWhite:1.0f alpha:0.25f]
                saturationDeltaFactor:1.8f maskImage:nil];
}

@end
