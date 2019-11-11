//
//  RKReadPageViewController.m
//  Reader
//
//  Created by Rzk on 2019/4/25.
//  Copyright © 2019 Rzk. All rights reserved.
//

#import "RKReadPageViewController.h"
#import "RKReadViewController.h"
#import "RKReadMenuView.h"
#import "RKReadSettingViewController.h"
#import "RKChaptersListView.h"

@interface RKReadPageViewController ()
<
UIPageViewControllerDelegate,
UIPageViewControllerDataSource,
UIGestureRecognizerDelegate
>

@property (nonatomic, strong) UIPageViewController *pageViewController; /**< 显示内容的VC*/

@property (nonatomic, assign) NSInteger currentChapter; /**< 当前章节*/
@property (nonatomic, assign) NSInteger currentPage; /**< 当前页码*/

@property (nonatomic, assign) NSInteger chapterNext; /**< 上/下 一章节*/
@property (nonatomic, assign) NSInteger pageNext; /**< 上/下 一页*/

@property (nonatomic, assign) BOOL isShowMenu; /**< 是否已弹出菜单*/

@property (nonatomic, strong) NSMutableArray *previewActionArray; /**< 3Dtouch 上滑选项*/

@end

@implementation RKReadPageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 添加点击手势
    [self.view addGestureRecognizer:({
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showToolMenu)];
        tap.delegate = self;
        tap;
    })];
    
    // 设置UIPageViewController的配置项
    NSDictionary *options = @{UIPageViewControllerOptionInterPageSpacingKey : @(80)};
//        NSDictionary *options = @{UIPageViewControllerOptionSpineLocationKey : @(UIPageViewControllerSpineLocationMin)};
    
    // 根据给定的属性实例化UIPageViewController
    _pageViewController = [[UIPageViewController alloc]
                           initWithTransitionStyle:[RKUserConfig sharedInstance].transitionStyle navigationOrientation:[RKUserConfig sharedInstance].navigationOrientation
                           options:options];
    
    // 设置UIPageViewController代理和数据源
    _pageViewController.delegate = self;
    _pageViewController.dataSource = self;
    
    // 让UIPageViewController对象，显示相应的页数据。
    // UIPageViewController对象要显示的页数据封装成为一个NSArray。
    // 因为我们定义UIPageViewController对象显示样式为显示一页（options参数指定）。
    // 如果要显示2页，NSArray中，应该有2个相应页数据。
    
    // 设置UIPageViewController初始化数据, 将数据放在NSArray里面
    // 如果 options 设置了 UIPageViewControllerSpineLocationMid,注意viewControllers至少包含两个数据,且 doubleSided = YES
    
    RKReadViewController *readVC = [self viewControllerChapter:self.book.currentChapterNum andPage:self.book.currentPage];// 得到第一页
    NSArray *viewControllers = [NSArray arrayWithObject:readVC];
    
    [_pageViewController setViewControllers:viewControllers
                                  direction:UIPageViewControllerNavigationDirectionReverse
                                   animated:NO
                                 completion:nil];
    
    // 设置UIPageViewController 尺寸
    _pageViewController.view.frame = self.view.bounds;
    
//    //是否双面显示，默认为NO
//    _pageViewController.doubleSided = YES;
    
    // 在页面上，显示UIPageViewController对象的View
    [self addChildViewController:_pageViewController];
    [self.view addSubview:_pageViewController.view];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // 屏幕常亮
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // 改变状态栏的颜色
    if ([[RKUserConfig sharedInstance].bgImageName isEqualToString:@"reader_bg_2"] || [[RKUserConfig sharedInstance].bgImageName isEqualToString:@"black"]) {
        [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    } else {
        if (@available(iOS 13.0, *)) {
            [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDarkContent;
        } else {
            [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
        }
    }
    
    [self updateLocalBookData];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    // 关闭屏幕常亮
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (BOOL)prefersHomeIndicatorAutoHidden {
    return true;
}

#pragma mark - 手势事件
- (void)showToolMenu {
    
    // 若已显示菜单则忽略
    if (self.isShowMenu) {
        return ;
    }
    
    // 改变状态栏的颜色
//    if ([[RKUserConfig sharedInstance].bgImageName isEqualToString:@"reader_bg_2"] || [[RKUserConfig sharedInstance].bgImageName isEqualToString:@"black"]) {
        [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
//    } else {
//        [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
//    }

    self.isShowMenu = YES;
    // 菜单view
    RKReadMenuView *menu = [[RKReadMenuView alloc] initWithFrame:self.view.bounds withBook:self.book withSuperView:self.view];
    [menu show];

    __weak typeof(self) weakSelf = self;
    // 菜单消失
    [menu dismissWithHandler:^{
        weakSelf.isShowMenu = NO;

        // 改变状态栏的颜色
        if ([[RKUserConfig sharedInstance].bgImageName isEqualToString:@"reader_bg_2"] || [[RKUserConfig sharedInstance].bgImageName isEqualToString:@"black"]) {
            [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
        } else {
            if (@available(iOS 13.0, *)) {
                [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDarkContent;
            } else {
                [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
            }
        }
    }];

    // 退出阅读
    [menu closeBlock:^{
        [weakSelf dissmiss];
    }];
    
    // 章节跳转
    [menu shouldChangeChapter:^(BOOL isNextChapter) {
        if (isNextChapter) {
            // 最后一章
            if (weakSelf.currentChapter == weakSelf.book.chapters.count - 1) {
                RKAlertMessage(@"没有下一章了~", weakSelf.view);
                return;
            }
            // 直接返回下一章
            weakSelf.pageNext = 0;
            weakSelf.chapterNext = weakSelf.currentChapter + 1;
            
        }else {
            // 第一章的最后一页
            if (weakSelf.currentChapter == 0) {
                RKAlertMessage(@"没有上一章了~", weakSelf.view);
                return;
            }
            weakSelf.pageNext = 0;
            weakSelf.chapterNext = weakSelf.currentChapter - 1;
        }
        
        // 设置当前显示的readVC
        [weakSelf.pageViewController setViewControllers:@[[weakSelf viewControllerChapter:weakSelf.chapterNext andPage:weakSelf.pageNext]] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
        
        // 更新阅读记录
        weakSelf.currentPage = 0;
        weakSelf.currentChapter = weakSelf.chapterNext;
        [weakSelf updateLocalBookData];
    }];
    
    // 字号
    [menu shouldChangeFontSize:^{
        // 设置当前显示的readVC
        [weakSelf.pageViewController setViewControllers:@[[weakSelf viewControllerChapter:weakSelf.currentChapter andPage:weakSelf.currentPage]] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    }];
    
    // 行间距
    [menu shouldChangeLineSpace:^{
        
        // 设置当前显示的readVC
        [weakSelf.pageViewController setViewControllers:@[[weakSelf viewControllerChapter:weakSelf.currentChapter andPage:weakSelf.currentPage]] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    }];
    
    // 目录
    [menu shouldShowBookCatalog:^{
        RKChaptersListView *chaptersListView = [[RKChaptersListView alloc] initWithFrame:weakSelf.view.bounds withBook:weakSelf.book withSuperView:weakSelf.view];
        // 显示
        [chaptersListView show];
        
        [chaptersListView didSelectChapter:^{
            // 更新阅读记录
            weakSelf.currentPage = 0;
            weakSelf.currentChapter = weakSelf.book.currentChapterNum;
            // 设置当前显示的readVC
            [weakSelf.pageViewController setViewControllers:@[[weakSelf viewControllerChapter:weakSelf.currentChapter andPage:weakSelf.currentPage]] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
            [weakSelf updateLocalBookData];
        }];
    }];
    
    // 夜间模式
    [menu shouldChangeNightModle:^(BOOL isOpen) {
        
        if (isOpen) {
            [RKUserConfig sharedInstance].bgImageName = @"black";
        } else {
            [RKUserConfig sharedInstance].fontColor = @"000000";
            [RKUserConfig sharedInstance].bgImageName = @"reader_bg_3";
        }
        
//        // 改变状态栏的颜色
//        if ([[RKUserConfig sharedInstance].bgImageName isEqualToString:@"reader_bg_2"] || [[RKUserConfig sharedInstance].bgImageName isEqualToString:@"black"]) {
//            [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
//        } else {
//            if (@available(iOS 13.0, *)) {
//                [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDarkContent;
//            } else {
//                [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
//            }
//        }
        
        // 设置当前显示的readVC
        [self.pageViewController setViewControllers:@[[self viewControllerChapter:self.currentChapter andPage:self.currentPage]] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    }];
    
    // 打开设置
    [menu shouldOpenSetting:^{
        RKReadSettingViewController *settingVC = [[RKReadSettingViewController alloc] init];
        settingVC.book = self.book;
        RKNavigationController *nav = [[RKNavigationController alloc] initWithRootViewController:settingVC];
        [settingVC needRefresh:^{
            // 改变状态栏的颜色
            if ([[RKUserConfig sharedInstance].bgImageName isEqualToString:@"reader_bg_2"] || [[RKUserConfig sharedInstance].bgImageName isEqualToString:@"black"]) {
                [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
            } else {
                if (@available(iOS 13.0, *)) {
                    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDarkContent;
                } else {
                    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
                }
            }
            // 设置当前显示的readVC
            [weakSelf.pageViewController setViewControllers:@[[weakSelf viewControllerChapter:weakSelf.currentChapter andPage:weakSelf.currentPage]] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
        }];
        [self presentViewController:nav animated:YES completion:nil];
    }];
    
    [menu fontAlphaChange:^(CGFloat alpha) {
        [RKUserConfig sharedInstance].nightAlpha = alpha;
        // 设置当前显示的readVC
        [weakSelf.pageViewController setViewControllers:@[[weakSelf viewControllerChapter:weakSelf.currentChapter andPage:weakSelf.currentPage]] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    }];
}

#pragma mark - 代理
#pragma mark -- UIGestureRecognizerDelegate
//解决TabView与Tap手势冲突
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if ([NSStringFromClass([touch.view class]) isEqualToString:@"UITableViewCellContentView"]) {
        return NO;
    }
    return  YES;
}

#pragma mark -- RKReadMenuViewDelegate
- (void)didClickCloseBtn {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UIPageViewControllerDataSource
#pragma mark -- 返回上一个ViewController对象
- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    
    if ([RKUserConfig sharedInstance].isAllNextPage) {
        
//        self.pageNext = self.currentPage;
//        self.chapterNext = self.currentChapter;
//        // 最后一章 && 最后一页
//        if (self.pageNext == self.book.currentChapter.allPages - 1 && self.chapterNext == self.book.chapters.count - 1) {
//            RKAlertMessage(@"已经看完了!", self.view);
//            return nil;
//        }
//        // 本章节的最后一页
//        if (self.pageNext == self.book.currentChapter.allPages - 1) {
//            self.chapterNext ++;
//            self.pageNext = 0;
//        } else {
//            self.pageNext ++;
//        }
//
//        // 设置当前显示的readVC
//        [self.pageViewController setViewControllers:@[[self viewControllerChapter:self.chapterNext andPage:self.pageNext]] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
//        return nil;
    }
    
    self.pageNext = self.currentPage;
    self.chapterNext = self.currentChapter;

    if (self.pageNext == 0 && self.chapterNext == 0) {
        RKAlertMessage(@"前面没有了!", self.view);
        return nil;
    }
    if (self.pageNext == 0) {
        self.chapterNext--;
        // 上一章节最后一页
        RKChapter *lastChapter = self.book.chapters[self.chapterNext];
        self.pageNext = lastChapter.allPages - 1;
    } else {
        self.pageNext--;
    }

//    RKLog(@"chapter:%ld -- page:%ld",self.chapterNext,self.pageNext);
    return [self viewControllerChapter:self.chapterNext andPage:self.pageNext];
}

#pragma mark -- 返回下一个ViewController对象
- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    
    self.pageNext = self.currentPage;
    self.chapterNext = self.currentChapter;
    // 最后一章 && 最后一页
    if (self.pageNext == self.book.currentChapter.allPages - 1 && self.chapterNext == self.book.chapters.count - 1) {
        RKAlertMessage(@"已经看完了!", self.view);
        return nil;
    }
    // 本章节的最后一页
    if (self.pageNext == self.book.currentChapter.allPages - 1) {
        self.chapterNext ++;
        self.pageNext = 0;
    } else {
        self.pageNext ++;
    }
//    RKLog(@"chapter:%ld -- page:%ld",self.chapterNext,self.pageNext);
    return [self viewControllerChapter:self.chapterNext andPage:self.pageNext];
}

#pragma mark -- UIPageViewControllerDelegate
// 页面跳转回调
- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray<UIViewController *> *)previousViewControllers transitionCompleted:(BOOL)completed {
//    RKLog(@"didFinishAnimating -- %@ -- completed:%@",finished?@YES:@NO,completed?@YES:@NO);
    
    if (finished && completed) {
        // 无论有无翻页，只要动画结束就恢复交互。
//        pageViewController.view.userInteractionEnabled = YES;
        self.currentChapter = self.chapterNext;
        self.currentPage = self.pageNext;
        [self updateLocalBookData];
    }
}

// 页面将要跳转
- (void)pageViewController:(UIPageViewController *)pageViewController willTransitionToViewControllers:(NSArray<UIViewController *> *)pendingViewControllers {
//    RKLog(@"willTransitionToViewControllers");
    //    self.currentChapter = self.chapterNext;
    //    self.currentPage = self.pageNext;
//    RKLog(@"%ld -|- %ld",self.currentChapter,self.currentPage);
}


#pragma mark - 函数
#pragma mark -- 根据index得到对应的UIViewController
- (RKReadViewController *)viewControllerChapter:(NSInteger)chapter andPage:(NSInteger)page {
    
    // 创建一个新的控制器类，并且分配给相应的数据
    RKReadViewController *readVC = [[RKReadViewController alloc] init];
    
    // 准备章节
    RKChapter *Chapter = self.book.chapters[chapter];
    NSRange contentRange = NSMakeRange(Chapter.location, Chapter.length);
    
    if (Chapter.location > self.book.content.length) {
        RKAlertMessage(@"错误 code:3", self.view);
        return nil;
    }
    
    if (contentRange.location+contentRange.length > self.book.content.length) {
        RKAlertMessage(@"错误 code:4", self.view);
        return nil;
    }
    Chapter.content = [self.book.content substringWithRange:contentRange];
    Chapter.page = page;
    self.book.currentChapter = Chapter;
    
    // 修改当前book对象的信息
    self.book.currentChapterNum = chapter;
    self.book.currentPage = page;

    readVC.chapter = self.book.currentChapter;
    readVC.content = [Chapter stringOfPage:page];
    
    // 排除开始页内容为空
    if (self.book.currentChapterNum == 0 && [readVC.content length] == 0) {
        readVC.content = @"开始";
    }
    return readVC;
}

#pragma mark -- 保存阅读进度
/// 保存阅读进度
- (void)updateLocalBookData {
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        self.book.currentPage = self.currentPage;
        self.book.currentChapterNum = self.currentChapter;
//        RKLog(@"---- %ld",self.currentPage);
        if (self.currentChapter == 0 && self.currentPage == 0) {
            self.book.progress = 0.0f;
            self.book.chapterName = @"开始";
        } else {
            NSRange pageRange = [self.book.content rangeOfString:[self.book.currentChapter stringOfPage:self.book.currentPage]];
            self.book.progress = (pageRange.location + pageRange.length)*1.0f/[self.book.content length]*1.0f;
            self.book.chapterName = self.book.currentChapter.title;
            if (self.book.progress > 1) {
                self.book.progress = 1;
            }
        }
        
        NSMutableArray *bookList = [[RKFileManager shareInstance] getHomeList];
        
        for (RKBook *subBook in bookList) {
            if ([subBook.bookID isEqualToString:self.book.bookID]) {
                subBook.currentChapterNum = self.currentChapter;
                subBook.currentPage = self.currentPage;
                subBook.progress = self.book.progress;
                subBook.chapterName = self.book.chapterName;
                subBook.lastReadDate = [[NSDate date] timeIntervalSince1970];
            }
        }
        [[RKFileManager shareInstance] saveBookList:bookList];
        [RKFileManager shareInstance].isNeedRefresh = YES;
    });
}

#pragma mark -- 退出阅读
/// 关闭页面
- (void)dissmiss {
    // 关闭
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - setting
- (void)setBook:(RKBook *)book {
    _book = book;
    
    self.currentChapter = book.currentChapterNum;
    self.currentPage = book.currentPage;
}

#pragma mark - 3d Touch
- (NSArray <id <UIPreviewActionItem>> *)previewActionItems {
    return self.previewActionArray;
}

- (NSMutableArray *)previewActionArray {
    if (!_previewActionArray) {
        __weak typeof(self) weakSelf = self;
        UIPreviewAction *deleteAnalysisAction = [UIPreviewAction actionWithTitle:@"删除缓存" style:UIPreviewActionStyleDestructive handler:^(UIPreviewAction * _Nonnull action, UIViewController * _Nonnull previewViewController) {
            RKLog(@"---- 删除缓存");
            
            NSMutableArray *bookList = [[RKFileManager shareInstance] getHomeList];
            
            for (RKBook *subBook in bookList) {
                if ([subBook.bookID isEqualToString:weakSelf.book.bookID]) {
                    subBook.isNeedRefreshChapters = YES;
                }
            }
            [[RKFileManager shareInstance] saveBookList:bookList];
            [RKFileManager shareInstance].isNeedRefresh = YES;
        }];
        
//        UIPreviewAction *deleteBookAction = [UIPreviewAction actionWithTitle:@"xxxx" style:UIPreviewActionStyleSelected handler:^(UIPreviewAction * _Nonnull action, UIViewController * _Nonnull previewViewController) {
//
//        }];
        
        UIPreviewAction *backAction = [UIPreviewAction actionWithTitle:@"返回" style:UIPreviewActionStyleDefault handler:^(UIPreviewAction * _Nonnull action, UIViewController * _Nonnull previewViewController) {
            RKLog(@"---- 返回");
        }];
        
        _previewActionArray = [NSMutableArray arrayWithObjects:deleteAnalysisAction,backAction, nil];
        
    }
    return _previewActionArray;
}

@end
