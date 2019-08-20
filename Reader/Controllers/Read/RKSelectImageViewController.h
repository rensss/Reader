//
//  RKSelectImageViewController.h
//  Reader
//
//  Created by Rzk on 2019/8/19.
//  Copyright © 2019 Rzk. All rights reserved.
//

#import "RKViewController.h"

typedef NS_ENUM(NSInteger, RKSelectImageType) {
    RKSelectImageTypeBgImage,
    RKSelectImageTypeCoverImage,
};

@interface RKSelectImageViewController : RKViewController

@property (nonatomic, strong) RKBook *book; /**< 书籍对象*/
@property (nonatomic, assign) RKSelectImageType type; /**< 类型*/
@property (nonatomic, copy) void(^callBack)(void); /**< 回调*/

@end

