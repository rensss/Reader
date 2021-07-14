//
//  RKUserConfig.m
//  Reader
//
//  Created by Rzk on 2019/4/30.
//  Copyright © 2019 Rzk. All rights reserved.
//

#import "RKUserConfig.h"
#import "AppDelegate.h"

@implementation RKUserConfig

@synthesize transitionStyle = _transitionStyle;
@synthesize navigationOrientation = _navigationOrientation;
@synthesize isAllowRotation = _isAllowRotation;
@synthesize topPadding = _topPadding;
@synthesize leftPadding = _leftPadding;
@synthesize bottomPadding = _bottomPadding;
@synthesize rightPadding = _rightPadding;

@synthesize bgImageName = _bgImageName;

@synthesize fontSize = _fontSize;
@synthesize lineSpace = _lineSpace;
@synthesize fontColor = _fontColor;
@synthesize fontName = _fontName;
@synthesize isAllNextPage = _isAllNextPage;

@synthesize isRefreshTop = _isRefreshTop;
@synthesize nightAlpha = _nightAlpha;

@synthesize isAutoRead = _isAutoRead;

@synthesize lastReadBookName = _lastReadBookName;
@synthesize isSecretAutoOpen = _isSecretAutoOpen;
@synthesize isChapterListAutoScroll = _isChapterListAutoScroll;
@synthesize pinString = _pinString;

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

- (void)setIsAllowRotation:(BOOL)isAllowRotation {
    _isAllowRotation = isAllowRotation;
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate.allowRotation = isAllowRotation;
    [[NSUserDefaults standardUserDefaults] setBool:isAllowRotation forKey:@"isAllowRotation"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)setIsAllNextPage:(BOOL)isAllNextPage {
    _isAllNextPage = isAllNextPage;
    
    [[NSUserDefaults standardUserDefaults] setBool:isAllNextPage forKey:@"isAllNextPage"];
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

- (void)setLineSpace:(CGFloat)lineSpace {
    _lineSpace = lineSpace;
    
    [[NSUserDefaults standardUserDefaults] setFloat:lineSpace forKey:@"lineSpace"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)setFontColor:(NSString *)fontColor {
    _fontColor = fontColor;
    
    [[NSUserDefaults standardUserDefaults] setObject:fontColor forKey:@"fontColor"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)setFontName:(NSString *)fontName {
    _fontName = fontName;
    
    [[NSUserDefaults standardUserDefaults] setObject:fontName forKey:@"fontName"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)setIsRefreshTop:(BOOL)isRefreshTop {
    _isRefreshTop = isRefreshTop;
    
    [[NSUserDefaults standardUserDefaults] setBool:isRefreshTop forKey:@"isRefreshTop"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)setIsAutoRead:(BOOL)isAutoRead {
    _isAutoRead = isAutoRead;
    
    [[NSUserDefaults standardUserDefaults] setBool:isAutoRead forKey:@"isAutoRead"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)setIsSecretAutoOpen:(BOOL)isSecretAutoOpen {
    _isSecretAutoOpen = isSecretAutoOpen;
    
    [[NSUserDefaults standardUserDefaults] setBool:isSecretAutoOpen forKey:@"isSecretAutoOpen"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)setLastReadBookName:(NSString *)lastReadBookName {
    _lastReadBookName = lastReadBookName;
    
    [[NSUserDefaults standardUserDefaults] setObject:lastReadBookName forKey:@"lastReadBookName"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)setNightAlpha:(float)nightAlpha {
    _nightAlpha = nightAlpha;
    
    [[NSUserDefaults standardUserDefaults] setFloat:nightAlpha forKey:@"nightAlpha"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)setIsChapterListAutoScroll:(BOOL)isChapterListAutoScroll {
    _isChapterListAutoScroll = isChapterListAutoScroll;
    
    [[NSUserDefaults standardUserDefaults] setBool:isChapterListAutoScroll forKey:@"isChapterListAutoScroll"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(void)setPinString:(NSString *)pinString {
    _pinString = pinString;
    
    [[NSUserDefaults standardUserDefaults] setObject:pinString forKey:@"pinString"];
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

- (BOOL)isAllNextPage {
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"isAllNextPage"]) {
        return [[NSUserDefaults standardUserDefaults] boolForKey:@"isAllNextPage"];
    } else {
        return YES;
    }
}

- (BOOL)isAllowRotation {
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"isAllowRotation"]) {
        return [[NSUserDefaults standardUserDefaults] boolForKey:@"isAllowRotation"];
    } else {
        return YES;
    }
}

- (CGFloat)topPadding {
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"topPadding"]) {
        return [[NSUserDefaults standardUserDefaults] floatForKey:@"topPadding"];
    } else {
        return 10;
    }
}

- (CGFloat)leftPadding {
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"leftPadding"]) {
        return [[NSUserDefaults standardUserDefaults] floatForKey:@"leftPadding"] + self.currentSafeAreaInsets.left;
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
        return [[NSUserDefaults standardUserDefaults] floatForKey:@"rightPadding"] + self.currentSafeAreaInsets.right;
    } else {
        return 20;
    }
}

- (CGRect)readViewFrame {
    CGRect rect = CGRectMake(self.leftPadding, kStatusHight + self.topPadding, self.currentViewWidth - self.leftPadding - self.rightPadding, self.currentViewHeight - self.topPadding - kStatusHight - self.bottomPadding - (kSafeAreaBottom));
    DDLogDebug(@"---- readViewFrame:%@", NSStringFromCGRect(rect));
    return rect;
}

- (CGRect)readStatusBarFrame {
    CGRect rect = CGRectMake(0, self.currentViewHeight - self.currentSafeAreaInsets.bottom - (kIsPad?15:12), self.currentViewWidth, 22);
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

- (NSString *)fontName {
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"fontName"]) {
        return [[NSUserDefaults standardUserDefaults] stringForKey:@"fontName"];
    } else {
        return @"YuppySC-Regular";
    }
}

- (BOOL)isRefreshTop {
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"isRefreshTop"]) {
        return [[NSUserDefaults standardUserDefaults] boolForKey:@"isRefreshTop"];
    } else {
        return NO;
    }
}

- (BOOL)isAutoRead {
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"isAutoRead"]) {
        return [[NSUserDefaults standardUserDefaults] boolForKey:@"isAutoRead"];
    } else {
        return NO;
    }
}

- (BOOL)isAlwaysHidden {
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"isAlwaysHidden"]) {
        return [[NSUserDefaults standardUserDefaults] boolForKey:@"isAlwaysHidden"];
    } else {
        return NO;
    }
}

- (BOOL)isUnlock {
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"isUnlock"]) {
        return [[NSUserDefaults standardUserDefaults] boolForKey:@"isUnlock"];
    } else {
        return NO;
    }
}

- (BOOL)isSecretAutoOpen {
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"isSecretAutoOpen"]) {
        return [[NSUserDefaults standardUserDefaults] boolForKey:@"isSecretAutoOpen"];
    } else {
        return NO;
    }
}

- (BOOL)isChapterListAutoScroll {
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"isChapterListAutoScroll"]) {
        return [[NSUserDefaults standardUserDefaults] boolForKey:@"isChapterListAutoScroll"];
    } else {
        return NO;
    }
}

- (NSString *)lastReadBookName {
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"lastReadBookName"]) {
        return [[NSUserDefaults standardUserDefaults] stringForKey:@"lastReadBookName"];
    } else {
        return @"";
    }
}

- (float)nightAlpha {
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"nightAlpha"]) {
        return [[NSUserDefaults standardUserDefaults] floatForKey:@"nightAlpha"];
    } else {
        return 1.0f;
    }
}

- (NSString *)pinString {
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"pinString"]) {
        return [[NSUserDefaults standardUserDefaults] stringForKey:@"pinString"];
    } else {
        return @"";
    }
}

/**
 内容显示的属性(字号/字体/颜色...)
 @return 属性字典
 */
- (NSDictionary *)parserAttribute {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    if ([self.bgImageName isEqualToString:@"black"]) {
        dict[NSForegroundColorAttributeName] = [UIColor colorWithWhite:1 alpha:self.nightAlpha];
    } else {
        dict[NSForegroundColorAttributeName] = [UIColor colorWithHexString:self.fontColor];
    }
    if (self.fontName.length > 0) {
        // YuppySC-Regular
        UIFont *font = [UIFont fontWithName:self.fontName size:self.fontSize];
        dict[NSFontAttributeName] = font;
    } else {
        dict[NSFontAttributeName] = [UIFont systemFontOfSize:self.fontSize];
    }
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = self.lineSpace;
    paragraphStyle.alignment = NSTextAlignmentJustified;
    dict[NSParagraphStyleAttributeName] = paragraphStyle;
    return [dict copy];
}

@end
