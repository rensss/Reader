//
//  UILabel+R_Category.h
//  R_category
//
//  Created by rzk on 2017/10/10.
//  Copyright © 2017年 rzk. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UILabel (R_Category)

/**
 包含图片的字符串
 默认{}包含需要显示的图片名
 仅供本地图片显示
 */
@property (nonatomic, copy) NSString *imgString; /**< 包含图片的字符串*/

@end
