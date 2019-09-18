//
//  RKBookImprotViewController.h
//  Reader
//
//  Created by Rzk on 2019/4/22.
//  Copyright © 2019 Rzk. All rights reserved.
//

#import "RKViewController.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, RKImprotShowType) {
    RKImprotShowTypePush,
    RKImprotShowTypePresent,
};

@interface RKBookImprotViewController : RKViewController

@property (nonatomic, assign) RKImprotShowType showType; /**< 显示类型*/

@end

NS_ASSUME_NONNULL_END
