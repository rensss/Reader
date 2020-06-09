//
//  RKSettingViewController.m
//  Reader
//
//  Created by Rzk on 2019/4/22.
//  Copyright © 2019 Rzk. All rights reserved.
//

#import "RKSettingViewController.h"
#import "RKBookImprotViewController.h"

#define kSwitchTag 10000

@interface RKSettingViewController () <UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView; /**< 列表*/
@property (nonatomic, strong) NSMutableArray *dataArr; /**< 数据源*/

@end

@implementation RKSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"设置";
    
    UITableView *tableView = [UITableView new];
    self.tableView = tableView;
    [self.view addSubview:tableView];
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.tableFooterView = [UIView new];
    [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(self.view);
    }];
}

#pragma mark - 事件
- (void)switchChangeValue:(UISwitch *)switchBtn {
    
    switch (switchBtn.tag - kSwitchTag) {
        case 0:
        {
            [RKUserConfig sharedInstance].isRefreshTop = switchBtn.on;
        }
            break;
        case 1:
        {
            [RKUserConfig sharedInstance].isAutoRead = switchBtn.on;
        }
            break;
            
        default:
            break;
    }
}


#pragma mark - delegate
#pragma mark -- UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"UITableViewCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    cell.textLabel.text = self.dataArr[indexPath.row];
    
    if ([self.dataArr[indexPath.row] isEqualToString:@"置顶是否按时间排序"]) {
        UISwitch *switchBtn = [[UISwitch alloc] init];
        cell.accessoryView = switchBtn;
        switchBtn.on = [RKUserConfig sharedInstance].isRefreshTop;
        switchBtn.tag = kSwitchTag;
        [switchBtn addTarget:self action:@selector(switchChangeValue:) forControlEvents:UIControlEventValueChanged];
    }
    
    if ([self.dataArr[indexPath.row] isEqualToString:@"是否自动阅读"]) {
        UISwitch *switchBtn = [[UISwitch alloc] init];
        cell.accessoryView = switchBtn;
        switchBtn.on = [RKUserConfig sharedInstance].isAutoRead;
        switchBtn.tag = kSwitchTag + 1;
        [switchBtn addTarget:self action:@selector(switchChangeValue:) forControlEvents:UIControlEventValueChanged];
    }
    
    return cell;
}

#pragma mark -- UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if ([self.dataArr[indexPath.row] isEqualToString:@"局域网导入"]) {
        RKBookImprotViewController *importVC = [[RKBookImprotViewController alloc] init];
        importVC.showType = RKImprotShowTypePresent;
        RKNavigationController *nav = [[RKNavigationController alloc] initWithRootViewController:importVC];
        nav.modalPresentationStyle = UIModalPresentationFullScreen;
        [self presentViewController:nav animated:YES completion:nil];
    }
    
    if ([self.dataArr[indexPath.row] isEqualToString:@"删除全部书籍"]) {
        
        __weak typeof(self) weakSelf = self;
        
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"是否删除全部数据"  message:@"将会清空书籍和阅读记录!" preferredStyle:UIAlertControllerStyleActionSheet];
        
        // 创建并添加按钮
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            RKLog(@"是否是主线程 ------- %@",[NSThread isMainThread]?@"YES":@"NO");
            RKLoadingView *loadingView = [[RKLoadingView alloc] initWithMessage:@"删除中..."];
            [loadingView showInView:weakSelf.view];
            
            // 计算代码运行时间
            CFAbsoluteTime startTime = CFAbsoluteTimeGetCurrent();
            
            [[RKFileManager shareInstance] clearAllBooksWithResult:^(BOOL isSuccess) {
                
                CFAbsoluteTime linkTime = (CFAbsoluteTimeGetCurrent() - startTime);
                // 打印运行时间
                RKLog(@"Linked in %f ms", linkTime * 1000.0);
                [loadingView stop];
                [RKFileManager shareInstance].isNeedRefresh = YES;
                
                RKLog(@"是否是主线程 ------- %@",[NSThread isMainThread]?@"YES":@"NO");
                
                if (isSuccess) {
                    RKAlertMessage(@"删除成功", weakSelf.view);
                } else {
                    RKAlertMessage(@"删除失败", weakSelf.view);
                }
            }];
            
        }];
        
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
        
        [alertController addAction:okAction];           // A
        [alertController addAction:cancelAction];       // B
        
        [self presentViewController:alertController animated:YES completion:nil];
    }
}

#pragma mark - getting
- (NSMutableArray *)dataArr {
    if (!_dataArr) {
        _dataArr = [NSMutableArray arrayWithObjects:
                    @"置顶是否按时间排序",
                    @"是否自动阅读",
                    @"局域网导入",
                    @"删除全部书籍",
                    nil];
    }
    return _dataArr;
}

@end
