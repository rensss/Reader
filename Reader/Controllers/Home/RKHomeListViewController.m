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


@interface RKHomeListViewController () <UITableViewDelegate,UITableViewDataSource>
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
#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"RKHomeListTableViewCell";
    RKHomeListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (!cell) {
        cell = [[RKHomeListTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
//        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    cell.book = self.dataArray[indexPath.row];
    
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}

#pragma mark - getting
- (NSMutableArray *)dataArray {
    if (!_dataArray) {
        _dataArray = [[RKFileManager shareInstance] getHomeList];
    }
    return _dataArray;
}
@end
