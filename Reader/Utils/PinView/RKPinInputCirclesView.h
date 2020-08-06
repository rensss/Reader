//
//  RKPinInputCirclesView.h
//  Reader
//
//  Created by Rzk on 2020/8/6.
//  Copyright © 2020 Rzk. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^RKPinInputCirclesViewShakeCompletionBlock)(void);

@interface RKPinInputCirclesView : UIView

@property (nonatomic, assign) NSUInteger pinLength; /**< pin码位数*/

- (instancetype)initWithPinLength:(NSUInteger)pinLength NS_DESIGNATED_INITIALIZER;
- (instancetype)initWithFrame:(CGRect)frame __attribute__((unavailable("Use -initWithPinLength: instead")));
- (instancetype)initWithCoder:(NSCoder *)aDecoder __attribute__((unavailable("Use -initWithPinLength: instead")));

- (void)fillCircleAtPosition:(NSUInteger)position;
- (void)unfillCircleAtPosition:(NSUInteger)position;
- (void)unfillAllCircles;
- (void)shakeWithCompletion:(__nullable RKPinInputCirclesViewShakeCompletionBlock)completion;

@end

NS_ASSUME_NONNULL_END
