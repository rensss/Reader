//
//  RKChaptersListView.h
//  Reader
//
//  Created by Rzk on 2019/8/20.
//  Copyright © 2019 Rzk. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface RKChaptersListView : UIView

/**
 初始化菜单view
 @param frame 大小
 @param book 书籍信息
 @param superView 父view
 @return 菜单
 */
- (instancetype)initWithFrame:(CGRect)frame withBook:(RKBook *)book withSuperView:(UIView *)superView;

/**
 选中章节的回调
 @param handler 回调
 */
- (void)didSelectChapter:(void(^)(void))handler;

/// 显示
- (void)show;

@end

NS_ASSUME_NONNULL_END
