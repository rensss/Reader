//
//  RKPinNumButton.m
//  Reader
//
//  Created by Rzk on 2020/8/6.
//  Copyright © 2020 Rzk. All rights reserved.
//

#import "RKPinNumButton.h"
#import "RKPinViewController.h"
#import "RKPinView.h"

@interface RKPinNumButton ()

@property (nonatomic, readwrite, assign) NSUInteger number;
@property (nonatomic, readwrite, copy) NSString *letters;

@property (nonatomic, strong) UILabel *numberLabel;
@property (nonatomic, strong) UILabel *lettersLabel;

@property (nonatomic, strong) UIColor *backgroundColorBackup;

@end


@implementation RKPinNumButton

- (instancetype)initWithNumber:(NSUInteger)number letters:(nullable NSString *)letters {
    self = [super initWithFrame:CGRectZero];
    if (self) {
        _number = number;
        _letters = letters;
        
        self.layer.cornerRadius = [[self class] diameter] / 2.0f;
//        self.layer.borderWidth = 1.0f;
        
        self.backgroundColor = RKShowTintColor;
        
        UIView *contentView = [[UIView alloc] init];
        contentView.userInteractionEnabled = NO;
        [self addSubview:contentView];
        [contentView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.mas_equalTo(self);
        }];
        
        _numberLabel = [[UILabel alloc] init];
        _numberLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)number];
        _numberLabel.textAlignment = NSTextAlignmentCenter;
        _numberLabel.font = [UIFont systemFontOfSize:36.0f];
        [contentView addSubview:_numberLabel];
        
        if (_letters) {
            
            CGFloat numberLabelYCorrection = -3.5f;
            CGFloat lettersLabelYCorrection = -4.0f;
            
            [_numberLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(contentView);
                make.left.right.mas_equalTo(contentView);
            }];
            
            _lettersLabel = [[UILabel alloc] init];
            _lettersLabel.text = _letters;
            _lettersLabel.textAlignment = NSTextAlignmentCenter;
            _lettersLabel.font = [UIFont systemFontOfSize:9.0f];
            [contentView addSubview:_lettersLabel];
            
            [_lettersLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerX.mas_equalTo(_numberLabel);
                make.top.mas_equalTo(_numberLabel.mas_bottom).mas_offset(numberLabelYCorrection);
                make.bottom.mas_equalTo(contentView.mas_bottom).mas_offset(lettersLabelYCorrection);
            }];
        } else {
            [_numberLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.left.bottom.right.mas_equalTo(contentView);
            }];
        }
        
        [self tintColorDidChange];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    return [self initWithNumber:0 letters:@""];
}

- (instancetype)initWithFrame:(CGRect)frame {
    return [self initWithNumber:0 letters:@""];
}

#pragma mark - func
- (void)tintColorDidChange {
    self.numberLabel.textColor = [UIColor whiteColor];
    self.lettersLabel.textColor = [UIColor whiteColor];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    
    self.backgroundColorBackup = self.backgroundColor;
    self.backgroundColor = RKShowHeilightTintColor;
    self.backgroundColorBackup = ([self.backgroundColorBackup isEqual:[UIColor clearColor]] ?
                                  [self.class averageContentColor] : self.backgroundColorBackup);
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
    
    [self resetHighlight];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesCancelled:touches withEvent:event];
    [self resetHighlight];
}

- (void)resetHighlight {
    [UIView animateWithDuration:0.3f
                          delay:0.0f
                        options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionAllowUserInteraction
                     animations:^{
                         self.backgroundColor = self.backgroundColorBackup;
                     } completion:^(BOOL finished) {
                         [self tintColorDidChange];
                     }];
}

- (CGSize)intrinsicContentSize {
    return CGSizeMake([[self class] diameter], [[self class] diameter]);
}

#pragma mark - class func
+ (CGFloat)diameter {
    return 75.0f;
}

+ (UIColor *)averageContentColor {
    static UIColor *averageContentColor = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        UIView *contentView = [[UIApplication sharedApplication].keyWindow viewWithTag:RKPinViewControllerContentViewTag];
        if (! contentView) {
            return;
        }
        CGSize size = CGSizeMake(1.0f, 1.0f);
        UIGraphicsBeginImageContext(size);
        CGContextRef ctx = UIGraphicsGetCurrentContext();
        CGContextSetInterpolationQuality(ctx, kCGInterpolationMedium);
        [contentView drawViewHierarchyInRect:(CGRect){ .size = size } afterScreenUpdates:NO];
        uint8_t *data = CGBitmapContextGetData(ctx);
        averageContentColor = [UIColor colorWithRed:data[2] / 255.0f
                                               green:data[1] / 255.0f
                                                blue:data[0] / 255.0f
                                               alpha:1.0f];
        UIGraphicsEndImageContext();
    });
    return averageContentColor;
}

@end
