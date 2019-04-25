//
//  RKReadMenuView.h
//  Reader
//
//  Created by Rzk on 2019/4/25.
//  Copyright © 2019 Rzk. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN


@protocol RKReadMenuViewDelegate <NSObject>

/// 关闭
- (void)didClickCloseBtn;

@end


@interface RKReadMenuView : UIView


@property (nonatomic, weak) id<RKReadMenuViewDelegate> delegate; /**< 代理*/

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

@end

NS_ASSUME_NONNULL_END