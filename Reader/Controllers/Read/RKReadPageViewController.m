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
#import "RKBackViewController.h"
#import "RKTTSMenuView.h"

@interface RKReadPageViewController ()
<
UIPageViewControllerDelegate,
UIPageViewControllerDataSource,
UIGestureRecognizerDelegate,
RKTTSMenuViewDelegate,
RKIFLYTTSManagerDelegate
>

@property (nonatomic, strong) UIPageViewController *pageViewController; /**< 显示内容的VC*/

@property (nonatomic, assign) NSInteger currentChapter; /**< 当前章节*/
@property (nonatomic, assign) NSInteger currentPage; /**< 当前页码*/

@property (nonatomic, assign) NSInteger chapterNext; /**< 上/下 一章节*/
@property (nonatomic, assign) NSInteger pageNext; /**< 上/下 一页*/

@property (nonatomic, assign) BOOL isShowMenu; /**< 是否已弹出菜单*/
@property (nonatomic, assign) BOOL isShowList; /**< 是否已展示章节列表 */
@property (nonatomic, strong) RKReadMenuView *menuView; /**< 菜单view*/

@property (nonatomic, strong) NSMutableArray *previewActionArray; /**< 3Dtouch 上滑选项*/

@property (nonatomic, strong) RKIFLYTTSManager *IFLYTTSManager; /**< tts*/

@property (nonatomic, strong) UIPanGestureRecognizer *bookmarkPan; /**< 下拉书签手势*/
@property (nonatomic, strong) UIView *bookmarkHintView; /**< 下拉提示条*/
@property (nonatomic, strong) UILabel *bookmarkHintLabel; /**< 下拉提示文案*/

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
    
    // 设置UIPageViewController 尺寸
//    DDLogVerbose(@"---- view:%@", NSStringFromCGRect(self.view.frame));
    _pageViewController.view.frame = self.view.bounds;
    
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
    
    // 是否双面显示，默认为NO
    _pageViewController.doubleSided = YES;
    
    // 在页面上，显示UIPageViewController对象的View
    [self addChildViewController:_pageViewController];
    [self.view addSubview:_pageViewController.view];

    // 下拉书签:提示条垫在内容层下方,仅左右翻页模式启用手势
    [self.view insertSubview:self.bookmarkHintView belowSubview:_pageViewController.view];
    if ([RKUserConfig sharedInstance].navigationOrientation == UIPageViewControllerNavigationOrientationHorizontal) {
        [self.view addGestureRecognizer:self.bookmarkPan];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // 屏幕常亮
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    [UIApplication sharedApplication].statusBarHidden = YES;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [UIApplication sharedApplication].statusBarHidden = NO;
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

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    RKUserConfig.sharedInstance.currentViewWidth = size.width;
    RKUserConfig.sharedInstance.currentViewHeight = size.height;
    
    if (@available(iOS 11.0, *)) {
        DDLogInfo(@"---- Transition size:%@ -- keywindow:%@ -- safaArea:%@", NSStringFromCGSize(size), NSStringFromCGRect(kKeyWindow.frame), NSStringFromUIEdgeInsets(self.view.safeAreaInsets));
        
        if (kIsPad) {
//            [UIApplication sharedApplication].applicationState != UIApplicationStateBackground;
            RKUserConfig.sharedInstance.currentSafeAreaInsets = self.view.safeAreaInsets;
            
            if (self.isShowMenu) [self.menuView dismiss];
            [self refreshCurrentVC];
        }
    }
}

- (void)viewSafeAreaInsetsDidChange {
    [super viewSafeAreaInsetsDidChange];
    
//    DDLogVerbose(@"---- safaArea:%@", NSStringFromUIEdgeInsets(self.view.safeAreaInsets));
    
    RKUserConfig.sharedInstance.currentSafeAreaInsets = self.view.safeAreaInsets;
    
    if (self.isShowMenu) [self.menuView dismiss];
    [self refreshCurrentVC];
}

- (BOOL)prefersHomeIndicatorAutoHidden {
    return true;
}

#pragma mark - 手势事件
- (void)showToolMenu {
    
    // 若已显示菜单则忽略
    if (self.isShowMenu) return;
    
    if (self.isShowList) return;
    
    [UIApplication sharedApplication].statusBarHidden = NO;
    
    self.isShowMenu = YES;
    // 菜单view
    self.menuView = [[RKReadMenuView alloc] initWithFrame:self.view.bounds withBook:self.book withSuperView:self.view];
    [self.menuView show];
    
    __weak typeof(self) weakSelf = self;
    // 菜单消失
    [self.menuView dismissWithHandler:^{
        [UIApplication sharedApplication].statusBarHidden = YES;
        
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
    [self.menuView closeBlock:^{
        [weakSelf dissmiss];
    }];
    
    // 章节跳转
    [self.menuView shouldChangeChapter:^(BOOL isNextChapter) {
        if (isNextChapter) {
            // 最后一章
            if (weakSelf.currentChapter == weakSelf.book.chapters.count - 1) {
                RKAlertMessage(@"没有下一章了~", weakSelf.view);
                return;
            }
            // 直接返回下一章
            weakSelf.pageNext = 0;
            weakSelf.chapterNext = weakSelf.currentChapter + 1;
            
        } else {
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
    [self.menuView shouldChangeFontSize:^{
        // 设置当前显示的readVC
        [weakSelf.pageViewController setViewControllers:@[[weakSelf viewControllerChapter:weakSelf.currentChapter andPage:weakSelf.currentPage]] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    }];
    
    // 行间距
    [self.menuView shouldChangeLineSpace:^{
        // 设置当前显示的readVC
        [weakSelf.pageViewController setViewControllers:@[[weakSelf viewControllerChapter:weakSelf.currentChapter andPage:weakSelf.currentPage]] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    }];
    
    // 目录
    [self.menuView shouldShowBookCatalog:^{
        RKChaptersListView *chaptersListView = [[RKChaptersListView alloc] initWithFrame:kKeyWindow.bounds withBook:weakSelf.book withSuperView:weakSelf.view dismissHandler:^{
            weakSelf.isShowList = NO;
            // 列表内可能删了当前页书签,回来刷新角标
            [weakSelf refreshCurrentBookmarkFlag];
        }];
        weakSelf.isShowList = YES;
        // 显示
        [chaptersListView show];

        [chaptersListView didSelectChapter:^{
            weakSelf.isShowList = NO;
            // 更新阅读记录
            weakSelf.currentPage = 0;
            weakSelf.currentChapter = weakSelf.book.currentChapterNum;
            // 设置当前显示的readVC
            [weakSelf.pageViewController setViewControllers:@[[weakSelf viewControllerChapter:weakSelf.currentChapter andPage:weakSelf.currentPage]] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
            [weakSelf updateLocalBookData];
        }];

        [chaptersListView didSelectBookmark:^(RKBookmark *bookmark) {
            weakSelf.isShowList = NO;
            if (bookmark.chapterNum >= weakSelf.book.chapters.count) return;

            // 先取章节触发分页,再按偏移换算页码
            RKChapter *chapterObj = [weakSelf getPageContentWithChapter:bookmark.chapterNum andPage:0];
            if (!chapterObj) return;
            NSInteger page = [chapterObj pageOfLocation:bookmark.location];

            weakSelf.currentChapter = bookmark.chapterNum;
            weakSelf.currentPage = page;
            [weakSelf.pageViewController setViewControllers:@[[weakSelf viewControllerChapter:bookmark.chapterNum andPage:page]] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
            [weakSelf updateLocalBookData];
        }];
    }];
    
    // 夜间模式
    [self.menuView shouldChangeNightModle:^(BOOL isOpen) {
        if (isOpen) {
            [RKUserConfig sharedInstance].bgImageName = @"black";
        } else {
            [RKUserConfig sharedInstance].fontColor = @"000000";
            [RKUserConfig sharedInstance].bgImageName = @"reader_bg_3";
        }
        
        // 设置当前显示的readVC
        [self.pageViewController setViewControllers:@[[self viewControllerChapter:self.currentChapter andPage:self.currentPage]] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    }];
    
    // 打开设置
    [self.menuView shouldOpenSetting:^{
        RKReadSettingViewController *settingVC = [[RKReadSettingViewController alloc] init];
        settingVC.book = self.book;
        RKNavigationController *nav = [[RKNavigationController alloc] initWithRootViewController:settingVC];
        [settingVC needRefresh:^{
            // 设置当前显示的readVC
            [weakSelf.pageViewController setViewControllers:@[[weakSelf viewControllerChapter:weakSelf.currentChapter andPage:weakSelf.currentPage]] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
        }];
        [self presentViewController:nav animated:YES completion:nil];
    }];
    
    // TTS 菜单
    [self.menuView shouldOpenTTS:^{
        RKTTSMenuView *tts = [[RKTTSMenuView alloc] initWithFrame:weakSelf.view.bounds withSuperview:weakSelf.view];
        tts.delegate = weakSelf;
        [tts show];
        [tts dismissWithHandler:^{
//            [weakSelf.ttsManager stop];
            [weakSelf.IFLYTTSManager stop];
        }];
        
        [weakSelf startSpeech];
    }];
    
    [self.menuView fontAlphaChange:^(CGFloat alpha) {
        [RKUserConfig sharedInstance].nightAlpha = alpha;
        // 设置当前显示的readVC
        [weakSelf.pageViewController setViewControllers:@[[weakSelf viewControllerChapter:weakSelf.currentChapter andPage:weakSelf.currentPage]] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    }];
}

#pragma mark -- 下拉书签
- (void)handleBookmarkPan:(UIPanGestureRecognizer *)pan {
    CGFloat translationY = [pan translationInView:self.view].y;
    // 阻尼 0.5,上限 120pt
    CGFloat offset = MIN(MAX(translationY * 0.5f, 0), 120);

    BOOL bookmarked = NO;
    if (self.currentChapter < self.book.chapters.count) {
        bookmarked = [self isPageBookmarkedWithChapterObj:self.book.chapters[self.currentChapter] chapterNum:self.currentChapter page:self.currentPage];
    }

    switch (pan.state) {
        case UIGestureRecognizerStateBegan:
        case UIGestureRecognizerStateChanged: {
            self.pageViewController.view.transform = CGAffineTransformMakeTranslation(0, offset);
            if (offset >= 60) {
                self.bookmarkHintLabel.text = bookmarked ? @"松手移除书签" : @"松手添加书签";
            } else {
                self.bookmarkHintLabel.text = bookmarked ? @"下拉移除书签" : @"下拉添加书签";
            }
            break;
        }
        case UIGestureRecognizerStateEnded: {
            if (offset >= 60) {
                [self toggleBookmark];
            }
            [self resetBookmarkPan];
            break;
        }
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateFailed: {
            [self resetBookmarkPan];
            break;
        }
        default:
            break;
    }
}

/// 回弹复位
- (void)resetBookmarkPan {
    [UIView animateWithDuration:0.35f delay:0 usingSpringWithDamping:0.8f initialSpringVelocity:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.pageViewController.view.transform = CGAffineTransformIdentity;
    } completion:nil];
}

/// 当前页书签 toggle:无则加,有则删该页全部
- (void)toggleBookmark {
    if (self.currentChapter >= self.book.chapters.count) return;

    RKChapter *chapterObj = self.book.chapters[self.currentChapter];
    NSRange range = [chapterObj rangeOfPage:self.currentPage];
    if (range.location == NSNotFound) return;

    if (!self.book.bookmarks) {
        self.book.bookmarks = [NSMutableArray array];
    }

    NSMutableArray *inPage = [NSMutableArray array];
    for (RKBookmark *bm in self.book.bookmarks) {
        if (bm.chapterNum != self.currentChapter) continue;
        if (bm.location >= (NSInteger)range.location && bm.location < (NSInteger)(range.location + MAX(range.length, 1))) {
            [inPage addObject:bm];
        }
    }

    if (inPage.count > 0) {
        [self.book.bookmarks removeObjectsInArray:inPage];
        RKAlertMessage(@"已移除书签", self.view);
    } else {
        RKBookmark *bookmark = [[RKBookmark alloc] init];
        bookmark.chapterNum = self.currentChapter;
        bookmark.location = range.location;
        NSString *pageText = [chapterObj stringOfPage:self.currentPage];
        NSString *summary = [pageText stringByTrimmingWhitespaceAndAllNewLine] ?: @"";
        if (summary.length > 40) {
            summary = [summary substringToIndex:40];
        }
        bookmark.summary = summary;
        bookmark.createDate = [[NSDate date] timeIntervalSince1970];
        [self.book.bookmarks addObject:bookmark];
        RKAlertMessage(@"已添加书签", self.view);
    }

    [[RKFileManager shareInstance] updateBookmarksForBook:self.book];
    [self refreshCurrentBookmarkFlag];
}

#pragma mark - 代理
#pragma mark -- UIGestureRecognizerDelegate
// 解决TabView与Tap手势冲突
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if ([NSStringFromClass([touch.view class]) isEqualToString:@"UITableViewCellContentView"]) {
        return NO;
    }
    if ([NSStringFromClass([touch.view.superview class]) isEqualToString:@"RKTTSMenuView"]) {
        return NO;
    }
    return YES;
}

// 下拉书签:竖直下滑分量占优才开始;菜单/目录展示中不响应
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if (gestureRecognizer == self.bookmarkPan) {
        if (self.isShowMenu || self.isShowList) return NO;
        CGPoint velocity = [self.bookmarkPan velocityInView:self.view];
        return velocity.y > 0 && fabs(velocity.y) > fabs(velocity.x);
    }
    return YES;
}

// 下拉书签手势与翻页内部手势并存,互不阻塞
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return gestureRecognizer == self.bookmarkPan || otherGestureRecognizer == self.bookmarkPan;
}

#pragma mark -- RKReadMenuViewDelegate
- (void)didClickCloseBtn {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UIPageViewControllerDataSource
#pragma mark -- 返回上一个ViewController对象
- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    
    if ([RKUserConfig sharedInstance].isAllNextPage) {
//        return [self pageViewController:pageViewController viewControllerAfterViewController:viewController];
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
    
//    DDLogInfo(@"chapter:%ld -- page:%ld",self.chapterNext,self.pageNext);
    return [self viewControllerChapter:self.chapterNext andPage:self.pageNext];
}

#pragma mark -- 返回下一个ViewController对象
- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    
    if ([viewController isKindOfClass:[RKReadViewController class]]) {
        RKBackViewController *backViewController = [[RKBackViewController alloc] init];
        [backViewController updateWithViewController:viewController];
        return backViewController;
    }
    
    self.pageNext = self.currentPage;
    self.chapterNext = self.currentChapter;
    // 最后一章 && 最后一页
    if (self.pageNext == self.book.currentChapter.allPages - 1 && self.chapterNext == self.book.chapters.count - 1) {
        RKAlertMessage(@"已经看完了!", self.view);
        return nil;
    }
    
    // 本章节的最后一页
    if (self.pageNext >= self.book.currentChapter.allPages - 1) {
        self.chapterNext ++;
        self.pageNext = 0;
    } else {
        self.pageNext ++;
    }
    
    if (self.chapterNext >= self.book.chapters.count) {
        RKAlertMessage(@"恭喜全部看完!", self.view);
        return nil;
    }
    DDLogInfo(@"chapter:%ld -- page:%ld",self.chapterNext,self.pageNext);
    return [self viewControllerChapter:self.chapterNext andPage:self.pageNext];
}

#pragma mark -- UIPageViewControllerDelegate
// 页面跳转回调
- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray<UIViewController *> *)previousViewControllers transitionCompleted:(BOOL)completed {
//    DDLogInfo(@"didFinishAnimating -- %@ -- completed:%@",finished?@YES:@NO,completed?@YES:@NO);
    
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
//    DDLogInfo(@"willTransitionToViewControllers");
    //    self.currentChapter = self.chapterNext;
    //    self.currentPage = self.pageNext;
//    DDLogInfo(@"%ld -|- %ld",self.currentChapter,self.currentPage);
}

#pragma mark -- RKTTSMenuViewDelegate
- (void)stopButtonClickForTTSMenuView:(RKTTSMenuView *)menuView {
    DDLogInfo(@"---- stopButtonClickForTTSMenuView");
    
}

- (void)sliderValueChangeForTTSMenuView:(RKTTSMenuView *)menuView {
//    [self.ttsManager stop];
//    self.ttsManager.delegate = nil;
//    self.ttsManager = nil;
    
    [self.IFLYTTSManager stop];
    self.IFLYTTSManager.delegate = nil;
    self.IFLYTTSManager = nil;
    
    [self startSpeech];
}

#pragma mark -- RKIFLYTTSManagerDelegate
- (void)onSpeakBeginForRKIFLYTTSManager:(RKIFLYTTSManager *)manager {
    
}

- (void)onSpeakPausedForRKIFLYTTSManager:(RKIFLYTTSManager *)manager {
    
}

- (void)onBufferProgress:(int)progress message:(NSString *)msg RKIFLYTTSManager:(RKIFLYTTSManager *)manager {
    if (progress == 100) {
        
    }
}

- (void)onSpeakProgress:(int)progress beginPos:(int)beginPos endPos:(int)endPos RKIFLYTTSManager:(RKIFLYTTSManager *)manager {
    
    if (progress < 100) { return; }
    
//    if ([manager.currentContent isEqualToString:@"当前page获取错误"]) {
//        return;
//    }
//
//    if ([manager.currentContent isEqualToString:@"已经看完了!"]) {
//        return;
//    }
//
//    [self performSelector:@selector(delay) withObject:nil afterDelay:0.5];
    
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1*NSEC_PER_MSEC)), dispatch_get_main_queue(), ^{
//        [self getNextPageContent];
//        [self refreshCurrentVC];
//        [self updateLocalBookData];
//    });
}

- (void)onCompletedRKIFLYTTSManager:(RKIFLYTTSManager *)manager {
    DDLogInfo(@"onCompleted");
    
    if ([manager.currentContent isEqualToString:@"当前page获取错误"]) { return; }
    
    if ([manager.currentContent isEqualToString:@"已经看完了!"]) { return; }
    
    [self delay];
    
//    [self performSelector:@selector(delay) withObject:nil afterDelay:0.5];
}

#pragma mark - 函数
#pragma mark -- 根据index得到对应的UIViewController
- (RKReadViewController *)viewControllerChapter:(NSInteger)chapter andPage:(NSInteger)page {
    
    // 创建一个新的控制器类，并且分配给相应的数据
    RKReadViewController *readVC = [[RKReadViewController alloc] init];
    
    RKChapter *Chapter = [self getPageContentWithChapter:chapter andPage:page];
    self.book.currentChapter = Chapter;
    
    // 修改当前book对象的信息
    self.book.currentChapterNum = chapter;
    self.book.currentPage = page;

    readVC.chapter = self.book.currentChapter;
    readVC.content = [Chapter stringOfPage:page];
    readVC.book = self.book;
    readVC.isBookmarked = [self isPageBookmarkedWithChapterObj:Chapter chapterNum:chapter page:page];

    // 排除开始页内容为空
    if (self.book.currentChapterNum == 0 && [readVC.content length] == 0) {
        readVC.content = @"开始";
    }
    return readVC;
}

- (RKChapter *)getPageContentWithChapter:(NSInteger)chapter andPage:(NSInteger)page {
    // 准备章节
    
    if (chapter >= self.book.chapters.count) {
        RKAlertMessage(@"错误 code:5", self.view);
        return nil;
    }
    
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
    return Chapter;
}

#pragma mark -- 书签判定
/// 当前页是否已有书签
- (BOOL)isPageBookmarkedWithChapterObj:(RKChapter *)chapterObj chapterNum:(NSInteger)chapterNum page:(NSInteger)page {
    if (!chapterObj || self.book.bookmarks.count == 0) return NO;

    NSRange range = [chapterObj rangeOfPage:page];
    if (range.location == NSNotFound) return NO;

    for (RKBookmark *bm in self.book.bookmarks) {
        if (bm.chapterNum != chapterNum) continue;
        if (bm.location >= (NSInteger)range.location && bm.location < (NSInteger)(range.location + MAX(range.length, 1))) {
            return YES;
        }
    }
    return NO;
}

/// 刷新当前显示页的角标
- (void)refreshCurrentBookmarkFlag {
    UIViewController *vc = self.pageViewController.viewControllers.firstObject;
    if (![vc isKindOfClass:[RKReadViewController class]]) return;
    if (self.currentChapter >= self.book.chapters.count) return;

    RKChapter *chapterObj = self.book.chapters[self.currentChapter];
    ((RKReadViewController *)vc).isBookmarked = [self isPageBookmarkedWithChapterObj:chapterObj chapterNum:self.currentChapter page:self.currentPage];
}

#pragma mark -- 保存阅读进度
/// 保存阅读进度
- (void)updateLocalBookData {
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        self.book.currentPage = self.currentPage;
        self.book.currentChapterNum = self.currentChapter;
//        DDLogInfo(@"---- %ld",self.currentPage);
        if (self.currentChapter == 0 && self.currentPage == 0) {
            self.book.progress = 0.0f;
            self.book.chapterName = @"开始";
        } else {
            if (self.book.currentChapter) {
                NSRange pageRange = [self.book.content rangeOfString:[self.book.currentChapter stringOfPage:self.book.currentPage]];
                self.book.progress = (pageRange.location + pageRange.length)*1.0f/[self.book.content length]*1.0f;
                self.book.chapterName = self.book.currentChapter.title;
                if (self.book.progress > 1) {
                    self.book.progress = 1;
                }
            }
        }
        
        [RKUserConfig sharedInstance].lastReadBookName = self.book.name;
        
        NSMutableArray *bookList = [[RKFileManager shareInstance] getAllBookList];
        
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

#pragma mark -- 刷新
- (void)refreshCurrentVC {
//    DDLogVerbose(@"---- frame = %@", NSStringFromCGRect([RKUserConfig sharedInstance].readViewFrame));
    // 设置当前显示的readVC
    [self.pageViewController setViewControllers:@[[self viewControllerChapter:self.currentChapter andPage:self.currentPage]] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
}

#pragma mark -- 阅读
- (void)startSpeech {
    NSString *content;
    RKChapter *chapter = [self getPageContentWithChapter:self.currentChapter andPage:self.currentPage];
    if (chapter) {
        content = [chapter stringOfPage:self.currentPage];
    } else {
        content = @"当前page获取错误";
    }
    [self startSpeechWithContent:content];
}

- (void)startSpeechWithContent:(NSString *)content {
    self.IFLYTTSManager = [[RKIFLYTTSManager alloc] init];
    self.IFLYTTSManager.delegate = self;
    [self.IFLYTTSManager startSpeechWithContent:content];
}

#pragma mark -- 获取内容
- (void)getNextPageContent {
    self.pageNext = self.currentPage;
    self.chapterNext = self.currentChapter;
    // 最后一章 && 最后一页
    if (self.pageNext == self.book.currentChapter.allPages - 1 && self.chapterNext == self.book.chapters.count - 1) {
        RKAlertMessage(@"已经看完了!", self.view);
        self.IFLYTTSManager = [[RKIFLYTTSManager alloc] init];
        [self.IFLYTTSManager startSpeechWithContent:@"已经看完了!"];
        return;
    }

    // 本章节的最后一页
    if (self.pageNext >= self.book.currentChapter.allPages - 1) {
        self.chapterNext ++;
        self.pageNext = 0;
    } else {
        self.pageNext ++;
    }
    
    self.currentPage = self.pageNext;
    self.currentChapter = self.chapterNext;
    
    [self startSpeech];
}

#pragma mark -- 延时执行
- (void)delay {
    [self getNextPageContent];
    [self refreshCurrentVC];
    [self updateLocalBookData];
}

#pragma mark - getting
- (UIPanGestureRecognizer *)bookmarkPan {
    if (!_bookmarkPan) {
        _bookmarkPan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleBookmarkPan:)];
        _bookmarkPan.delegate = self;
    }
    return _bookmarkPan;
}

- (UIView *)bookmarkHintView {
    if (!_bookmarkHintView) {
        _bookmarkHintView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 140)];
        _bookmarkHintView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _bookmarkHintView.backgroundColor = [UIColor clearColor];

        _bookmarkHintLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 30, self.view.bounds.size.width, 20)];
        _bookmarkHintLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _bookmarkHintLabel.font = [UIFont systemFontOfSize:13];
        _bookmarkHintLabel.textColor = kReadViewBottomTintColor;
        _bookmarkHintLabel.textAlignment = NSTextAlignmentCenter;
        [_bookmarkHintView addSubview:_bookmarkHintLabel];
    }
    return _bookmarkHintView;
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
            DDLogInfo(@"---- 删除缓存");
            
            NSMutableArray *bookList = [[RKFileManager shareInstance] getAllBookList];
            
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
            DDLogInfo(@"---- 返回");
        }];
        
        _previewActionArray = [NSMutableArray arrayWithObjects:deleteAnalysisAction,backAction, nil];
    }
    return _previewActionArray;
}

@end
