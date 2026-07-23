//
//  RKReadViewController.m
//  Reader
//
//  Created by Rzk on 2019/4/25.
//  Copyright © 2019 Rzk. All rights reserved.
//

#import "RKReadViewController.h"
#import "RKReadView.h"
#import "RKReadStatusBar.h"

@interface RKReadViewController ()

@property (nonatomic, strong) UIImageView *bgImageView; /**< 背景底图*/
@property (nonatomic, strong) RKReadView *readView; /**< view*/
@property (nonatomic, strong) RKReadStatusBar *statusBar; /**< 底部状态栏*/
@property (nonatomic, strong) CAShapeLayer *ribbonLayer; /**< 书签角标*/

@end

@implementation RKReadViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIImage *image = [UIImage imageNamed:[RKUserConfig sharedInstance].bgImageName];
    if ([[RKUserConfig sharedInstance].bgImageName isEqualToString:@"black"]) {
        image = [UIImage imageWithColor:[UIColor blackColor]];
    }
    self.view.layer.contents = (id)image.CGImage;
    self.view.layer.contentsGravity = kCAGravityResizeAspectFill;
    
    [self.view addSubview:self.readView];

    [self.view addSubview:self.statusBar];

    [self.view.layer addSublayer:self.ribbonLayer];
    self.ribbonLayer.hidden = !self.isBookmarked;
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];

    self.ribbonLayer.frame = CGRectMake(self.view.bounds.size.width - 40, 0, 16, 24);
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (BOOL)prefersHomeIndicatorAutoHidden {
    return YES;
}

- (void)dealloc {
    [self.statusBar remove];
}

#pragma mark - getting
- (UIImageView *)bgImageView {
    if (!_bgImageView) {
        _bgImageView = [[UIImageView alloc] init];
        _bgImageView.image = [UIImage imageNamed:[RKUserConfig sharedInstance].bgImageName];
        if ([[RKUserConfig sharedInstance].bgImageName isEqualToString:@"black"]) {
            _bgImageView.image = [UIImage imageWithColor:[UIColor blackColor]];
        }
    }
    return _bgImageView;
}

- (RKReadView *)readView {
    if (!_readView) {
        _readView = [[RKReadView alloc] initWithFrame:[RKUserConfig sharedInstance].readViewFrame];
        _readView.content = self.content;
    }
    return _readView;
}

- (RKReadStatusBar *)statusBar {
    if (!_statusBar) {
        _statusBar = [[RKReadStatusBar alloc] initWithFrame:[RKUserConfig sharedInstance].readStatusBarFrame];
        _statusBar.book = self.book;
    }
    return _statusBar;
}

- (CAShapeLayer *)ribbonLayer {
    if (!_ribbonLayer) {
        _ribbonLayer = [CAShapeLayer layer];
        // 书签 ribbon:矩形底部内凹三角
        UIBezierPath *path = [UIBezierPath bezierPath];
        [path moveToPoint:CGPointMake(0, 0)];
        [path addLineToPoint:CGPointMake(16, 0)];
        [path addLineToPoint:CGPointMake(16, 24)];
        [path addLineToPoint:CGPointMake(8, 18)];
        [path addLineToPoint:CGPointMake(0, 24)];
        [path closePath];
        _ribbonLayer.path = path.CGPath;
        _ribbonLayer.fillColor = [UIColor colorWithHexString:@"E74C3C"].CGColor;
    }
    return _ribbonLayer;
}

#pragma mark - setting
- (void)setIsBookmarked:(BOOL)isBookmarked {
    _isBookmarked = isBookmarked;

    if (_ribbonLayer) {
        _ribbonLayer.hidden = !isBookmarked;
    }
}

@end
