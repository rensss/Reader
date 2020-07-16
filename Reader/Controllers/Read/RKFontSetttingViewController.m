//
//  RKFontSetttingViewController.m
//  Reader
//
//  Created by Rzk on 2019/8/19.
//  Copyright © 2019 Rzk. All rights reserved.
//

#import "RKFontSetttingViewController.h"

#define kFontSize 18

@interface RKFontSetttingViewController () <UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView; /**< 列表*/
@property (nonatomic, strong) NSMutableArray *dataArray; /**< 数据源*/

@property (nonatomic, copy) NSString *selectFontName; /**< 选中的字体名*/
@property (nonatomic, assign) NSInteger index; /**< 选中的index*/

@end

@implementation RKFontSetttingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"字体设置";
    
    UIBarButtonItem *saveItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(saveClick)];
    self.navigationItem.rightBarButtonItem = saveItem;
    
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.view);
    }];
    
//    for (NSString *familyNames in [UIFont familyNames]) {
//        DDLogInfo(@"---- %@",familyNames);
//        for (NSString *fontName in [UIFont fontNamesForFamilyName:familyNames]) {
//            DDLogInfo(@"---- \t%@",fontName);
//        }
//    }
}

#pragma mark - 点击事件
- (void)saveClick {
    
    if (self.callBack) {
        RKUserConfig *userConfig = [RKUserConfig sharedInstance];
        userConfig.fontName = self.selectFontName;
        self.callBack();
    }
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - 代理
#pragma mark -- UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    // 取消前一个选中的，就是单选啦
    //self.index设为全局变量出初始化为－1，
    NSIndexPath *lastIndex = [NSIndexPath indexPathForRow:self.index inSection:0];
    UITableViewCell *lastCell = [tableView cellForRowAtIndexPath:lastIndex];
    lastCell.accessoryType = UITableViewCellAccessoryNone;
    
    // 选中操作
    UITableViewCell *cell = [tableView  cellForRowAtIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
    // 保存选中的行
    self.index = indexPath.row;
    
    if ([self.dataArray[indexPath.row] isEqualToString:@"系统"]) {
        self.selectFontName = @"";
    }
    
    if ([self.dataArray[indexPath.row] isEqualToString:@"雅痞"]) {
        self.selectFontName = @"YuppySC-Regular";
    }
    
    if ([self.dataArray[indexPath.row] isEqualToString:@"凌慧体"]) {
        self.selectFontName = @"MLingWaiMedium-SC";
    }
    
    if ([self.dataArray[indexPath.row] isEqualToString:@"手札体"]) {
        self.selectFontName = @"HannotateSC-W5";
    }
    
    if ([self.dataArray[indexPath.row] isEqualToString:@"翩翩体"]) {
        self.selectFontName = @"HanziPenSC-W5";
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
        cell.textLabel.font = [UIFont systemFontOfSize:kFontSize];
        if ([[RKUserConfig sharedInstance].fontName length] == 0) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
            self.index = indexPath.row;
        }
    }
    
    if ([self.dataArray[indexPath.row] isEqualToString:@"雅痞"]) {
        cell.textLabel.font = [UIFont fontWithName:@"YuppySC-Regular" size:kFontSize];
        if ([[RKUserConfig sharedInstance].fontName isEqualToString:@"YuppySC-Regular"]) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
            self.index = indexPath.row;
        }
    }
    
    if ([self.dataArray[indexPath.row] isEqualToString:@"凌慧体"]) {
        cell.textLabel.font = [UIFont fontWithName:@"MLingWaiMedium-SC" size:kFontSize];
        if ([[RKUserConfig sharedInstance].fontName isEqualToString:@"MLingWaiMedium-SC"]) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
            self.index = indexPath.row;
        }
    }
    
    if ([self.dataArray[indexPath.row] isEqualToString:@"手札体"]) {
        cell.textLabel.font = [UIFont fontWithName:@"HannotateSC-W5" size:kFontSize];
        if ([[RKUserConfig sharedInstance].fontName isEqualToString:@"HannotateSC-W5"]) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
            self.index = indexPath.row;
        }
    }
    
    if ([self.dataArray[indexPath.row] isEqualToString:@"翩翩体"]) {
        cell.textLabel.font = [UIFont fontWithName:@"HanziPenSC-W5" size:kFontSize];
        if ([[RKUserConfig sharedInstance].fontName isEqualToString:@"HanziPenSC-W5"]) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
            self.index = indexPath.row;
        }
    }
    
    return cell;
}

#pragma mark - getting
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] init];
        
        _tableView.delegate = self;
        _tableView.dataSource = self;
        
//        _tableView.allowsMultipleSelectionDuringEditing = YES;
//        [_tableView setEditing:YES animated:YES];
        
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
                      @"翩翩体",
                      nil];
    }
    return _dataArray;
}

@end
