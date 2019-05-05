//
//  RKUserConfig.m
//  Reader
//
//  Created by Rzk on 2019/4/30.
//  Copyright © 2019 Rzk. All rights reserved.
//

#import "RKUserConfig.h"

@implementation RKUserConfig

@synthesize transitionStyle = _transitionStyle;
@synthesize navigationOrientation = _navigationOrientation;

@synthesize topPadding = _topPadding;
@synthesize leftPadding = _leftPadding;
@synthesize bottomPadding = _bottomPadding;
@synthesize rightPadding = _rightPadding;

@synthesize bgImageName = _bgImageName;

@synthesize fontSize = _fontSize;
@synthesize lineSpace = _lineSpace;
@synthesize fontColor = _fontColor;

#pragma mark - lifeCycle
+ (instancetype)sharedInstance
{
    static id sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

#pragma mark - setting
- (void)setTransitionStyle:(UIPageViewControllerTransitionStyle)transitionStyle {
    _transitionStyle = transitionStyle;
    
    [[NSUserDefaults standardUserDefaults] setInteger:transitionStyle forKey:@"transitionStyle"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)setNavigationOrientation:(UIPageViewControllerNavigationOrientation)navigationOrientation {
    _navigationOrientation = navigationOrientation;
    
    [[NSUserDefaults standardUserDefaults] setInteger:navigationOrientation forKey:@"navigationOrientation"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)setTopPadding:(CGFloat)topPadding {
    _topPadding = topPadding;
    
    [[NSUserDefaults standardUserDefaults] setFloat:topPadding forKey:@"topPadding"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)setLeftPadding:(CGFloat)leftPadding {
    _leftPadding = leftPadding;
    
    [[NSUserDefaults standardUserDefaults] setFloat:leftPadding forKey:@"leftPadding"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)setBottomPadding:(CGFloat)bottomPadding {
    _bottomPadding = bottomPadding;
    
    [[NSUserDefaults standardUserDefaults] setFloat:bottomPadding forKey:@"bottomPadding"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)setRightPadding:(CGFloat)rightPadding {
    _rightPadding = rightPadding;
    
    [[NSUserDefaults standardUserDefaults] setFloat:rightPadding forKey:@"rightPadding"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)setBgImageName:(NSString *)bgImageName {
    _bgImageName = bgImageName;
    
    [[NSUserDefaults standardUserDefaults] setObject:bgImageName forKey:@"bgImageName"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)setFontSize:(CGFloat)fontSize {
    _fontSize = fontSize;
    
    [[NSUserDefaults standardUserDefaults] setFloat:fontSize forKey:@"fontSize"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)setFontColor:(NSString *)fontColor {
    _fontColor = fontColor;
    
    [[NSUserDefaults standardUserDefaults] setObject:fontColor forKey:@"fontColor"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - getting
- (UIPageViewControllerTransitionStyle)transitionStyle {
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"transitionStyle"]) {
        return [[NSUserDefaults standardUserDefaults] integerForKey:@"transitionStyle"];
    } else {
        return UIPageViewControllerTransitionStylePageCurl;
    }
}

- (UIPageViewControllerNavigationOrientation)navigationOrientation {
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"navigationOrientation"]) {
        return [[NSUserDefaults standardUserDefaults] integerForKey:@"navigationOrientation"];
    } else {
        return UIPageViewControllerNavigationOrientationHorizontal;
    }
}

- (CGFloat)topPadding {
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"topPadding"]) {
        return [[NSUserDefaults standardUserDefaults] floatForKey:@"topPadding"];
    } else {
        return kStatusHight + 20;
    }
}

- (CGFloat)leftPadding {
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"leftPadding"]) {
        return [[NSUserDefaults standardUserDefaults] floatForKey:@"leftPadding"];
    } else {
        return 20;
    }
}

- (CGFloat)bottomPadding {
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"bottomPadding"]) {
        return [[NSUserDefaults standardUserDefaults] floatForKey:@"bottomPadding"];
    } else {
        return 20;
    }
}

- (CGFloat)rightPadding {
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"rightPadding"]) {
        return [[NSUserDefaults standardUserDefaults] floatForKey:@"rightPadding"];
    } else {
        return 20;
    }
}

- (CGRect)readViewFrame {
    CGRect rect = [UIApplication sharedApplication].keyWindow.bounds;
    rect.origin.y = self.topPadding;
    rect.origin.x = self.leftPadding;
    rect.size.width = rect.size.width - self.leftPadding - self.rightPadding;
    rect.size.height = rect.size.height - self.topPadding - self.bottomPadding - kSafeAreaBottom;
    return rect;
}

- (NSString *)bgImageName {
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"bgImageName"]) {
        return [[NSUserDefaults standardUserDefaults] stringForKey:@"bgImageName"];
    } else {
        return @"reader_bg_3";
    }
}

- (CGFloat)fontSize {
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"fontSize"]) {
        return [[NSUserDefaults standardUserDefaults] floatForKey:@"fontSize"];
    } else {
        return 20.0f;
    }
}

- (CGFloat)lineSpace {
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"lineSpace"]) {
        return [[NSUserDefaults standardUserDefaults] floatForKey:@"lineSpace"];
    } else {
        return 10.0f;
    }
}

- (NSString *)fontColor {
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"fontColor"]) {
        return [[NSUserDefaults standardUserDefaults] stringForKey:@"fontColor"];
    } else {
        return @"000000";
    }
}

@end
