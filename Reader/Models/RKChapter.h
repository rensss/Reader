//
//  RKChapter.h
//  Reader
//
//  Created by Rzk on 2019/4/22.
//  Copyright © 2019 Rzk. All rights reserved.
//

#import "RKModel.h"

@interface RKChapter : RKModel

@property (nonatomic, copy) NSString *title; /**< 章节名*/
@property (nonatomic, assign) NSInteger location; /**< 起点*/
@property (nonatomic, assign) NSInteger length; /**< 长度*/
@property (nonatomic, assign) NSInteger allPages; /**< 总页数*/
@property (nonatomic, assign) NSInteger page; /**< 当前页数*/
//@property (nonatomic, copy) NSString *chapterName; /**< 章节名*/
@property (nonatomic, copy) NSString *content; /**< 内容*/

@end
