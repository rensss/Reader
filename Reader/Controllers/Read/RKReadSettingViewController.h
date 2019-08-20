//
//  RKReadSettingViewController.h
//  Reader
//
//  Created by Rzk on 2019/8/19.
//  Copyright © 2019 Rzk. All rights reserved.
//

#import "RKViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface RKReadSettingViewController : RKViewController

@property (nonatomic, strong) RKBook *book; /**< 书籍对象*/

/**
 刷新回调
 @param handler 回调
 */
- (void)needRefresh:(void(^)(void))handler;

@end

NS_ASSUME_NONNULL_END
