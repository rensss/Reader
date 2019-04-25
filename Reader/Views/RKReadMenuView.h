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
 @return 菜单
 */
- (instancetype)initWithFrame:(CGRect)frame withBook:(RKBook *)book;


@end

NS_ASSUME_NONNULL_END
