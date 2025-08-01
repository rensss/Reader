//
//  RKChaptersListView.m
//  Reader
//
//  Created by Rzk on 2019/8/20.
//  Copyright © 2019 Rzk. All rights reserved.
//

#import "RKChaptersListView.h"
#import "RKChaptersListCell.h"

#define kListWidth (RKUserConfig.sharedInstance.currentViewWidth * 0.8)

@interface RKChaptersListView () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) RKBook *book; /**< 当前书籍*/
@property (nonatomic, strong) UIButton *bgButton; /**< 大背景*/
@property (nonatomic, strong) UIView *tableViewBgView; /**< 列表背景 */
@property (nonatomic, strong) UITableView *tableView; /**< 列表*/
@property (nonatomic, copy) void(^callBack)(void); /**< 回调*/
@property (nonatomic, copy) void(^dismissHandler)(void); /**< 消失的回调 */
@end


@implementation RKChaptersListView

#pragma mark - lifeCycle
/**
 初始化菜单view
 @param frame 大小
 @param book 书籍信息
 @param superView 父view
 @return 菜单
 */
- (instancetype)initWithFrame:(CGRect)frame withBook:(RKBook *)book withSuperView:(UIView *)superView dismissHandler:(void(^)(void))handler {
    self = [super initWithFrame:frame];
    if (self) {
        _book = book;
        [superView addSubview:self];
        
        [self addSubview:self.bgButton];
        [self.bgButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(self);
        }];
        
        [self addSubview:self.tableViewBgView];
        [self.tableViewBgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(0);
            make.leading.mas_equalTo(self.mas_leading).mas_offset(-kListWidth);
            make.width.mas_equalTo(kListWidth);
            make.height.mas_equalTo(kWindowHeight);
        }];
        self.dismissHandler = handler;
        [self layoutIfNeeded];
    }
    return self;
}

#pragma mark - 点击事件
- (void)bgClick {
    [self dismiss];
}

#pragma mark - func
/**
 选中章节的回调
 @param handler 回调
 */
- (void)didSelectChapter:(void(^)(void))handler {
    self.callBack = handler;
}

/// 显示
- (void)show {
    [UIView animateWithDuration:0.25f animations:^{
        [self.tableViewBgView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.mas_left);
        }];
        // 注意需要再执行一次更新约束
        [self layoutIfNeeded];
    } completion:^(BOOL finished) {
        if ([self.book.chapters count] > 0) {
            [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.book.currentChapterNum inSection:0] atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
        }
    }];
}

- (void)dismiss {
    [UIView animateWithDuration:0.25f animations:^{
        [self.tableViewBgView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.mas_left).mas_offset(-kListWidth);
        }];
        // 注意需要再执行一次更新约束
        [self layoutIfNeeded];
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
        self.dismissHandler();
    }];
}

#pragma mark - 代理
#pragma mark -- UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.book.currentChapterNum = indexPath.row;
    self.book.currentPage = 0;
    
    if (self.callBack) {
        self.callBack();
    }
    
    [self dismiss];
}

#pragma mark -- UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.book.chapters count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    RKChaptersListCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([RKChaptersListCell class])];
    
    if (!cell) {
        cell = [[RKChaptersListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:NSStringFromClass([RKChaptersListCell class])];
        cell.backgroundColor = [UIColor clearColor];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    RKChapter *chapter = self.book.chapters[indexPath.row];
    cell.chapter = chapter;
    
    if (indexPath.row == self.book.currentChapterNum) { // 当前章节
        cell.isCurrent = YES;
    } else {
        cell.isCurrent = NO;
    }
    
    return cell;
}

#pragma mark - getting
- (UIButton *)bgButton {
    if (!_bgButton) {
        _bgButton = [[UIButton alloc] init];
        
        [_bgButton addTarget:self action:@selector(bgClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _bgButton;
}

- (UIView *)tableViewBgView {
    if (!_tableViewBgView) {
        // 外层 View：负责阴影
        _tableViewBgView = [[UIView alloc] init];
        _tableViewBgView.backgroundColor = [UIColor clearColor];
        _tableViewBgView.layer.shadowColor = [UIColor blackColor].CGColor;
        _tableViewBgView.layer.shadowOffset = CGSizeMake(3, 0);
        _tableViewBgView.layer.shadowOpacity = 0.8;
        _tableViewBgView.layer.shadowRadius = 8;
        
        // 内层容器 View：负责背景图和裁剪
        UIView *bgContainerView = [[UIView alloc] init];
        bgContainerView.backgroundColor = [UIColor clearColor];
        bgContainerView.layer.masksToBounds = YES;
        
        // 设置背景图
        UIImage *image = [UIImage imageNamed:[RKUserConfig sharedInstance].bgImageName];
        if ([[RKUserConfig sharedInstance].bgImageName isEqualToString:@"black"]) {
            image = [UIImage imageWithColor:[UIColor blackColor]];
        }
        bgContainerView.layer.contents = (id)image.CGImage;
        bgContainerView.layer.contentsGravity = kCAGravityResizeAspectFill;
        
        [_tableViewBgView addSubview:bgContainerView];
        [bgContainerView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(_tableViewBgView);
        }];
        
        // 添加 tableView 到 bgContainerView 中
        [bgContainerView addSubview:self.tableView];
        [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(kStatusHight);
            make.leading.trailing.mas_equalTo(bgContainerView);
            make.bottom.mas_offset(-(kSafeAreaBottom + RKUserConfig.sharedInstance.readStatusBarFrame.size.height));
        }];
    }
    return _tableViewBgView;
}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] init];
        
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.rowHeight = 50;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.layer.masksToBounds = YES;
        
        _tableView.tableFooterView = [UIView new];
    }
    return _tableView;
}

@end
