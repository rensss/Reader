//
//  RKReadViewController.m
//  Reader
//
//  Created by Rzk on 2019/4/25.
//  Copyright © 2019 Rzk. All rights reserved.
//

#import "RKReadViewController.h"
#import "RKReadView.h"

@interface RKReadViewController ()

@property (nonatomic, strong) UIImageView *bgImageView; /**< 背景底图*/
@property (nonatomic, strong) RKReadView *readView; /**< view*/

@end

@implementation RKReadViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    [self.view addSubview:self.bgImageView];
//    [self.bgImageView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.edges.equalTo(self.view);
//    }];
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:[RKUserConfig sharedInstance].bgImageName]];
    
    [self.view addSubview:self.readView];
    
#warning - masonry
//    RKUserConfig *userConfig = [RKUserConfig sharedInstance];
//    [self.readView mas_makeConstraints:^(MASConstraintMaker *make) {
////        make.edges.equalTo(self.view).with.insets(UIEdgeInsetsMake(kStatusHight + 20, 20, kSafeAreaBottom + 20, 20));
//        make.edges.equalTo(self.view).with.insets(UIEdgeInsetsMake(kStatusHight + userConfig.topPadding, userConfig.leftPadding, kSafeAreaBottom + userConfig.bottomPadding, userConfig.rightPadding));
//    }];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
//    RKLog(@"---- ddd");
}

#pragma mark - getting
- (UIImageView *)bgImageView {
    if (!_bgImageView) {
        _bgImageView = [[UIImageView alloc] init];
        _bgImageView.image = [UIImage imageNamed:[RKUserConfig sharedInstance].bgImageName];
    }
    return _bgImageView;
}

- (RKReadView *)readView {
    if (!_readView) {
        _readView = [[RKReadView alloc] initWithFrame:[RKUserConfig sharedInstance].readViewFrame];
//        _readView = [[RKReadView alloc] init];
        _readView.content = self.content;
    }
    return _readView;
}

@end
