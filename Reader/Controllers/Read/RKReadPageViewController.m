//
//  RKReadPageViewController.m
//  Reader
//
//  Created by Rzk on 2019/4/25.
//  Copyright © 2019 Rzk. All rights reserved.
//

#import "RKReadPageViewController.h"
#import "RKReadViewController.h"

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

@end

@implementation RKReadPageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    // 改变状态栏的颜色
//    if ([[RKUserConfiguration sharedInstance].bgImageName isEqualToString:@"reader_bg_2"]) {
//        // 设置状态栏的颜色
//        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
//    }else {
//        // 设置状态栏的颜色
//        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
//    }
    
    // 添加点击手势
    [self.view addGestureRecognizer:({
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showToolMenu)];
        tap.delegate = self;
        tap;
    })];
    
    // 设置UIPageViewController的配置项
    NSDictionary *options = @{UIPageViewControllerOptionInterPageSpacingKey : @(20)};
    //        NSDictionary *options = @{UIPageViewControllerOptionSpineLocationKey : @(UIPageViewControllerSpineLocationMin)};
    
    // 根据给定的属性实例化UIPageViewController
    _pageViewController = [[UIPageViewController alloc]
                           initWithTransitionStyle:UIPageViewControllerTransitionStylePageCurl navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal
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
    
    // 在页面上，显示UIPageViewController对象的View
    [self addChildViewController:_pageViewController];
    [self.view addSubview:_pageViewController.view];
}

#pragma mark - 手势事件
- (void)showToolMenu {
    
//    // 若已显示菜单则忽略
//    if (self.isShowMenu) {
//        return ;
//    }
//
//    // 设置状态栏的颜色
//    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
//
//    self.isShowMenu = YES;
//    // 菜单view
//    RKReadMenuView *menu = [[RKReadMenuView alloc] initWithFrame:self.view.bounds withBook:self.book];
//    menu.delegate = self;
//    [menu showToView:self.view];
//
//    __weak typeof(self) weakSelf = self;
//    // 菜单消失
//    [menu dismissBlock:^{
//        weakSelf.isShowMenu = NO;
//
//
//        // 改变状态栏的颜色
//        if ([[RKUserConfiguration sharedInstance].bgImageName isEqualToString:@"reader_bg_2"]) {
//            // 设置状态栏的颜色
//            [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
//        }else {
//            // 设置状态栏的颜色
//            [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
//        }
//
//        //        // 设置状态栏的颜色
//        //        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
//    }];
//
//    // 退出阅读
//    [menu closeBlock:^{
//        // 设置状态栏的颜色
//        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
//        [weakSelf dissmiss];
//    }];
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

#pragma mark - UIPageViewControllerDataSource And UIPageViewControllerDelegate
#pragma mark -- 返回上一个ViewController对象
- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    
//    self.pageNext = self.currentPage;
//    self.chapterNext = self.currentChapter;
//
//    if (self.pageNext == 0 && self.chapterNext == 0) {
//        return nil;
//    }
//    if (self.pageNext == 0) {
//        self.chapterNext--;
//        self.pageNext = self.book.chapters[self.chapterNext].pageCount - 1;
//    }else {
//        self.pageNext--;
//    }
//
//    RKLog(@"chapter:%ld -- page:%ld",self.chapterNext,self.pageNext);
    return [self viewControllerChapter:self.chapterNext andPage:self.pageNext];
}

#pragma mark -- 返回下一个ViewController对象
- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    
//    self.pageNext = self.currentPage;
//    self.chapterNext = self.currentChapter;
//    if (self.pageNext == self.book.chapters.lastObject.pageCount - 1 && self.chapterNext == self.book.chapters.count - 1) {
//        return nil;
//    }
//    if (self.pageNext == self.book.chapters[self.chapterNext].pageCount - 1) {
//        self.chapterNext ++;
//        self.pageNext = 0;
//    }else {
//        self.pageNext ++;
//    }
//    RKLog(@"chapter:%ld -- page:%ld",self.chapterNext,self.pageNext);
    return [self viewControllerChapter:self.chapterNext andPage:self.pageNext];
}

// 页面跳转回调
- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray<UIViewController *> *)previousViewControllers transitionCompleted:(BOOL)completed {
    RKLog(@"didFinishAnimating -- %@ -- completed:%@",finished?@YES:@NO,completed?@YES:@NO);
    
    if (completed) {
//        self.currentChapter = self.chapterNext;
//        self.currentPage = self.pageNext;
//        [self updateLocalBookData];
    } else {
        //        RKReadViewController *readViewVC = (RKReadViewController *)previousViewControllers.firstObject;
        //        RKLog(@"%ld -- %ld -|- %ld -- %ld",self.currentChapter,self.currentPage,readViewVC.chapter,readViewVC.page);
        //        self.currentPage = readViewVC.page;
        //        self.currentChapter = readViewVC.chapter;
    }
}

// 页面将要跳转
- (void)pageViewController:(UIPageViewController *)pageViewController willTransitionToViewControllers:(NSArray<UIViewController *> *)pendingViewControllers {
    RKLog(@"willTransitionToViewControllers");
    //    self.currentChapter = self.chapterNext;
    //    self.currentPage = self.pageNext;
    RKLog(@"%ld -|- %ld",self.currentChapter,self.currentPage);
}


#pragma mark - 函数
#pragma mark -- 根据index得到对应的UIViewController
- (RKReadViewController *)viewControllerChapter:(NSInteger)chapter andPage:(NSInteger)page {
    
    // 创建一个新的控制器类，并且分配给相应的数据
    RKReadViewController *readVC = [[RKReadViewController alloc] init];
    readVC.chapter = self.book.currentChapter;
//    // 切换章节时 可能需要重新规划字体显示内容
//    if (self.currentChapter != chapter) {
//        [self.book.chapters[chapter] updateFont];
//    }
//    // 内容
//    readVC.content = [self.book.chapters[chapter] stringOfPage:page];
//    readVC.chapter = chapter;
//    readVC.page = page;
//    readVC.bookChapter = self.book.chapters[chapter];
//    readVC.chapters = self.book.chapters.count;
//    readVC.listBook = self.listBook;
    
    return readVC;
}

#pragma mark -- 保存阅读进度
/// 保存阅读进度
- (void)updateLocalBookData {
    
//    self.listBook.readProgress.chapter = self.currentChapter;
//    self.listBook.readProgress.page = self.currentPage;
//    self.listBook.readProgress.progress = self.currentChapter*1.0f/self.book.chapters.count;
//    self.listBook.readProgress.title = self.book.chapters[self.currentChapter].title;
//
//    RKReadViewController *readVC = (RKReadViewController *)self.pageViewController.viewControllers.firstObject;
//    readVC.listBook = self.listBook;
//
//    [RKFileManager updateHomeListDataWithListBook:self.listBook];
}

#pragma mark -- 退出阅读
/// 关闭页面
- (void)dissmiss {
    // 侧滑返回
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    // 关闭
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - setting
- (void)setBook:(RKBook *)book {
    _book = book;
    
    self.currentChapter = book.currentChapterNum;
    self.currentPage = book.currentPage;
}

@end
