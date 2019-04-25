//
//  RKReadMenuView.m
//  Reader
//
//  Created by Rzk on 2019/4/25.
//  Copyright © 2019 Rzk. All rights reserved.
//

#import "RKReadMenuView.h"

@interface RKReadMenuView ()

@property (nonatomic, strong) RKBook *book; /**< 书籍*/

@property (nonatomic, strong) UIButton *bgButton; /**< 大Button*/
@property (nonatomic, strong) UIView *navBar; /**< 顶部导航条*/



@property (nonatomic, strong) UIView *bottomView; /**< 底部view*/

@end

@implementation RKReadMenuView

/**
初始化菜单view
@param frame 大小
@param book 书籍信息
@return 菜单
*/
- (instancetype)initWithFrame:(CGRect)frame withBook:(RKBook *)book {
    self = [super initWithFrame:frame];
    if (self) {
        _book = book;
        [self initUI];
    }
    return self;
}

#pragma mark - 函数
/// 初始化UI
- (void)initUI {
    
    UIButton *bgButton = [UIButton new];
    self.bgButton = bgButton;
    [self addSubview:bgButton];
    [bgButton addTarget:self action:@selector(bgClick) forControlEvents:UIControlEventTouchUpInside];
    [bgButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.bottom.right.mas_offset(0);
    }];
    
    // 顶部view
    UIView *navBar = [UIView new];
    self.navBar = navBar;
    [bgButton addSubview:navBar];
    navBar.backgroundColor = [UIColor colorWithWhite:0 alpha:0.8f];
    CGFloat topOffset = kStatusHight + 44;
    [navBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(-topOffset);
        make.left.right.mas_equalTo(0);
        make.height.mas_equalTo(topOffset);
    }];
    
    UILabel *title = [UILabel new];
    
    
    // 底部view
    UIView *bottomView = [UIView new];
    self.bottomView = bottomView;
    [self addSubview:bottomView];
    bottomView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.8f];
    CGFloat height = kSafeAreaBottom + 140;
    [bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(bgButton.mas_height);
        make.left.right.mas_equalTo(0);
        make.height.mas_equalTo(height);
    }];
    
}

/// 显示
- (void)showToView:(UIView *)superView {
    
    [superView addSubview:self];
    
    [UIView animateWithDuration:0.25f animations:^{
        self.navBar.y = 0;
        self.bottomView.maxY = self.height;
    }];
}

#pragma mark - 点击时间
/// 消失
-  (void)bgClick {
    
    [UIView animateWithDuration:0.25f animations:^{
        self.navBar.maxY = 0;
        self.bottomView.y = self.height;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
//        if (self.dismissBlock) {
//            self.dismissBlock();
//        }
    }];
}

@end
