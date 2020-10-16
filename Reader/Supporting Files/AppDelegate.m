//
//  AppDelegate.m
//  Reader
//
//  Created by Rzk on 2019/4/22.
//  Copyright © 2019 Rzk. All rights reserved.
//

#import "AppDelegate.h"
#import "RKHomeListViewController.h"
#import "RKBookImprotViewController.h"
#import "RKReadPageViewController.h"
#import "RKLogFormatter.h"

@interface AppDelegate ()


@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    if (@available(iOS 9.1, *)) {
        UIApplicationShortcutIcon *quickReadIcon = [UIApplicationShortcutIcon iconWithType:UIApplicationShortcutIconTypeBookmark];
        UIApplicationShortcutItem *quickRead = [[UIApplicationShortcutItem alloc] initWithType:RKShortcutQuickReadItemType localizedTitle:@"快速阅读" localizedSubtitle:nil icon:quickReadIcon userInfo:nil];
        
        UIApplicationShortcutIcon *importIcon = [UIApplicationShortcutIcon iconWithType:UIApplicationShortcutIconTypeInvitation];
        UIApplicationShortcutItem *importBook = [[UIApplicationShortcutItem alloc] initWithType:RKShortcutImportItemType localizedTitle:@"导入书籍" localizedSubtitle:nil icon:importIcon userInfo:nil];
        
        application.shortcutItems = @[quickRead, importBook];
    }
    // log初始化
    // 添加DDASLLogger，你的日志语句将被发送到Xcode控制台
//    if (@available(iOS 10.0, *)) {
//        [DDLog addLogger:[DDOSLogger sharedInstance]];
//        [DDOSLogger sharedInstance].logFormatter = [[RKLogFormatter alloc] init];
//    } else {
        [DDLog addLogger:[DDTTYLogger sharedInstance]];
        [DDTTYLogger sharedInstance].logFormatter = [[RKLogFormatter alloc] init];
//    }
    // 添加DDFileLogger，你的日志语句将写入到一个文件中，默认路径在沙盒的Library/Caches/Logs/目录下，文件名为bundleid+空格+日期.log。
    DDFileLogger *fileLogger = [[DDFileLogger alloc] init];
    fileLogger.rollingFrequency = 60 * 60 * 24;
    fileLogger.logFileManager.maximumNumberOfLogFiles = 7;
    [DDLog addLogger:fileLogger];
        
    // 初始化
    [RKFileManager shareInstance];
    // 首页
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    RKHomeListViewController *listVC = [[RKHomeListViewController alloc] init];
    RKNavigationController *nav = [[RKNavigationController alloc] initWithRootViewController:listVC];
    self.window.rootViewController = nav;
    [self.window makeKeyAndVisible];
    
    // 自动打开阅读
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if ([RKUserConfig sharedInstance].isAutoRead) {
            [[NSNotificationCenter defaultCenter] postNotificationName:RKAutoReadNotification object:nil];
        }
    });
    
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
    /*
     当应用进入后台，什么时候会被系统杀死，并不会通知app。那么如果需要什么状态记录的话，需放在此函数中。
     */
    
    // 隐藏
    [RKFileManager shareInstance].isNeedRefresh = YES;
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    if ([[[UIDevice currentDevice] systemVersion] compare:@"9.0" options:NSNumericSearch] != NSOrderedAscending) {
        // 用于处理来自 ShortcutItem 的唤醒动作，我们的 App 一开始有一大堆的界面广告之类的，调用早的话，tabbarController 还没创建，就没办法定位发动跳转的界面了
        // 所以还是稍等下，等 tabbarController 创建好了我们再继续处理跳转逻辑
        // 另外，这里仅仅处理首次启动时来自 ShortcutItem 的跳转逻辑，如果是从后台唤醒的话，请使用 -application:performActionForShortcutItem: completionHandler:这个回调
//        __weak typeof(self) weakSelf = self;
//        [[RACObserve(self, tabbarController) deliverOn:[RACScheduler mainThreadScheduler]] subscribeNext:^(MTGroupTabbarController *tabbarController) {
//            __strong typeof(weakSelf) stongSelf = weakSelf;
//            if (stongSelf.launchedShortcutItem && tabbarController) {
//                [stongSelf handleShortCutItem:stongSelf.launchedShortcutItem];
//
//                // 这里在首次启动完后，将这个 property 置 nil ，以防从后台唤醒的时候重复调用上面的方法
//                stongSelf.launchedShortcutItem = nil;
//            }
//        }];
    }
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // 在后台时被用户杀死 将调用此函数
    DDLogInfo(@"---- Terminate");
}

- (void)application:(UIApplication *)application performActionForShortcutItem:(UIApplicationShortcutItem *)shortcutItem completionHandler:(void (^)(BOOL))completionHandler {
    DDLogInfo(@"shortcut");
    DDLogInfo(@"---- %@",[UIApplication sharedApplication].keyWindow.rootViewController);
    
    if ([shortcutItem.type isEqualToString:RKShortcutQuickReadItemType]) {
        
        if ([[UIApplication sharedApplication].keyWindow.rootViewController isKindOfClass:[RKReadPageViewController class]]) {
            return;
        } else {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:RKShortcutQuickReadItemType object:nil];
            });
        }
    }
    
    if ([shortcutItem.type isEqualToString:RKShortcutImportItemType]) {
        
//        if ([[UIApplication sharedApplication].keyWindow.rootViewController isKindOfClass:[RKNavigationController class]]) {
//            return;
//        }
//        RKBookImprotViewController *importVC = [[RKBookImprotViewController alloc] init];
//        importVC.showType = RKImprotShowTypePresent;
//        RKNavigationController *nav = [[RKNavigationController alloc] initWithRootViewController:importVC];
//        nav.modalPresentationStyle = UIModalPresentationFullScreen;
//        [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:nav animated:YES completion:^{
//            DDLogInfo(@"---- modalPresent");
//        }];
    }
}

#pragma mark - func
// 处理 Quick Action 的跳转操作的方法
- (BOOL)handleShortCutItem:(UIApplicationShortcutItem *)shortcutItem {
    BOOL handled = NO;

    if (!shortcutItem) {
        return NO;
    }

    // 切换到首页
//    MTGroupTabbarController *tabBarController = self.tabbarController;
//    tabBarController.selectedIndex = 0;
//    MTNavigationController *destinationViewController = (MTNavigationController *)tabBarController.selectedViewController;
//    UIViewController *homePageViewController = destinationViewController.topViewController;
//
//    if ([shortcutItem.type isEqualToString:METShortcutSearchItemType]) {
//        handled = YES;
//
//        // 跳转到搜索页面
//        ......
//
//    } else if ([shortcutItem.type isEqualToString:METShortcutCouponItemType]) {
//        handled = YES;
//
//        // 先判断是否有登录，没有的话先登录再跳转美团券列表页
//        ......
//
//    } else if ([shortcutItem.type isEqualToString:METShortcutScanItemType]) {
//        handled = YES;
//
//        // 跳转到扫一扫
//        ......
//
//    } else {
//        // do nothing
//    }

    return handled;
}

@end
