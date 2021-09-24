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

@end
