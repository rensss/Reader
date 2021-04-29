//
//  RKHomeListViewController.m
//  Reader
//
//  Created by Rzk on 2019/4/22.
//  Copyright © 2019 Rzk. All rights reserved.
//

#import "RKHomeListViewController.h"
#import "RKSettingViewController.h"
#import "RKHomeListTableViewCell.h"
#import "RKReadPageViewController.h"
#import "RKSecretViewController.h"
#import "RKPinViewController.h"

@interface RKHomeListViewController () <UITableViewDelegate, UITableViewDataSource, UIViewControllerPreviewingDelegate, RKPinViewControllerDelegate>

@property (nonatomic, strong) UITableView *tableView; /**< 列表*/
@property (nonatomic, strong) NSMutableArray *dataArray; /**< 数据源*/

@end

@implementation RKHomeListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"Reader";
    
    [self initUI];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveQuickReadNotification:) name:RKShortcutQuickReadItemType object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveAutoReadNotification:) name:RKAutoReadNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveHomeListRefreshNotification:) name:RKHomeListRefresh object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (@available(iOS 13.0, *)) {
        [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDarkContent;
    } else {
        [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    }
    
    // 刷新界面
    if ([RKFileManager shareInstance].isNeedRefresh) {
        [self needReloadData];
        [RKFileManager shareInstance].isNeedRefresh = NO;
    }
}

#pragma mark - 通知
- (void)didReceiveHomeListRefreshNotification:(NSNotification *)notification {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self needReloadData];
    });
    [RKFileManager shareInstance].isNeedRefresh = NO;
}

/// 快速阅读通知
- (void)didReceiveQuickReadNotification:(NSNotification *)notification {
    [self tableView:self.tableView didSelectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
}

- (void)didReceiveAutoReadNotification:(NSNotification *)notification {
    RKUserConfig *config = [RKUserConfig sharedInstance];
    RKBook *autoRead;
    for (RKBook *book in [[RKFileManager shareInstance] getAllBookList]) {
        if ([book.name isEqualToString:config.lastReadBookName]) {
            if (book.isSecret && !config.isSecretAutoOpen) {
                [self didReceiveQuickReadNotification:nil];
                return;
            }
            autoRead = book;
        }
    }
    if (autoRead) {
        if (autoRead.isSecret) {
            __weak typeof(self) weakSelf = self;
            [RKTouchFaceIDUtil requestAuthenticationEvaluatePolicy:YES localizedReason:@"Check Auth" result:^(BOOL success) {
                if (success) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [weakSelf startReadWithBook:autoRead];
                    });
                }
            }];
        } else {
            [self startReadWithBook:autoRead];
        }
    }
}

#pragma mark - 函数
/// 布局UI
- (void)initUI {
    // 设置按钮
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"设置"] style:UIBarButtonItemStylePlain target:self action:@selector(settingClick)];
    
    // 加密
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"锁定"] style:UIBarButtonItemStylePlain target:self action:@selector(secretClick)];
    
    UITableView *tableView = [UITableView new];
    self.tableView = tableView;
    [self.view addSubview:self.tableView];
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.rowHeight = 110;
    tableView.alwaysBounceVertical = YES;
    tableView.tableFooterView = [UIView new];
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.equalTo(self.view);
    }];
}

- (RKBook *)analysisBookContentWithBook:(RKBook *)book {
    // 获取内容
    if (book.content.length == 0) {
        RKLoadingView *loadingView = [[RKLoadingView alloc] initWithMessage:@"加载中..."];
        [loadingView showInView:self.view];
        
        // 加载内容
        book.content = [[RKFileManager shareInstance] encodeWithFilePath:book.path];
        
        if (book.content.length == 0) {
            [loadingView stop];
            RKAlertMessage(@"解析失败,请确认编码格式", self.view);
            return nil;
        }
        [loadingView stop];
    }
    
    // 读取章节数据
    if ([book.chapters count] == 0) {
        NSString *path = [NSString stringWithFormat:@"%@/%@.plist",kBookAnalysisPath,book.bookID];
        NSMutableArray *array = [NSMutableArray array];
        for (NSDictionary *dict in [NSMutableArray arrayWithContentsOfFile:path]) {
            RKChapter *chapter = [RKChapter mj_objectWithKeyValues:dict];
            [array addObject:chapter];
        }
        book.chapters = array;
        RKChapter *chapter = array[book.currentChapterNum];
        book.currentChapter = chapter;
    }
    
    // 重新解析章节
    if (book.isNeedRefreshChapters) {
        NSMutableArray *chaptersArray = [NSMutableArray array];
        [[RKFileManager shareInstance] separateChapter:&chaptersArray content:book.content];
        if ([chaptersArray count] > 0) {
            book.chapters = chaptersArray;
            [[RKFileManager shareInstance] saveChaptersWithBook:book];
        }
        
        NSMutableArray *bookList = [[RKFileManager shareInstance] getAllBookList];
        
        for (RKBook *subBook in bookList) {
            if ([subBook.bookID isEqualToString:book.bookID]) {
                subBook.isNeedRefreshChapters = NO;
            }
        }
        [[RKFileManager shareInstance] saveBookList:bookList];
        [self needReloadData];
    }
    
    return book;
}

- (void)needReloadData {
    // 原数组
    NSMutableArray *books = self.dataArray;
    // 新数组
    self.dataArray = [[RKFileManager shareInstance] getAllBookListWithSecret:NO];
    
    // 原数组加载过的内容赋值到新数组
    for (RKBook *originBook in books) {
        for (RKBook *newBook in self.dataArray) {
            if ([originBook.bookID isEqualToString:newBook.bookID]) {
                newBook.content = originBook.content;
                newBook.chapters = originBook.chapters;
            }
        }
    }
    
    [self.tableView reloadData];
}

/// 开始阅读
/// @param book 书籍对象
- (void)startReadWithBook:(RKBook *)book {
    RKBook *analysisBook = [self analysisBookContentWithBook:book];
    if (analysisBook) {
        [self openBook:analysisBook];
    }
}

- (void)openBook:(RKBook *)book {
    // 创建阅读页面
    RKReadPageViewController *readPageVC = [[RKReadPageViewController alloc] init];
    readPageVC.book = book;
    readPageVC.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:readPageVC animated:YES completion:nil];
}

- (void)jumpToSecret {
    RKSecretViewController *secretVC = [RKSecretViewController new];
    [self.navigationController pushViewController:secretVC animated:YES];
}

#pragma mark - 点击事件
- (void)settingClick {
    RKSettingViewController *settingVC = [RKSettingViewController new];
    [self.navigationController pushViewController:settingVC animated:YES];
}

- (void)secretClick {
    
    RKPinViewController *pinVC = [[RKPinViewController alloc] initWithDelegate:self];
    
    self.navigationController.view.tag = RKPinViewControllerContentViewTag;
    pinVC.translucentBackground = YES;
    
    [self presentViewController:pinVC animated:YES completion:nil];
}

#pragma mark - delegate
#pragma mark -- UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"RKHomeListTableViewCell";
    RKHomeListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (!cell) {
        cell = [[RKHomeListTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    // 注册需要实现 Touch 效果的view， 这里是 用力按下cell,弹出预览小视图，同时上滑底部出现若干个选项（peek功能）
    // 首先判断设备系统是否支持，否则会崩溃
    if ([self respondsToSelector:@selector(traitCollection)]) {
        if ([self.traitCollection respondsToSelector:@selector(forceTouchCapability)]) {
            if (self.traitCollection.forceTouchCapability == UIForceTouchCapabilityAvailable) {
                [self registerForPreviewingWithDelegate:self sourceView:cell];
            }
        }
    }
    
    RKBook *book = self.dataArray[indexPath.row];
    cell.book = book;
    
    return cell;
}

#pragma mark -- UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    RKBook *book = self.dataArray[indexPath.row];
    
    [self startReadWithBook:book];
}

- (UISwipeActionsConfiguration *)tableView:(UITableView *)tableView leadingSwipeActionsConfigurationForRowAtIndexPath:(NSIndexPath *)indexPath  API_AVAILABLE(ios(11.0)) {
    
    __weak typeof(self) weakSelf = self;
    RKHomeListTableViewCell *listCell = [tableView cellForRowAtIndexPath:indexPath];
    RKBook *book = listCell.book;
    
    // 解密
    NSString *secretTitle = book.isSecret ? @"解密":@"隐藏";
    UIContextualAction *secretAction = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleNormal title:secretTitle handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL)) {
        NSMutableArray *bookList = [[RKFileManager shareInstance] getAllBookList];
        
        for (RKBook *subBook in bookList) {
            if ([subBook.bookID isEqualToString:book.bookID]) {
                subBook.isSecret = !book.isSecret;
            }
        }
        
        [[RKFileManager shareInstance] saveBookList:bookList];
        [weakSelf needReloadData];
    }];
    secretAction.backgroundColor = [UIColor colorWithHexString:@"8abcd1"];
    
    return [UISwipeActionsConfiguration configurationWithActions:@[secretAction]];
}

- (UISwipeActionsConfiguration *)tableView:(UITableView *)tableView trailingSwipeActionsConfigurationForRowAtIndexPath:(nonnull NSIndexPath *)indexPath API_AVAILABLE(ios(11.0)) {
    
    __weak typeof(self) weakSelf = self;
    RKHomeListTableViewCell *listCell = [tableView cellForRowAtIndexPath:indexPath];
    RKBook *book = listCell.book;
    
    // 删除
    UIContextualAction *deleteAction = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleNormal title:@"删除" handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL)) {
        
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"是否删除"  message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        
        // 创建并添加按钮
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            DDLogInfo(@"---- xxxxx");
            [[RKFileManager shareInstance] deleteBookWithName:book.name];
            [[RKFileManager shareInstance] setIsNeedRefresh:NO];
            NSInteger bookIndex = [weakSelf.dataArray indexOfObject:book];
            if (bookIndex != NSNotFound) {
                if (weakSelf.dataArray.count >= bookIndex) {
                    [weakSelf.dataArray removeObjectAtIndex:bookIndex];
                    [weakSelf.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:bookIndex inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
                }
            }
        }];
        
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
        
        [alertController addAction:okAction];           // A
        [alertController addAction:cancelAction];       // B
        
        if (kIsPad) {
            alertController.popoverPresentationController.sourceView = listCell;
//            alertController.popoverPresentationController.sourceRect = listCell.frame;
        }
        
        [self presentViewController:alertController animated:YES completion:nil];
    }];
    
    
    deleteAction.backgroundColor = [UIColor colorWithHexString:@"f03752"];
    
    // 置顶
    NSString *topTitle = book.isTop ? @"取消置顶" : @"置顶";
    UIContextualAction *pinAction = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleNormal title:topTitle handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL)) {
        book.isTop = !book.isTop;
        
        NSMutableArray *bookList = [[RKFileManager shareInstance] getAllBookList];
        
        for (RKBook *subBook in bookList) {
            if ([subBook.bookID isEqualToString:book.bookID]) {
                subBook.isTop = book.isTop;
            }
        }
        
        [[RKFileManager shareInstance] saveBookList:bookList];
        [weakSelf needReloadData];
    }];
    UIColor *topColor = book.isTop ? [UIColor colorWithHexString:@"f1939c"] : [UIColor colorWithHexString:@"f1939c"];
    pinAction.backgroundColor = topColor;
    
    return [UISwipeActionsConfiguration configurationWithActions:@[deleteAction, pinAction]];
}

#pragma mark -- UIViewControllerPreviewingDelegate
// If you return nil, a preview presentation will not be performed
- (nullable UIViewController *)previewingContext:(id <UIViewControllerPreviewing>)previewingContext viewControllerForLocation:(CGPoint)location {
    
    // 获取按压的cell所在行，[previewingContext sourceView]就是按压的那个视图
    NSIndexPath *indexPath = [self.tableView indexPathForCell: (UITableViewCell *)[previewingContext sourceView]];
    
    // 调整不被虚化的范围，按压的那个cell不被虚化
    CGRect rect = CGRectMake(0, 0, self.view.width, 110);
    previewingContext.sourceRect = rect;
    
    RKHomeListTableViewCell *cell = (RKHomeListTableViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
    DDLogVerbose(@"---- %@ ---- book:%@",NSStringFromCGPoint(location),cell.book.name);
    
    RKBook *analysisBook = [self analysisBookContentWithBook:cell.book];
    if (analysisBook) {
        cell.book = analysisBook;
    }
    
    // 创建阅读页面
    RKReadPageViewController *readPageVC = [[RKReadPageViewController alloc] init];
    readPageVC.book = cell.book;
//    RKNavigationController *nav = [[RKNavigationController alloc] initWithRootViewController:readPageVC];
//    readPageVC.recordPreviewActionItems = self.recordPreviewActionItems;

    // 设定预览的界面，preferredContentSize决定了预览视图的大小
//    nav.preferredContentSize = CGSizeMake(0.0f, 500.0f);
    
    return readPageVC;
}

- (void)previewingContext:(id <UIViewControllerPreviewing>)previewingContext commitViewController:(UIViewController *)viewControllerToCommit {
    viewControllerToCommit.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:viewControllerToCommit animated:YES completion:nil];
}

#pragma mark --
- (NSUInteger)pinLengthForPinViewController:(RKPinViewController *)pinViewController {
    return 4;
}

- (BOOL)pinViewController:(RKPinViewController *)pinViewController isPinValid:(NSString *)pin {
    return [pin isEqualToString:@"0000"];
}

- (BOOL)userCanRetryInPinViewController:(RKPinViewController *)pinViewController {
    return YES;
}

- (void)incorrectPinEnteredInPinViewController:(RKPinViewController *)pinViewController {
    DDLogDebug(@"---- incorrectPinEntered");
}

- (void)pinViewControllerWillDismissAfterPinEntryWasSuccessful:(RKPinViewController *)pinViewController {
    DDLogDebug(@"---- WillDismiss WasSuccessful");
    [self jumpToSecret];
}

- (void)pinViewControllerDidDismissAfterPinEntryWasSuccessful:(RKPinViewController *)pinViewController {
    DDLogDebug(@"---- DidDismiss WasSuccessful");
}

#pragma mark - getting
- (NSMutableArray *)dataArray {
    if (!_dataArray) {
        _dataArray = [[RKFileManager shareInstance] getAllBookListWithSecret:NO];
    }
    return _dataArray;
}

@end
