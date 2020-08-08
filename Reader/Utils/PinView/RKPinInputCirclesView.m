//
//  RKPinInputCirclesView.m
//  Reader
//
//  Created by Rzk on 2020/8/6.
//  Copyright © 2020 Rzk. All rights reserved.
//

#import "RKPinInputCirclesView.h"
#import "RKPinInputCircleView.h"
#import "RKPinView.h"

@interface RKPinInputCirclesView () <CAAnimationDelegate>

@property (nonatomic, strong) NSMutableArray *circleViews;

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
        
        for (NSUInteger i = 0; i < _pinLength; i++) {
            RKPinInputCircleView *circleView = [[RKPinInputCircleView alloc] init];
            circleView.tintColor = RKShowTintColor;
            [self addSubview:circleView];
            [circleView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.bottom.mas_equalTo(self);
                make.left.mas_equalTo(self).mas_offset(i*(25+[RKPinInputCircleView diameter]));
                if (i == _pinLength - 1) {
                    make.right.mas_equalTo(self);
                }
            }];
            
            [_circleViews addObject:circleView];
        }
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    return [self initWithPinLength:0];
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    return [self initWithPinLength:0];
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
    [animation setAutoreverses:YES];
    [animation setRemovedOnCompletion:NO];
    [animation setRepeatCount:RKTotalNumberOfShakes];
    [animation setFromValue:[NSValue valueWithCGPoint:
                   CGPointMake([self center].x - RKInitialShakeAmplitude, [self center].y)]];
    [animation setToValue:[NSValue valueWithCGPoint:
                   CGPointMake([self center].x + RKInitialShakeAmplitude, [self center].y)]];
    [[self layer] addAnimation:animation forKey:RKPositionAnimation];
}

#pragma mark - delegate
- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    CAAnimation *animation = [[self layer] animationForKey:RKPositionAnimation];
    
    if ([anim isEqual:animation]) {
        if (self.shakeCompletionBlock) {
            self.shakeCompletionBlock();
            self.shakeCompletionBlock = nil;
        }
    }
}

@end
