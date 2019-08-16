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

@property (nonatomic, strong) RKReadView *readView; /**< view*/

@end

@implementation RKReadViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view addSubview:self.readView];
    [self.readView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view).with.insets(UIEdgeInsetsMake(kStatusHight + 20, 20, kSafeAreaBottom + 20, 20));
    }];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    RKLog(@"---- ddd");
}

#pragma mark - getting
- (RKReadView *)readView {
    if (!_readView) {
        _readView = [[RKReadView alloc] init];
        _readView.content = self.content;
    }
    return _readView;
}

@end
