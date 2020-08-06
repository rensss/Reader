//
//  RKPinViewController.m
//  Reader
//
//  Created by Rzk on 2020/8/6.
//  Copyright © 2020 Rzk. All rights reserved.
//

#import "RKPinViewController.h"
#import "RKPinView.h"

@interface RKPinViewController ()


@property (nonatomic, strong) RKPinView *pinView; /**< view*/


@end

@implementation RKPinViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIButton *btn = [[UIButton alloc] init];
    [self.view addSubview:btn];
    [btn setBackgroundColor:[UIColor blackColor]];
    [btn setTitle:@"close" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(closeClick) forControlEvents:UIControlEventTouchUpInside];
    
    [btn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.view);
        make.top.mas_equalTo(100);
        make.width.mas_equalTo(100);
        make.height.mas_equalTo(50);
    }];
    
}

#pragma mark - 事件
- (void)closeClick {
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - getting
- (RKPinView *)pinView {
    if (!_pinView) {
        _pinView = [[RKPinView alloc] init];
    }
    return _pinView;
}

@end
