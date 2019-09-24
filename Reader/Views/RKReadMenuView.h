//
//  RKReadMenuView.h
//  Reader
//
//  Created by Rzk on 2019/4/25.
//  Copyright © 2019 Rzk. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@interface RKReadMenuView : UIView

/**
 初始化菜单view
 @param frame 大小
 @param book 书籍信息
 @param superView 父view
 @return 菜单
 */
- (instancetype)initWithFrame:(CGRect)frame withBook:(RKBook *)book withSuperView:(UIView *)superView;

/// 显示
- (void)show;

/// 消失
- (void)dismiss;

/// 消失 带回调
- (void)dismissWithHandler:(void(^)(void))handler;

/// 关闭回调
- (void)closeBlock:(void(^)(void))handler;

/// 章节跳转
- (void)shouldChangeChapter:(void(^)(BOOL isNextChapter))handler;

/// 改变字号
- (void)shouldChangeFontSize:(void(^)(void))handler;

/// 改变行间距
- (void)shouldChangeLineSpace:(void(^)(void))handler;

/// 打开目录
- (void)shouldShowBookCatalog:(void(^)(void))handler;

/// 是否打开夜间模式
- (void)shouldChangeNightModle:(void(^)(BOOL isOpen))handler;

/// 打开设置
- (void)shouldOpenSetting:(void(^)(void))handler;

/// 字体透明度
- (void)fontAlphaChange:(void(^)(CGFloat alpha))handler;

@end

NS_ASSUME_NONNULL_END
