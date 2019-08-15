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
@property (nonatomic, strong) UILabel *title; /**< 书名*/
@property (nonatomic, strong) UIButton *closeBtn; /**< 关闭按钮*/

@property (nonatomic, strong) UIView *bottomView; /**< 底部view*/
@property (nonatomic, strong) UIButton *lastChapter; /**< 上一章*/
@property (nonatomic, strong) UIButton *nextChapter; /**< 下一章*/

@property (nonatomic, copy) void(^dismissBlock)(void); /**< 消失回调*/
@property (nonatomic, copy) void(^closeBlock)(void); /**< 消失回调*/

@end

@implementation RKReadMenuView

/**
 初始化菜单view
 @param frame 大小
 @param book 书籍信息
 @param superView 父view
 @return 菜单
 */
- (instancetype)initWithFrame:(CGRect)frame withBook:(RKBook *)book withSuperView:(UIView *)superView {
    self = [super initWithFrame:frame];
    if (self) {
        _book = book;
        [superView addSubview:self];
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
        make.edges.equalTo(self).insets(UIEdgeInsetsZero);
    }];
    
    // 顶部view
    UIView *navBar = [UIView new];
    self.navBar = navBar;
    [bgButton addSubview:navBar];
    navBar.backgroundColor = [UIColor colorWithWhite:0 alpha:0.8f];
    CGFloat topOffset = kStatusHight + 44;
    [navBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(bgButton.mas_top);
        make.left.right.mas_equalTo(bgButton);
        make.height.mas_equalTo(topOffset);
    }];
    
    UILabel *title = [UILabel new];
    self.title = title;
    [navBar addSubview:title];
    title.text = self.book.name;
    title.textColor = [UIColor whiteColor];
    title.font = [UIFont systemFontOfSize:18];
    title.textAlignment = NSTextAlignmentCenter;
    [title mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(navBar.mas_bottom).mas_offset(-10);
        make.centerX.mas_equalTo(navBar.centerX);
        make.width.mas_equalTo(280);
    }];
    
    UIButton *closeBtn = [UIButton new];
    self.closeBtn = closeBtn;
    [navBar addSubview:closeBtn];
    [closeBtn setImage:[UIImage imageNamed:@"关闭白"] forState:UIControlStateNormal];
    [closeBtn addTarget:self action:@selector(clickCloseBtn) forControlEvents:UIControlEventTouchUpInside];
    [closeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15);
        make.centerY.mas_equalTo(title.mas_centerY);
        make.width.height.mas_equalTo(35);
    }];
    
    // 底部view
    UIView *bottomView = [UIView new];
    self.bottomView = bottomView;
    [bgButton addSubview:bottomView];
    bottomView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.8f];
    CGFloat height = kSafeAreaBottom + 140;
    [bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(bgButton.mas_bottom);
        make.left.right.mas_equalTo(bgButton);
        make.height.mas_equalTo(height);
    }];
    
    [self layoutIfNeeded];
}

/// 显示
- (void)show {
    
    [UIView animateWithDuration:0.25f animations:^{
        CGFloat topOffset = kStatusHight + 44;
        [self.navBar mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(0);
            make.left.right.mas_equalTo(self.bgButton);
            make.height.mas_equalTo(topOffset);
        }];
        CGFloat height = kSafeAreaBottom + 140;
        [self.bottomView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(self.bgButton.mas_bottom);
            make.left.right.mas_equalTo(self.bgButton);
            make.height.mas_equalTo(height);
        }];
        // 注意需要再执行一次更新约束
        [self layoutIfNeeded];
    }];
}

/// 消失回调
- (void)dismissWithHandler:(void(^)(void))handler {
    self.dismissBlock = handler;
}

/// 关闭回调
- (void)closeBlock:(void(^)(void))handler {
    self.closeBlock = handler;
}

#pragma mark - 点击事件
/// 消失
-  (void)bgClick {
    
    [UIView animateWithDuration:0.25f animations:^{
        CGFloat topOffset = kStatusHight + 44;
        [self.navBar mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(self.bgButton.mas_top);
            make.left.right.mas_equalTo(self.bgButton);
            make.height.mas_equalTo(topOffset);
        }];
        CGFloat height = kSafeAreaBottom + 140;
        [self.bottomView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.bgButton.mas_bottom);
            make.left.right.mas_equalTo(self.bgButton);
            make.height.mas_equalTo(height);
        }];
        // 注意需要再执行一次更新约束
        [self layoutIfNeeded];
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
        if (self.dismissBlock) {
            self.dismissBlock();
        }
    }];
}

/// 关闭
- (void)clickCloseBtn {
    
    [UIView animateWithDuration:0.25f animations:^{
        CGFloat topOffset = kStatusHight + 44;
        [self.navBar mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(self.bgButton.mas_top);
            make.left.right.mas_equalTo(self.bgButton);
            make.height.mas_equalTo(topOffset);
        }];
        CGFloat height = kSafeAreaBottom + 140;
        [self.bottomView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.bgButton.mas_bottom);
            make.left.right.mas_equalTo(self.bgButton);
            make.height.mas_equalTo(height);
        }];
        // 注意需要再执行一次更新约束
        [self layoutIfNeeded];
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
        if (self.closeBlock) {
            self.closeBlock();
        }
    }];
}


@end
