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
@property (nonatomic, strong, nullable) UIColor *backgroundColor; // is only used if translucentBackground == NO
@property (nonatomic, assign) BOOL translucentBackground;
@property (nonatomic, copy, nullable) NSString *promptTitle;
@property (nonatomic, strong, nullable) UIColor *promptColor;
@property (nonatomic, assign) BOOL hideLetters; // hides the letters on the number buttons
@property (nonatomic, assign) BOOL disableCancel; // hides the cancel button
@property (nonatomic, assign) BOOL disableDismissAniamtion;

- (instancetype)initWithDelegate:(nullable id<RKPinViewControllerDelegate>)delegate NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
