//
//  RKReadSettingViewController.m
//  Reader
//
//  Created by Rzk on 2019/8/19.
//  Copyright © 2019 Rzk. All rights reserved.
//

#import "RKReadSettingViewController.h"
#import "RKSelectImageViewController.h"
#import "RKFontSetttingViewController.h"

@interface RKReadSettingViewController () <UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView; /**< 列表*/
@property (nonatomic, strong) NSMutableArray *dataArray; /**< 数据源*/

@property (nonatomic, copy) void(^callBack)(void); /**< 回调*/

@end

@implementation RKReadSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"设置";
    
    UIBarButtonItem *doneItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneClick)];
    self.navigationItem.rightBarButtonItem = doneItem;
    
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.view);
    }];
}

#pragma mark - 点击事件
- (void)doneClick {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)switchChangeValue:(UISwitch *)switchBtn {
    [RKUserConfig sharedInstance].isRefreshTop = switchBtn.on;
}

#pragma mark - func
/**
 刷新回调
 @param handler 回调
 */
- (void)needRefresh:(void(^)(void))handler {
    self.callBack = handler;
}

#pragma mark - 代理
#pragma mark -- UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if ([self.dataArray[indexPath.row] isEqualToString:@"封面图"]) {
        RKSelectImageViewController *selectImageVC = [[RKSelectImageViewController alloc] init];
        selectImageVC.book = self.book;
        selectImageVC.type = RKSelectImageTypeCoverImage;
        [self.navigationController pushViewController:selectImageVC animated:YES];
    }
    
    if ([self.dataArray[indexPath.row] isEqualToString:@"背景图"]) {
        RKSelectImageViewController *selectImageVC = [[RKSelectImageViewController alloc] init];
        selectImageVC.type = RKSelectImageTypeBgImage;
        selectImageVC.callBack = self.callBack;
        [self.navigationController pushViewController:selectImageVC animated:YES];
    }
    
    if ([self.dataArray[indexPath.row] isEqualToString:@"字体"]) {
        RKFontSetttingViewController *fontVC = [[RKFontSetttingViewController alloc] init];
        fontVC.callBack = self.callBack;
        [self.navigationController pushViewController:fontVC animated:YES];
    }
}

#pragma mark -- UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.dataArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([UITableViewCell class])];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:NSStringFromClass([UITableViewCell class])];
    }
    
    cell.textLabel.text = self.dataArray[indexPath.row];
    
    if ([self.dataArray[indexPath.row] isEqualToString:@"置顶是否按时间排序"]) {
        UISwitch *switchBtn = [[UISwitch alloc] init];
        cell.accessoryView = switchBtn;
        switchBtn.on = [RKUserConfig sharedInstance].isRefreshTop;
        switchBtn.tag = 10000;
        [switchBtn addTarget:self action:@selector(switchChangeValue:) forControlEvents:UIControlEventValueChanged];
    }
    
    return cell;
}

#pragma mark - getting
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] init];
        
        _tableView.delegate = self;
        _tableView.dataSource = self;
        
        _tableView.tableFooterView = [UIView new];
    }
    return _tableView;
}

- (NSMutableArray *)dataArray {
    if (!_dataArray) {
        _dataArray = [NSMutableArray arrayWithObjects:
                      @"置顶是否按时间排序",
                      @"封面图",
                      @"背景图",
                      @"字体",
                      nil];
    }
    return _dataArray;
}

@end
