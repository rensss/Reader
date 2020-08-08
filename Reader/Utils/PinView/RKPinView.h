//
//  RKPinView.h
//  Reader
//
//  Created by Rzk on 2020/8/6.
//  Copyright © 2020 Rzk. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

#define RKShowTintColor [UIColor colorWithR:168 g:168 b:168 alpha:1]
#define RKShowHeilightTintColor [UIColor colorWithR:198 g:198 b:198 alpha:1]

@class RKPinView;
@protocol RKPinViewDelegate <NSObject>

@required
- (NSUInteger)pinLengthForPinView:(RKPinView *)pinView;
- (BOOL)pinView:(RKPinView *)pinView isPinValid:(NSString *)pin;
- (void)cancelButtonTappedInPinView:(RKPinView *)pinView;
- (void)correctPinWasEnteredInPinView:(RKPinView *)pinView;
- (void)incorrectPinWasEnteredInPinView:(RKPinView *)pinView;

@end

@interface RKPinView : UIView

@property (nonatomic, weak, nullable) id<RKPinViewDelegate> delegate;
@property (nonatomic, copy, nullable) NSString *promptTitle;
@property (nonatomic, strong, nullable) UIColor *promptColor;
@property (nonatomic, assign) BOOL hideLetters;
@property (nonatomic, assign) BOOL disableCancel;

- (instancetype)initWithDelegate:(nullable id<RKPinViewDelegate>)delegate NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
