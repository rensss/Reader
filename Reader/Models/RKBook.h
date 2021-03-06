//
//  RKBook.h
//  Reader
//
//  Created by Rzk on 2019/4/22.
//  Copyright © 2019 Rzk. All rights reserved.
//

#import "RKModel.h"
#import "RKChapter.h"

@interface RKBook : RKModel

@property (nonatomic, copy) NSString *bookID; /**< 书籍ID*/
@property (nonatomic, copy) NSString *coverImage; /**< 封面图*/
@property (nonatomic, copy) NSString *name; /**< 书名*/
@property (nonatomic, copy) NSString *path; /**< 存放地址*/
@property (nonatomic, copy) NSString *content; /**< 全书内容*/
@property (nonatomic, assign) CGFloat progress; /**< 进度*/
@property (nonatomic, strong) NSMutableArray *chapters; /**< 所有章节*/
@property (nonatomic, assign) CGFloat size; /**< 大小*/
@property (nonatomic, assign) NSTimeInterval addDate; /**< 添加时间*/
@property (nonatomic, assign) NSTimeInterval lastReadDate; /**< 最后阅读*/
@property (nonatomic, assign) BOOL isTop; /**< 是否置顶*/
@property (nonatomic, assign) BOOL isSecret; /**< 是否加密*/
@property (nonatomic, copy) NSString *chapterName; /**< 章节名*/

@property (nonatomic, assign) NSInteger currentChapterNum; /**< 第几章*/
@property (nonatomic, assign) NSInteger currentPage; /**< 第几页*/

@property (nonatomic, strong) RKChapter *currentChapter; /**< 当前章节*/
@property (nonatomic, assign) NSInteger allChapters; /**< 总章节数*/

@property (nonatomic, assign) BOOL isNeedRefreshChapters; /**< 是否需要重新解析章节*/

@end
