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

@interface RKHomeListViewController () <UITableViewDelegate,UITableViewDataSource,SWTableViewCellDelegate>

@property (nonatomic, strong) UITableView *tableView; /**< 列表*/
@property (nonatomic, strong) NSMutableArray *dataArray; /**< 数据源*/

@end

@implementation RKHomeListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"Reader";
    
    [self initUI];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // 刷新界面
    if ([RKFileManager shareInstance].isNeedRefresh) {
        // 原数组
        NSMutableArray *books = self.dataArray;
        // 新数组
        self.dataArray = [[RKFileManager shareInstance] getHomeList];
        
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
        [RKFileManager shareInstance].isNeedRefresh = NO;
    }
}

#pragma mark - 函数
/// 布局UI
- (void)initUI {
    // 设置按钮
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"设置"] style:UIBarButtonItemStylePlain target:self action:@selector(settingClick)];
    
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

- (void)settingClick {
    RKSettingViewController *settingVC = [RKSettingViewController new];
    [self.navigationController pushViewController:settingVC animated:YES];
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
    
    RKBook *book = self.dataArray[indexPath.row];
    cell.book = book;
    
    NSMutableArray *btns = [NSMutableArray array];
    // 删除
    NSAttributedString *delete = [[NSAttributedString alloc] initWithString:@"删除"
                                                               attributes:@{
                                                                            NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue-Medium" size:16],
                                                                            NSForegroundColorAttributeName: [UIColor whiteColor]
                                                                            }];
    [btns sw_addUtilityButtonWithColor:[UIColor redColor] attributedTitle:delete];
    [cell setRightUtilityButtons:btns WithButtonWidth:80.0f];
    
    // 置顶
    NSString *topTitle = @"置顶";
    if (book.isTop) {
        topTitle = @"取消置顶";
    }
    NSAttributedString *top = [[NSAttributedString alloc] initWithString:topTitle
                                                              attributes:@{
                                                                           NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue-Medium" size:16],
                                                                           NSForegroundColorAttributeName: [UIColor whiteColor]
                                                                           }];
    [btns sw_addUtilityButtonWithColor:[UIColor colorWithHexString:@"c8402d"] attributedTitle:top];
    [cell setRightUtilityButtons:btns WithButtonWidth:80.0f];
    
    cell.delegate = self;
    
    return cell;
}


#pragma mark -- UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    RKBook *book = self.dataArray[indexPath.row];
    if (book.content.length == 0) {
        RKLoadingView *loadingView = [[RKLoadingView alloc] initWithMessage:@"加载中..."];
        [loadingView showInView:self.view];
        
        // 加载内容
        book.content = [[RKFileManager shareInstance] encodeWithFilePath:book.path];
        
        if (book.content.length == 0) {
            [loadingView stop];
            RKAlertMessage(@"解析失败,请确认编码格式", self.view);
            return;
        }
        [loadingView stop];
    }
    
    // 读取章节数据
    NSString *path = [NSString stringWithFormat:@"%@/%@.plist",kBookAnalysisPath,book.bookID];
    NSMutableArray *array = [NSMutableArray array];
    for (NSDictionary *dict in [NSMutableArray arrayWithContentsOfFile:path]) {
        RKChapter *chapter = [RKChapter mj_objectWithKeyValues:dict];
        [array addObject:chapter];
    }
    book.chapters = array;
    RKChapter *chapter = array[book.currentChapterNum];
    chapter.content = [book.content substringWithRange:NSMakeRange(chapter.location, chapter.length)];
    book.currentChapter = chapter;
    
    // 创建阅读页面
    RKReadPageViewController *readPageVC = [[RKReadPageViewController alloc] init];
    readPageVC.book = book;
    RKNavigationController *nav = [[RKNavigationController alloc] initWithRootViewController:readPageVC];
    [self presentViewController:nav animated:YES completion:nil];
}

#pragma mark -- SWTableViewCellDelegate
- (BOOL)swipeableTableViewCell:(SWTableViewCell *)cell canSwipeToState:(SWCellState)state {
    return YES;
}

- (BOOL)swipeableTableViewCellShouldHideUtilityButtonsOnSwipe:(SWTableViewCell *)cell {
    return YES;
}

- (void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerRightUtilityButtonWithIndex:(NSInteger)index {
    RKLog(@"---- index:%ld",(long)index);
    
    RKHomeListTableViewCell *listCell = (RKHomeListTableViewCell *)cell;
    RKBook *book = listCell.book;
    if (index == 0) {
        [[RKFileManager shareInstance] deleteBookWithName:book.name];
        [[RKFileManager shareInstance] setIsNeedRefresh:NO];
        NSInteger bookIndex = [self.dataArray indexOfObject:book];
        [self.dataArray removeObjectAtIndex:bookIndex];
        [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:bookIndex inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
    }
    
    if (index == 1) {
        book.isTop = !book.isTop;
        
        if (book.isTop) {
            [self.dataArray removeObject:book];
            [self.dataArray insertObject:book atIndex:0];
        } else {
            NSInteger index = 0;
            for (RKBook *subBook in self.dataArray) {
                if (subBook.isTop) {
                    index++;
                }
            }
            
            [self.dataArray removeObject:book];
            if (index == 0) {
                [self.dataArray insertObject:book atIndex:0];
            } else {
                if (index > [self.dataArray count]) {
                    [self.dataArray addObject:book];
                } else {
                    [self.dataArray insertObject:book atIndex:index];
                }
            }
        }
        
        [[RKFileManager shareInstance] saveBookList:self.dataArray];
        
        [self.tableView reloadData];
    }
}

#pragma mark - getting
- (NSMutableArray *)dataArray {
    if (!_dataArray) {
        _dataArray = [[RKFileManager shareInstance] getHomeList];
    }
    return _dataArray;
}

@end
