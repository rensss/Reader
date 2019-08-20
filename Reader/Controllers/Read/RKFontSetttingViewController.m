//
//  RKFontSetttingViewController.m
//  Reader
//
//  Created by Rzk on 2019/8/19.
//  Copyright © 2019 Rzk. All rights reserved.
//

#import "RKFontSetttingViewController.h"

@interface RKFontSetttingViewController () <UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView; /**< 列表*/
@property (nonatomic, strong) NSMutableArray *dataArray; /**< 数据源*/

@end

@implementation RKFontSetttingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"字体设置";
    
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.view);
    }];
    
    for (NSString *familyNames in [UIFont familyNames]) {
        RKLog(@"---- %@",familyNames);
        for (NSString *fontName in [UIFont fontNamesForFamilyName:familyNames]) {
            RKLog(@"---- \t%@",fontName);
        }
    }
}

#pragma mark - 代理
#pragma mark -- UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if ([self.dataArray[indexPath.row] isEqualToString:@"封面图"]) {
        
    }
    
    if ([self.dataArray[indexPath.row] isEqualToString:@"背景图"]) {
        
    }
    
    if ([self.dataArray[indexPath.row] isEqualToString:@"字体"]) {
        
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
    
    if ([self.dataArray[indexPath.row] isEqualToString:@"系统"]) {
        cell.textLabel.font = [UIFont systemFontOfSize:14];
    }
    
    if ([self.dataArray[indexPath.row] isEqualToString:@"雅痞"]) {
        cell.textLabel.font = [UIFont fontWithName:@"YuppySC-Regular" size:14];
    }
    
    if ([self.dataArray[indexPath.row] isEqualToString:@"凌慧体"]) {
        cell.textLabel.font = [UIFont fontWithName:@"MLingWaiMedium-SC" size:14];
    }
    
    if ([self.dataArray[indexPath.row] isEqualToString:@"手札体"]) {
        cell.textLabel.font = [UIFont fontWithName:@"HannotateSC-W5" size:14];
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
                      @"系统",
                      @"雅痞",
                      @"凌慧体",
                      @"手札体",
                      nil];
    }
    return _dataArray;
}

@end
