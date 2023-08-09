//
//  RKPinViewController.h
//  Reader
//
//  Created by Rzk on 2020/8/6.
//  Copyright © 2020 Rzk. All rights reserved.
//

#import <UIKit/UIKit.h>

// when using translucentBackground assign this tag to the view that should be blurred
static const NSInteger RKPinViewControllerContentViewTag = 23333;

NS_ASSUME_NONNULL_BEGIN

@class RKPinViewController;
@protocol RKPinViewControllerDelegate <NSObject>

@required
- (NSUInteger)pinLengthForPinViewController:(RKPinViewController *)pinViewController;
- (BOOL)pinViewController:(RKPinViewController *)pinViewController isPinValid:(NSString *)pin;
- (BOOL)userCanRetryInPinViewController:(RKPinViewController *)pinViewController;

@optional
- (void)cancelButtonTappedInpinViewController:(RKPinViewController *)pinViewController;
- (void)incorrectPinEnteredInPinViewController:(RKPinViewController *)pinViewController;
- (void)pinViewControllerWillDismissAfterPinEntryWasSuccessful:(RKPinViewController *)pinViewController;
- (void)pinViewControllerDidDismissAfterPinEntryWasSuccessful:(RKPinViewController *)pinViewController;
- (void)pinViewControllerWillDismissAfterPinEntryWasUnsuccessful:(RKPinViewController *)pinViewController;
- (void)pinViewControllerDidDismissAfterPinEntryWasUnsuccessful:(RKPinViewController *)pinViewController;
- (void)pinViewControllerWillDismissAfterPinEntryWasCancelled:(RKPinViewController *)pinViewController;
- (void)pinViewControllerDidDismissAfterPinEntryWasCancelled:(RKPinViewController *)pinViewController;

@end

@interface RKPinViewController : UIViewController

@property (nonatomic, weak, nullable) id<RKPinViewControllerDelegate> delegate;
@property (nonatomic, strong, nullable) UIColor *backgroundColor;   /**< 背景色 仅当translucentBackground = no时生效*/
@property (nonatomic, assign) BOOL translucentBackground;           /**< 是否透明背景*/
@property (nonatomic, copy, nullable) NSString *promptTitle;        /**< title*/
@property (nonatomic, strong, nullable) UIColor *promptColor;       /**< title的颜色*/
@property (nonatomic, assign) BOOL hideLetters;                     /**< 是否隐藏按钮上的字母*/
@property (nonatomic, assign) BOOL disableCancel;                   /**< 是否显示取消按钮*/
@property (nonatomic, assign) BOOL disableAuthentication;           /**< 是否开启生物认证*/
@property (nonatomic, assign) BOOL disableAutoAuthentication;       /**< 是否自动校验生物认证*/
@property (nonatomic, assign) BOOL disableDismissAniamtion;         /**< 是否取消动画*/
@property (nonatomic, copy) NSString *sourceString;                 /**< 来源 */

- (instancetype)initWithDelegate:(nullable id<RKPinViewControllerDelegate>)delegate NS_DESIGNATED_INITIALIZER;

/// VC DidDisappear
/// - Parameter handler: 回调
- (void)pinVCDidDisappear:(void(^)(void))handler;

@end

NS_ASSUME_NONNULL_END
