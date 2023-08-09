//
//  RKSettingViewController.m
//  Reader
//
//  Created by Rzk on 2019/4/22.
//  Copyright © 2019 Rzk. All rights reserved.
//

#import "RKSettingViewController.h"
#import "RKBookImprotViewController.h"
#import "RKPinViewController.h"

#define kSwitchTag 10000

@interface RKSettingViewController () <UITableViewDelegate, UITableViewDataSource, RKPinViewControllerDelegate>

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
        case 2:
        {
            [RKUserConfig sharedInstance].isSecretAutoOpen = switchBtn.on;
        }
            break;
        case 3:
        {
            [RKUserConfig sharedInstance].isChapterListAutoScroll = switchBtn.on;
        }
            break;
        case 4:
        {
            [RKUserConfig sharedInstance].isAllowRotation = switchBtn.on;
        }
            break;
        case 5:
        {
            if (switchBtn.on) {
                // 打开密码
                [self pinClick];
            } else {
                // 关闭密码
                [self checkPin];
            }
        }
            break;
            
        case 6:
        {
            if (switchBtn.on) {
                RKUserConfig.sharedInstance.engineType = @"local";
            } else {
                RKUserConfig.sharedInstance.engineType = @"cloud";
            }
        }
            
        default:
            break;
    }
}

#pragma mark - func
- (void)pinClick {
    RKPinViewController *pinVC = [[RKPinViewController alloc] initWithDelegate:self];
    
    self.navigationController.view.tag = RKPinViewControllerContentViewTag;
    pinVC.translucentBackground = YES;
    pinVC.promptTitle = @"设置 Pin 码";
    pinVC.disableAuthentication = YES;
    pinVC.disableAutoAuthentication = YES;
    pinVC.sourceString = @"打开 Pin";

    [self presentViewController:pinVC animated:YES completion:nil];
}

- (void)checkPin {
    RKPinViewController *pinVC = [[RKPinViewController alloc] initWithDelegate:self];
    
    self.navigationController.view.tag = RKPinViewControllerContentViewTag;
    pinVC.translucentBackground = YES;
    pinVC.promptTitle = @"输入 Pin 码";
    pinVC.disableAuthentication = NO;
    pinVC.disableAutoAuthentication = NO;
    pinVC.sourceString = @"关闭 Pin";
    
    __weak typeof(self) weakSelf = self;
    [pinVC pinVCDidDisappear:^{
        [weakSelf.tableView reloadData];
    }];
    
    [self presentViewController:pinVC animated:YES completion:nil];
}

/// 根据 tag 获取 switch 的值
/// @param tag tag
- (BOOL)getSwichValueWithTag:(NSInteger)tag {
    UISwitch *switchView = [self.view viewWithTag:tag];
    return switchView.on;
}

- (void)jumpToImport {
    RKBookImprotViewController *importVC = [[RKBookImprotViewController alloc] init];
    importVC.showType = RKImprotShowTypePresent;
    RKNavigationController *nav = [[RKNavigationController alloc] initWithRootViewController:importVC];
    nav.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:nav animated:YES completion:nil];
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
    if (cell.accessoryView) {
        UIView *switchView = cell.accessoryView;
        [switchView removeFromSuperview];
        cell.accessoryView = nil;
    }
    
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
    
    if ([self.dataArr[indexPath.row] isEqualToString:@"加密书籍是否自动打开"]) {
        UISwitch *switchBtn = [[UISwitch alloc] init];
        cell.accessoryView = switchBtn;
        switchBtn.on = [RKUserConfig sharedInstance].isSecretAutoOpen;
        switchBtn.tag = kSwitchTag + 2;
        [switchBtn addTarget:self action:@selector(switchChangeValue:) forControlEvents:UIControlEventValueChanged];
    }
    
    if ([self.dataArr[indexPath.row] isEqualToString:@"目录是否自动滚动"]) {
        UISwitch *switchBtn = [[UISwitch alloc] init];
        cell.accessoryView = switchBtn;
        switchBtn.on = [RKUserConfig sharedInstance].isChapterListAutoScroll;
        switchBtn.tag = kSwitchTag + 3;
        [switchBtn addTarget:self action:@selector(switchChangeValue:) forControlEvents:UIControlEventValueChanged];
    }
    
    if ([self.dataArr[indexPath.row] isEqualToString:@"是否允许横屏"]) {
        UISwitch *switchBtn = [[UISwitch alloc] init];
        cell.accessoryView = switchBtn;
        switchBtn.on = [RKUserConfig sharedInstance].isAllowRotation;
        switchBtn.tag = kSwitchTag + 4;
        [switchBtn addTarget:self action:@selector(switchChangeValue:) forControlEvents:UIControlEventValueChanged];
    }
    
    if ([self.dataArr[indexPath.row] isEqualToString:@"是否打开 Pin"]) {
        UISwitch *switchBtn = [[UISwitch alloc] init];
        cell.accessoryView = switchBtn;
        switchBtn.on = [RKUserConfig sharedInstance].pinString.length > 0;
        switchBtn.tag = kSwitchTag + 5;
        [switchBtn addTarget:self action:@selector(switchChangeValue:) forControlEvents:UIControlEventValueChanged];
    }
    
    if ([self.dataArr[indexPath.row] isEqualToString:@"是否使用本地阅读引擎"]) {
        UISwitch *switchBtn = [[UISwitch alloc] init];
        cell.accessoryView = switchBtn;
        switchBtn.on = [[RKUserConfig sharedInstance].engineType isEqualToString:@"local"];
        switchBtn.tag = kSwitchTag + 6;
        [switchBtn addTarget:self action:@selector(switchChangeValue:) forControlEvents:UIControlEventValueChanged];
    }
    
    return cell;
}

#pragma mark -- UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    if ([self.dataArr[indexPath.row] isEqualToString:@"局域网导入"]) {
        if (RKUserConfig.sharedInstance.pinString.length == 0) {
            [self jumpToImport];
            return;
        }
        
        RKPinViewController *pinVC = [[RKPinViewController alloc] initWithDelegate:self];
        
        self.navigationController.view.tag = RKPinViewControllerContentViewTag;
        pinVC.translucentBackground = YES;
        pinVC.promptColor = [UIColor blackColor];
        pinVC.sourceString = @"局域网导入";
        
        [self presentViewController:pinVC animated:YES completion:nil];
        
    }
    
    if ([self.dataArr[indexPath.row] isEqualToString:@"删除全部书籍"]) {
        
        __weak typeof(self) weakSelf = self;
        
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"是否删除全部数据"  message:@"将会清空书籍和阅读记录!" preferredStyle:UIAlertControllerStyleActionSheet];
        
        // 创建并添加按钮
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            DDLogDebug(@"是否是主线程 ------- %@",[NSThread isMainThread]?@"YES":@"NO");
            RKLoadingView *loadingView = [[RKLoadingView alloc] initWithMessage:@"删除中..."];
            [loadingView showInView:weakSelf.view];
            
            // 计算代码运行时间
            CFAbsoluteTime startTime = CFAbsoluteTimeGetCurrent();
            
            [[RKFileManager shareInstance] clearAllBooksWithResult:^(BOOL isSuccess) {
                
                CFAbsoluteTime linkTime = (CFAbsoluteTimeGetCurrent() - startTime);
                // 打印运行时间
                DDLogDebug(@"Linked in %f ms", linkTime * 1000.0);
                [loadingView stop];
                [RKFileManager shareInstance].isNeedRefresh = YES;
                
                DDLogDebug(@"是否是主线程 ------- %@",[NSThread isMainThread]?@"YES":@"NO");
                
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
        
        if (kIsPad) {
            alertController.popoverPresentationController.sourceView = cell;
            alertController.popoverPresentationController.sourceRect = cell.frame;
        }
        
        [self presentViewController:alertController animated:YES completion:nil];
    }
}

#pragma mark -- RKPinViewControllerDelegate
- (NSUInteger)pinLengthForPinViewController:(RKPinViewController *)pinViewController {
    return 4;
}

- (BOOL)pinViewController:(RKPinViewController *)pinViewController isPinValid:(NSString *)pin {
    DDLogDebug(@"---- pin:%@", pin);
    
    if ([pinViewController.sourceString isEqualToString:@"关闭 Pin"]) {
        if ([RKUserConfig.sharedInstance.pinString isEqualToString:pin]) {
            RKUserConfig.sharedInstance.pinString = @"";
            return YES;
        } else {
            return NO;
        }
    }
    
    if ([pinViewController.sourceString isEqualToString:@"局域网导入"]) {
        return [RKUserConfig.sharedInstance.pinString isEqualToString:pin];
    }
    
    if ([pinViewController.sourceString isEqualToString:@"打开 Pin"]) {
        RKUserConfig.sharedInstance.pinString = pin;
        return YES;
    }
    
    return NO;
}

- (BOOL)userCanRetryInPinViewController:(RKPinViewController *)pinViewController {
    return YES;
}

- (void)cancelButtonTappedInpinViewController:(RKPinViewController *)pinViewController {
    [self.tableView reloadData];
}

- (void)pinViewControllerWillDismissAfterPinEntryWasSuccessful:(RKPinViewController *)pinViewController {
    DDLogDebug(@"---- WillDismiss WasSuccessful");
}

- (void)pinViewControllerDidDismissAfterPinEntryWasSuccessful:(RKPinViewController *)pinViewController {
    DDLogDebug(@"---- DidDismiss WasSuccessful");
    
    if ([pinViewController.sourceString isEqualToString:@"关闭 Pin"]) {
        RKUserConfig.sharedInstance.pinString = @"";
        [self.tableView reloadData];
    }
    
    if ([pinViewController.sourceString isEqualToString:@"打开 Pin"]) {
        [self.tableView reloadData];
    }
    
    if ([pinViewController.sourceString isEqualToString:@"局域网导入"]) {
        [self jumpToImport];
    }
}

#pragma mark - getting
- (NSMutableArray *)dataArr {
    if (!_dataArr) {
        _dataArr = [NSMutableArray arrayWithObjects:
                    @"置顶是否按时间排序",
                    @"是否自动阅读",
                    @"加密书籍是否自动打开",
                    @"目录是否自动滚动",
                    @"是否使用本地阅读引擎",
                    @"是否允许横屏",
                    @"是否打开 Pin",
                    @"局域网导入",
                    @"删除全部书籍",
                    nil];
    }
    return _dataArr;
}

@end
