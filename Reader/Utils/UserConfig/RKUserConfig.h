//
//  RKUserConfig.h
//  Reader
//
//  Created by Rzk on 2019/4/30.
//  Copyright © 2019 Rzk. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface RKUserConfig : NSObject

// 翻页方式
@property (nonatomic, assign) UIPageViewControllerTransitionStyle transitionStyle; /**< 翻页模式*/
@property (nonatomic, assign) UIPageViewControllerNavigationOrientation navigationOrientation; /**< 上下/左右 翻页*/

@property (nonatomic, assign) BOOL isAllNextPage; /**< 点击左侧翻下一页*/

// 上左下右 边距
@property (nonatomic, assign) CGFloat topPadding; /**< 上边距*/
@property (nonatomic, assign) CGFloat leftPadding; /**< 左边距*/
@property (nonatomic, assign) CGFloat bottomPadding; /**< 下边距*/
@property (nonatomic, assign) CGFloat rightPadding; /**< 右边距*/

// 阅读页大小
@property (nonatomic, assign) CGRect readViewFrame; /**< 阅读页大小*/

// 阅读页背景图
@property (nonatomic, copy) NSString *bgImageName; /**< 背景图*/

// 内容展示相关配置  字号/行间距/字体颜色/字体
@property (nonatomic, assign) CGFloat fontSize; /**< 字号*/
@property (nonatomic, assign) CGFloat lineSpace; /**< 行间距*/
@property (nonatomic, copy) NSString *fontColor; /**< 字体颜色*/
@property (nonatomic, copy) NSString *fontName; /**< 字体*/

@property (nonatomic, assign) BOOL isNeedRefreshView; /**< 是否需要刷新界面*/

@property (nonatomic, assign) BOOL isRefreshTop; /**< 置顶书籍是否需要按时间排序*/

@property (nonatomic, assign) float nightAlpha; /**< 夜间模式 字体透明度*/

/// 用户设置单例
+ (instancetype)sharedInstance;

/**
 显示属性
 @return 属性字典
 */
- (NSDictionary *)parserAttribute;

@end

NS_ASSUME_NONNULL_END
