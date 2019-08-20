//
//  RKChaptersListView.m
//  Reader
//
//  Created by Rzk on 2019/8/20.
//  Copyright © 2019 Rzk. All rights reserved.
//

#import "RKChaptersListView.h"

@interface RKChaptersListView () <UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) RKBook *book; /**< 当前书籍*/
@property (nonatomic, strong) UIButton *bgButton; /**< 大背景*/
@property (nonatomic, strong) UITableView *tableView; /**< 列表*/
@property (nonatomic, copy) void(^callBack)(void); /**< 回调*/

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
- (instancetype)initWithFrame:(CGRect)frame withBook:(RKBook *)book withSuperView:(UIView *)superView {
    self = [super initWithFrame:frame];
    if (self) {
        _book = book;
        [superView addSubview:self];
        
        [self addSubview:self.bgButton];
        [self.bgButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(self);
        }];
        
        [self addSubview:self.tableView];
        [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(0);
            make.right.mas_equalTo(self.mas_left);
            make.width.mas_equalTo(260);
            make.height.mas_equalTo(kScreenHeight);
        }];
        
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
        [self.tableView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(0);
            make.left.mas_equalTo(self.mas_left);
            make.width.mas_equalTo(260);
            make.height.mas_equalTo(kScreenHeight);
        }];
        // 注意需要再执行一次更新约束
        [self layoutIfNeeded];
    } completion:^(BOOL finished) {
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.book.currentChapterNum inSection:0] atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
    }];
}

- (void)dismiss {
    [UIView animateWithDuration:0.25f animations:^{
        [self.tableView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(0);
            make.right.mas_equalTo(self.mas_left);
            make.width.mas_equalTo(260);
            make.height.mas_equalTo(kScreenHeight);
        }];
        // 注意需要再执行一次更新约束
        [self layoutIfNeeded];
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
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
    RKLog(@"---- count=%lu",(unsigned long)[self.book.chapters count]);
    return [self.book.chapters count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([UITableViewCell class])];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:NSStringFromClass([UITableViewCell class])];
    }
    
    RKChapter *chapter = self.book.chapters[indexPath.row];
    cell.textLabel.text = [chapter.title stringByTrimmingCharactersInSet];
    
    if (indexPath.row == self.book.currentChapterNum) {
        cell.textLabel.textColor = [UIColor grayColor];
    } else {
        cell.textLabel.textColor = [UIColor blackColor];
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

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] init];
        
        _tableView.delegate = self;
        _tableView.dataSource = self;
        
        [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:NSStringFromClass([UITableViewCell class])];
        _tableView.contentInset = UIEdgeInsetsMake(kStatusHight + 20, 0, kSafeAreaBottom + 20, 0);
        
        _tableView.tableFooterView = [UIView new];
    }
    return _tableView;
}


@end
