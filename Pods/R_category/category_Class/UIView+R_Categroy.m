//
//  UIView+R_Categroy.m
//  R_category
//
//  Created by rzk on 2017/10/10.
//  Copyright © 2017年 rzk. All rights reserved.
//

#import "UIView+R_Categroy.h"

@implementation UIView (R_Categroy)

- (void)setX:(CGFloat)x {
    CGRect frame = self.frame;
    frame.origin.x = x;
    self.frame = frame;
}

- (CGFloat)x {
    return self.frame.origin.x;
}

- (void)setMaxX:(CGFloat)maxX {
    self.x = maxX - self.width;
}

- (CGFloat)maxX {
    return CGRectGetMaxX(self.frame);
}

- (void)setMaxY:(CGFloat)maxY {
    self.y = maxY - self.height;
}

- (CGFloat)maxY {
    return CGRectGetMaxY(self.frame);
}

- (void)setY:(CGFloat)y {
    CGRect frame = self.frame;
    frame.origin.y = y;
    self.frame = frame;
}

- (CGFloat)y {
    return self.frame.origin.y;
}

- (void)setCenterX:(CGFloat)centerX {
    CGPoint center = self.center;
    center.x = centerX;
    self.center = center;
}

- (CGFloat)centerX {
    return self.center.x;
}

- (void)setCenterY:(CGFloat)centerY {
    CGPoint center = self.center;
    center.y = centerY;
    self.center = center;
}

- (CGFloat)centerY {
    return self.center.y;
}

- (void)setWidth:(CGFloat)width {
    CGRect frame = self.frame;
    frame.size.width = width;
    self.frame = frame;
}

- (CGFloat)width {
    return self.frame.size.width;
}

- (void)setHeight:(CGFloat)height {
    CGRect frame = self.frame;
    frame.size.height = height;
    self.frame = frame;
}

- (CGFloat)height {
    return self.frame.size.height;
}

- (void)setSize:(CGSize)size {
    self.width = size.width;
    self.height = size.height;
    CGRect frame = self.frame;
    frame.size = size;
    self.frame = frame;
}

- (CGSize)size {
    return self.frame.size;
}

- (UIViewController *)viewController {
    
    UIResponder *responder = self;
    while ((responder = [responder nextResponder]))
        if ([responder isKindOfClass:[UIViewController class]])
            return (UIViewController *)responder;
    
    return nil;
}


/**
 旋转
 @param duration 一圈时长
 @param clockwise 是否顺时针
 */
- (void)startRotating:(double)duration withClockwise:(BOOL)clockwise {
    NSString *kRotatingAnimationKey = @"kRotatingAnimationKey";
    
    CGFloat currentState = 0;
    
    CGAffineTransform transform = CATransform3DGetAffineTransform(self.layer.presentationLayer.transform);
    
    currentState = atan2(transform.b, transform.a);
    
    CABasicAnimation *path = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];

    path.repeatCount = MAXFLOAT;
    path.duration = duration;
    path.fromValue = @(currentState);
    path.byValue = @(clockwise ? M_PI*2 : -M_PI*2);
    [self.layer addAnimation:path forKey:kRotatingAnimationKey];
}

/**
 停止旋转
 */
- (void)stopRotating {
    
    NSString *kRotatingAnimationKey = @"kRotatingAnimationKey";
    
    CGFloat currentState = 0;
    
    CGAffineTransform transform = CATransform3DGetAffineTransform(self.layer.presentationLayer.transform);
    
    currentState = atan2(transform.b, transform.a);
    
    if ([self.layer.animationKeys containsObject:kRotatingAnimationKey]) {
        [self.layer removeAnimationForKey:kRotatingAnimationKey];
    }
    
    // Leave self as it was when stopped.
    self.layer.transform = CATransform3DMakeRotation(currentState, 0, 0, 1);
}

@end
