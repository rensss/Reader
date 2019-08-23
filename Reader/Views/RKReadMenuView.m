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

@property (nonatomic, strong) UIButton *reduceButton; /**< 减小字体*/
@property (nonatomic, strong) UILabel *fontSize; /**< 字号*/
@property (nonatomic, strong) UIButton *increaseButton; /**< 增大字体*/

@property (nonatomic, strong) UIButton *smallSpace; /**< 小行间距*/
@property (nonatomic, strong) UIButton *middleSpace; /**< 中行间距*/
@property (nonatomic, strong) UIButton *bigSpace; /**< 大行间距*/

@property (nonatomic, strong) UIButton *chaptersButton; /**< 目录*/
@property (nonatomic, strong) UIButton *nightButton; /**< 夜间模式*/
@property (nonatomic, strong) UIButton *settingButton; /**< 设置*/

@property (nonatomic, copy) void(^dismissBlock)(void); /**< 消失回调*/
@property (nonatomic, copy) void(^closeBlock)(void); /**< 关闭回调*/
@property (nonatomic, copy) void(^changeChapterBlock)(BOOL); /**< 上/下一章节*/
@property (nonatomic, copy) void(^fontSizrChangeBlock)(void); /**< 改变字号*/
@property (nonatomic, copy) void(^lineSpaceBlock)(void); /**< 行间距回调*/
@property (nonatomic, copy) void(^catalogBlock)(void); /**< 目录回调*/
@property (nonatomic, copy) void(^nightModeBlock)(BOOL); /**< 夜间模式回调*/
@property (nonatomic, copy) void(^settingBlock)(void); /**< 设置回调*/

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
    
    // 关闭按钮
    UIButton *closeBtn = [UIButton new];
    self.closeBtn = closeBtn;
    [navBar addSubview:closeBtn];
    [closeBtn setBackgroundImage:[UIImage imageNamed:@"关闭白"] forState:UIControlStateNormal];
    [closeBtn addTarget:self action:@selector(clickCloseBtn) forControlEvents:UIControlEventTouchUpInside];
    [closeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(navBar.mas_bottom).mas_offset(-10);
        make.left.mas_equalTo(15);
        make.width.mas_equalTo(24);
        make.height.mas_equalTo(24);
    }];
    
    // 书名
    UILabel *title = [UILabel new];
    self.title = title;
    [navBar addSubview:title];
    title.text = self.book.name;
    title.textColor = [UIColor whiteColor];
    title.font = [UIFont systemFontOfSize:18];
    title.textAlignment = NSTextAlignmentCenter;
    [title mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(closeBtn.mas_centerY);
        make.centerX.mas_equalTo(navBar.mas_centerX);
//        make.left.mas_equalTo(closeBtn.mas_right).mas_offset(0);
//        make.right.mas_equalTo(navBar.mas_right);
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
    
    // 上/下 章节
    UIButton *lastChapter = [[UIButton alloc] init];
    self.lastChapter = lastChapter;
    [bottomView addSubview:lastChapter];
    lastChapter.tintColor = [UIColor whiteColor];
    [lastChapter setBackgroundImage:[[UIImage imageNamed:@"上一章"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    [lastChapter mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(10);
        make.left.mas_equalTo(10);
        make.width.mas_equalTo(30);
        make.height.mas_equalTo(24);
    }];
    [lastChapter addTarget:self action:@selector(changChaperClick:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *nextChapter = [[UIButton alloc] init];
    self.nextChapter = nextChapter;
    [bottomView addSubview:nextChapter];
    nextChapter.tintColor = [UIColor whiteColor];
    [nextChapter setBackgroundImage:[[UIImage imageNamed:@"下一章"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    [nextChapter mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(10);
        make.right.mas_equalTo(-10);
        make.width.mas_equalTo(30);
        make.height.mas_equalTo(24);
    }];
    [nextChapter addTarget:self action:@selector(changChaperClick:) forControlEvents:UIControlEventTouchUpInside];
    
    // 字号
    [bottomView addSubview:self.fontSize];
    [self.fontSize mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.lastChapter.mas_centerY);
        make.centerX.mas_equalTo(bottomView);
    }];
    
    [bottomView addSubview:self.reduceButton];
    [self.reduceButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.fontSize.mas_centerY);
        make.right.mas_equalTo(self.fontSize.mas_left).mas_offset(-12);
        make.width.height.mas_equalTo(26);
    }];
    
    [bottomView addSubview:self.increaseButton];
    [self.increaseButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.fontSize.mas_centerY);
        make.left.mas_equalTo(self.fontSize.mas_right).mas_offset(12);
        make.width.height.mas_equalTo(26);
    }];
    
    // 行间距
    [bottomView addSubview:self.smallSpace];
    [bottomView addSubview:self.middleSpace];
    [bottomView addSubview:self.bigSpace];
    
    NSMutableArray *array = [NSMutableArray arrayWithArray:@[self.smallSpace,self.middleSpace,self.bigSpace]];
    [array mas_distributeViewsAlongAxis:MASAxisTypeHorizontal withFixedSpacing:10 leadSpacing:15 tailSpacing:15];
    [array mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(lastChapter.mas_bottom).mas_offset(12);
        make.height.mas_equalTo(60);
    }];
    
    // 目录
    [bottomView addSubview:self.chaptersButton];
    [self.chaptersButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(24);
        make.height.mas_equalTo(24);
        make.left.mas_equalTo(15);
        make.bottom.mas_equalTo( -(kSafeAreaBottom + 5));
    }];
    
    // 夜间
    [bottomView addSubview:self.nightButton];
    [self.nightButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(self.chaptersButton.mas_width);
        make.height.mas_equalTo(self.chaptersButton.mas_height);
        make.left.mas_equalTo(self.chaptersButton.mas_right).with.mas_offset(12);
        make.centerY.mas_equalTo(self.chaptersButton.mas_centerY);
    }];
    
    // 设置
    [bottomView addSubview:self.settingButton];
    [self.settingButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(self.chaptersButton.mas_width);
        make.height.mas_equalTo(self.chaptersButton.mas_height);
        make.left.mas_equalTo(self.nightButton.mas_right).with.mas_offset(12);
        make.centerY.mas_equalTo(self.nightButton.mas_centerY);
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

/// 消失
- (void)dismiss {
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

/// 消失回调
- (void)dismissWithHandler:(void(^)(void))handler {
    self.dismissBlock = handler;
}

/// 关闭回调
- (void)closeBlock:(void(^)(void))handler {
    self.closeBlock = handler;
}

/// 章节跳转
- (void)shouldChangeChapter:(void(^)(BOOL isNextChapter))handler {
    self.changeChapterBlock = handler;
}

- (void)shouldChangeFontSize:(void (^)(void))handler {
    self.fontSizrChangeBlock = handler;
}

/// 改变行间距
- (void)shouldChangeLineSpace:(void(^)(void))handler {
    self.lineSpaceBlock = handler;
}

/// 打开目录
- (void)shouldShowBookCatalog:(void(^)(void))handler {
    self.catalogBlock = handler;
}

/// 是否打开夜间模式
- (void)shouldChangeNightModle:(void(^)(BOOL isOpen))handler {
    self.nightModeBlock = handler;
}

/// 打开设置
- (void)shouldOpenSetting:(void(^)(void))handler {
    self.settingBlock = handler;
}

#pragma mark - 点击事件
/// 消失
-  (void)bgClick {
    [self dismiss];
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

/// 章节跳转
- (void)changChaperClick:(UIButton *)btn {
    if (self.changeChapterBlock) {
        self.changeChapterBlock(btn == self.nextChapter);
    }
}

- (void)fontSizeClick:(UIButton *)btn {
    CGFloat fontSize = [RKUserConfig sharedInstance].fontSize;
    
    if (btn == self.reduceButton) {
        if (fontSize == 10) {
            RKAlertMessageShowInWindow(@"太小了！");
            return;
        }
        [RKUserConfig sharedInstance].fontSize = fontSize-1;
    } else {
        if (fontSize == 30) {
            RKAlertMessageShowInWindow(@"太大了！");
            return;
        }
        [RKUserConfig sharedInstance].fontSize = fontSize+1;
    }

    self.fontSize.text = [NSString stringWithFormat:@"%.0f",[RKUserConfig sharedInstance].fontSize];
    
    if (self.fontSizrChangeBlock) {
        self.fontSizrChangeBlock();
    }
}

- (void)spaceClick:(UIButton *)btn {
    
    if (btn.selected) {
        return;
    }
    
    if (btn == self.smallSpace) {
        self.smallSpace.selected = YES;
        self.middleSpace.selected = NO;
        self.bigSpace.selected = NO;
        
        [RKUserConfig sharedInstance].lineSpace = 5.0f;
    }
    
    if (btn == self.middleSpace) {
        self.smallSpace.selected = NO;
        self.middleSpace.selected = YES;
        self.bigSpace.selected = NO;
        
        [RKUserConfig sharedInstance].lineSpace = 10.0f;
    }
    
    if (btn == self.bigSpace) {
        self.smallSpace.selected = NO;
        self.middleSpace.selected = NO;
        self.bigSpace.selected = YES;
        
        [RKUserConfig sharedInstance].lineSpace = 15.0f;
    }
    
    if (self.lineSpaceBlock) {
        self.lineSpaceBlock();
    }
}

- (void)chaptersClick:(UIButton *)btn {
    [self dismiss];
    if (self.catalogBlock) {
        self.catalogBlock();
    }
}

- (void)nightClick:(UIButton *)btn {
    btn.selected = !btn.selected;
    if (self.nightModeBlock) {
        self.nightModeBlock(btn.selected);
    }
}

- (void)settingClick:(UIButton *)btn {
    if (self.settingBlock) {
        self.settingBlock();
    }
    [self dismiss];
}

#pragma mark - getting
- (UILabel *)fontSize {
    if (!_fontSize) {
        _fontSize = [[UILabel alloc] init];
        
        _fontSize.textColor = [UIColor whiteColor];
        _fontSize.font = [UIFont systemFontOfSize:18];
        _fontSize.textAlignment = NSTextAlignmentCenter;
        _fontSize.text = [NSString stringWithFormat:@"%.0f",[RKUserConfig sharedInstance].fontSize];
    }
    return _fontSize;
}

- (UIButton *)reduceButton {
    if (!_reduceButton) {
        _reduceButton = [[UIButton alloc] init];
        
        [_reduceButton setBackgroundImage:[UIImage imageNamed:@"字体减小"] forState:UIControlStateNormal];
        [_reduceButton addTarget:self action:@selector(fontSizeClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _reduceButton;
}

- (UIButton *)increaseButton {
    if (!_increaseButton) {
        _increaseButton = [[UIButton alloc] init];
        
        [_increaseButton setBackgroundImage:[UIImage imageNamed:@"字体增大"] forState:UIControlStateNormal];
        [_increaseButton addTarget:self action:@selector(fontSizeClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _increaseButton;
}


- (UIButton *)bigSpace {
    if (!_bigSpace) {
        _bigSpace = [[UIButton alloc] init];
        
        _bigSpace.tintColor = [UIColor whiteColor];
        [_bigSpace setImage:[[UIImage imageNamed:@"lineSpace_big"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
        [_bigSpace setImage:[[UIImage imageNamed:@"lineSpace_big"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forState:UIControlStateSelected];
        
        [_bigSpace addTarget:self action:@selector(spaceClick:) forControlEvents:UIControlEventTouchUpInside];
        
        CGFloat space = [RKUserConfig sharedInstance].lineSpace;
        if (space == 15.0f) {
            _bigSpace.selected = YES;
        }
    }
    return _bigSpace;
}

- (UIButton *)middleSpace {
    if (!_middleSpace) {
        _middleSpace = [[UIButton alloc] init];
        
        _middleSpace.tintColor = [UIColor whiteColor];
        [_middleSpace setImage:[[UIImage imageNamed:@"lineSpace_mid"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
        [_middleSpace setImage:[[UIImage imageNamed:@"lineSpace_mid"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forState:UIControlStateSelected];
        
        [_middleSpace addTarget:self action:@selector(spaceClick:) forControlEvents:UIControlEventTouchUpInside];
        
        CGFloat space = [RKUserConfig sharedInstance].lineSpace;
        if (space == 10.0f) {
            _middleSpace.selected = YES;
        }
    }
    return _middleSpace;
}

- (UIButton *)smallSpace {
    if (!_smallSpace) {
        _smallSpace = [[UIButton alloc] init];
        
        _smallSpace.tintColor = [UIColor whiteColor];
        [_smallSpace setImage:[[UIImage imageNamed:@"lineSpace_small"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
        [_smallSpace setImage:[[UIImage imageNamed:@"lineSpace_small"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forState:UIControlStateSelected];
        
        [_smallSpace addTarget:self action:@selector(spaceClick:) forControlEvents:UIControlEventTouchUpInside];
        
        CGFloat space = [RKUserConfig sharedInstance].lineSpace;
        if (space == 5.0f) {
            _smallSpace.selected = YES;
        }
    }
    return _smallSpace;
}

- (UIButton *)chaptersButton {
    if (!_chaptersButton) {
        _chaptersButton = [[UIButton alloc] init];
        
        _chaptersButton.tintColor = [UIColor whiteColor];
        [_chaptersButton setBackgroundImage:[[UIImage imageNamed:@"详情"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
        [_chaptersButton addTarget:self action:@selector(chaptersClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _chaptersButton;
}

- (UIButton *)nightButton {
    if (!_nightButton) {
        _nightButton = [[UIButton alloc] init];
        
        _nightButton.tintColor = [UIColor whiteColor];
        [_nightButton setBackgroundImage:[[UIImage imageNamed:@"夜间模式选中"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
        [_nightButton setBackgroundImage:[[UIImage imageNamed:@"夜间模式选中"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forState:UIControlStateSelected];
        
        [_nightButton addTarget:self action:@selector(nightClick:) forControlEvents:UIControlEventTouchUpInside];
        
        // 改变默认状态
        if ([[RKUserConfig sharedInstance].bgImageName isEqualToString:@"reader_bg_2"]) {
            _nightButton.selected = YES;
        }else {
            _nightButton.selected = NO;
        }
    }
    return _nightButton;
}

- (UIButton *)settingButton {
    if (!_settingButton) {
        _settingButton = [[UIButton alloc] init];
        
        _settingButton.tintColor = [UIColor whiteColor];
        [_settingButton setBackgroundImage:[[UIImage imageNamed:@"设置"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
        [_settingButton addTarget:self action:@selector(settingClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _settingButton;
}

@end
