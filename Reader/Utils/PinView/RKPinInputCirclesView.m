//
//  RKPinInputCirclesView.m
//  Reader
//
//  Created by Rzk on 2020/8/6.
//  Copyright © 2020 Rzk. All rights reserved.
//

#import "RKPinInputCirclesView.h"
#import "RKPinInputCircleView.h"

@interface RKPinInputCirclesView () <CAAnimationDelegate>

@property (nonatomic, strong) NSMutableArray *circleViews;
@property (nonatomic, readonly, assign) CGFloat circlePadding;

@property (nonatomic, assign) NSUInteger numShakes;
@property (nonatomic, assign) NSInteger shakeDirection;
@property (nonatomic, assign) CGFloat shakeAmplitude;
@property (nonatomic, strong) RKPinInputCirclesViewShakeCompletionBlock shakeCompletionBlock;

@end

@implementation RKPinInputCirclesView

#pragma mark - init
- (nonnull instancetype)initWithPinLength:(NSUInteger)pinLength {
    NSParameterAssert(pinLength > 0);

    self = [super initWithFrame:CGRectZero];
    if (self) {
        _pinLength = pinLength;
        
        _circleViews = [NSMutableArray array];
        NSMutableString *format = [NSMutableString stringWithString:@"H:|"];
        NSMutableDictionary *views = [NSMutableDictionary dictionary];
        
        for (NSUInteger i = 0; i < _pinLength; i++) {
            RKPinInputCircleView *circleView = [[RKPinInputCircleView alloc] init];
            circleView.translatesAutoresizingMaskIntoConstraints = NO;
            [self addSubview:circleView];
            [self addConstraint:[NSLayoutConstraint constraintWithItem:circleView attribute:NSLayoutAttributeTop
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:self attribute:NSLayoutAttributeTop
                                                            multiplier:1.0f constant:0.0f]];
            [_circleViews addObject:circleView];
            NSString *name = [NSString stringWithFormat:@"circle%lu", (unsigned long)i];
            if (i > 0) {
                [format appendString:@"-(padding)-"];
            }
            [format appendFormat:@"[%@]", name];
            views[name] = circleView;
        }
        
        [format appendString:@"|"];
        NSDictionary *metrics = @{ @"padding" : @(self.circlePadding) };
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:format options:0 metrics:metrics views:views]];
    }
    return self;
}

- (nonnull instancetype)initWithFrame:(CGRect)frame {
    return [self initWithPinLength:0];
}

- (nonnull instancetype)initWithCoder:(nonnull NSCoder *)aDecoder {
    return [self initWithPinLength:0];
}

- (CGSize)intrinsicContentSize {
    return CGSizeMake(self.pinLength * [RKPinInputCircleView diameter] + (self.pinLength - 1) * self.circlePadding,
                      [RKPinInputCircleView diameter]);
}

- (CGFloat)circlePadding {
    return 2.0f * [RKPinInputCircleView diameter];
}

- (void)fillCircleAtPosition:(NSUInteger)position {
    NSParameterAssert(position < [self.circleViews count]);
    [self.circleViews[position] setFilled:YES];
}

- (void)unfillCircleAtPosition:(NSUInteger)position {
    NSParameterAssert(position < [self.circleViews count]);
    [self.circleViews[position] setFilled:NO];
}

- (void)unfillAllCircles {
    for (RKPinInputCircleView *view in self.circleViews) {
        view.filled = NO;
    }
}

#pragma mark - func

static const NSUInteger RKTotalNumberOfShakes = 6;
static const CGFloat RKInitialShakeAmplitude = 40.0f;
static NSString * const RKPositionAnimation = @"CirclesViewPosition";

- (void)shakeWithCompletion:(RKPinInputCirclesViewShakeCompletionBlock)completion {
    self.numShakes = 0;
    self.shakeDirection = -1;
    self.shakeAmplitude = RKInitialShakeAmplitude;
    self.shakeCompletionBlock = completion;
    [self performShake];
}

- (void)performShake {
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position"];
    animation.delegate = self;
    [animation setDuration:0.03];
    [animation setRepeatCount:RKTotalNumberOfShakes];
    [animation setAutoreverses:YES];
    [animation setFromValue:[NSValue valueWithCGPoint:
                   CGPointMake([self center].x - RKInitialShakeAmplitude, [self center].y)]];
    [animation setToValue:[NSValue valueWithCGPoint:
                   CGPointMake([self center].x + RKInitialShakeAmplitude, [self center].y)]];
    [[self layer] addAnimation:animation forKey:RKPositionAnimation];
}

#pragma mark - delegate
- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    CAAnimation *animation = [self.layer animationForKey:RKPositionAnimation];
    
    if (anim == animation) {
        if (self.shakeCompletionBlock) {
            self.shakeCompletionBlock();
            self.shakeCompletionBlock = nil;
        }
    }
}

@end
