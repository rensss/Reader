//
//  RKChaptersListView.m
//  Reader
//
//  Created by Rzk on 2019/8/20.
//  Copyright © 2019 Rzk. All rights reserved.
//

#import "RKChaptersListView.h"
#import "RKChaptersListCell.h"
#import "RKBookmarkListCell.h"

#define kListWidth (RKUserConfig.sharedInstance.currentViewWidth * 0.8)

@interface RKChaptersListView () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) RKBook *book; /**< 当前书籍*/
@property (nonatomic, strong) UIButton *bgButton; /**< 大背景*/
@property (nonatomic, strong) UIView *tableViewBgView; /**< 列表背景 */
@property (nonatomic, strong) UITableView *tableView; /**< 列表*/
@property (nonatomic, copy) void(^callBack)(void); /**< 回调*/
@property (nonatomic, copy) void(^dismissHandler)(void); /**< 消失的回调 */
@property (nonatomic, strong) UISegmentedControl *segmentControl; /**< 目录/书签 切换*/
@property (nonatomic, strong) UILabel *emptyLabel; /**< 书签空占位*/
@property (nonatomic, copy) void(^bookmarkCallBack)(RKBookmark *bookmark); /**< 书签回调*/
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

/**
 选中书签的回调
 @param handler 回调(回传选中的书签)
 */
- (void)didSelectBookmark:(void(^)(RKBookmark *bookmark))handler {
    self.bookmarkCallBack = handler;
}

/// 分段切换
- (void)segmentChanged {
    [self.tableView reloadData];
    [self updateEmptyLabel];
}

/// 更新空占位显隐
- (void)updateEmptyLabel {
    BOOL showEmpty = (self.segmentControl.selectedSegmentIndex == 1) && (self.book.bookmarks.count == 0);
    self.emptyLabel.hidden = !showEmpty;
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
        if (self.segmentControl.selectedSegmentIndex == 0 && [self.book.chapters count] > 0) {
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
    if (self.segmentControl.selectedSegmentIndex == 1) {
        if (indexPath.row < self.book.bookmarks.count && self.bookmarkCallBack) {
            self.bookmarkCallBack(self.book.bookmarks[indexPath.row]);
        }
        [self dismiss];
        return;
    }

    self.book.currentChapterNum = indexPath.row;
    self.book.currentPage = 0;

    if (self.callBack) {
        self.callBack();
    }

    [self dismiss];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return self.segmentControl.selectedSegmentIndex == 1 ? 72 : 50;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return self.segmentControl.selectedSegmentIndex == 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    return @"删除";
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle != UITableViewCellEditingStyleDelete) return;
    if (self.segmentControl.selectedSegmentIndex != 1) return;
    if (indexPath.row >= self.book.bookmarks.count) return;

    [self.book.bookmarks removeObjectAtIndex:indexPath.row];
    // 与 updateLocalBookData 一致,落盘走后台队列
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [[RKFileManager shareInstance] updateBookmarksForBook:self.book];
    });
    [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    [self updateEmptyLabel];
}

#pragma mark -- UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.segmentControl.selectedSegmentIndex == 1) {
        return [self.book.bookmarks count];
    }
    return [self.book.chapters count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.segmentControl.selectedSegmentIndex == 1) {
        RKBookmarkListCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([RKBookmarkListCell class])];
        if (!cell) {
            cell = [[RKBookmarkListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:NSStringFromClass([RKBookmarkListCell class])];
            cell.backgroundColor = [UIColor clearColor];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        RKBookmark *bookmark = self.book.bookmarks[indexPath.row];
        cell.bookmark = bookmark;
        if (bookmark.chapterNum < self.book.chapters.count) {
            RKChapter *chapter = self.book.chapters[bookmark.chapterNum];
            cell.chapterTitle = chapter.title;
        } else {
            cell.chapterTitle = @"未知章节";
        }
        return cell;
    }

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
        
        // 目录/书签 分段
        [bgContainerView addSubview:self.segmentControl];
        [self.segmentControl mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(kStatusHight + 8);
            make.leading.mas_equalTo(16);
            make.trailing.mas_equalTo(-16);
            make.height.mas_equalTo(32);
        }];

        // 添加 tableView 到 bgContainerView 中
        [bgContainerView addSubview:self.tableView];
        [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.segmentControl.mas_bottom).mas_offset(8);
            make.leading.trailing.mas_equalTo(bgContainerView);
            make.bottom.mas_offset(-(kSafeAreaBottom + RKUserConfig.sharedInstance.readStatusBarFrame.size.height));
        }];

        // 书签空占位
        [bgContainerView addSubview:self.emptyLabel];
        [self.emptyLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.mas_equalTo(bgContainerView);
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

- (UISegmentedControl *)segmentControl {
    if (!_segmentControl) {
        _segmentControl = [[UISegmentedControl alloc] initWithItems:@[@"目录", @"书签"]];
        _segmentControl.selectedSegmentIndex = 0;
        [_segmentControl addTarget:self action:@selector(segmentChanged) forControlEvents:UIControlEventValueChanged];
    }
    return _segmentControl;
}

- (UILabel *)emptyLabel {
    if (!_emptyLabel) {
        _emptyLabel = [[UILabel alloc] init];
        _emptyLabel.text = @"暂无书签,阅读页下拉即可添加";
        _emptyLabel.font = [UIFont systemFontOfSize:14.0f];
        _emptyLabel.textColor = kReadViewBottomTintColor;
        _emptyLabel.hidden = YES;
    }
    return _emptyLabel;
}

@end
