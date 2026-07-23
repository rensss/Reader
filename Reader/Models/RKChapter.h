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

/// 根据页码取出 当页内容
- (NSString *)stringOfPage:(NSUInteger)index;

/// 页起始偏移与长度;未分页返回 {NSNotFound, 0},index 越界按最后一页处理
- (NSRange)rangeOfPage:(NSUInteger)index;

/// 章节内字符偏移 换算 页码
- (NSInteger)pageOfLocation:(NSInteger)location;

@end
