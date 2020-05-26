//
//  RKBookImprotViewController.h
//  Reader
//
//  Created by Rzk on 2019/4/22.
//  Copyright © 2019 Rzk. All rights reserved.
//

#import "RKViewController.h"

NS_ASSUME_NONNULL_BEGIN
/// 书籍导入VC 显示类型
typedef NS_ENUM(NSInteger, RKImprotShowType) {
    /// push进入
    RKImprotShowTypePush,
    /// 模态跳转进入
    RKImprotShowTypePresent,
};

@interface RKBookImprotViewController : RKViewController

@property (nonatomic, assign) RKImprotShowType showType; /**< 显示类型*/

@end

NS_ASSUME_NONNULL_END
