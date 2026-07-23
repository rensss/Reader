//
//  RKBookmark.h
//  Reader
//

#import "RKModel.h"

@interface RKBookmark : RKModel

@property (nonatomic, assign) NSInteger chapterNum; /**< 章节 index*/
@property (nonatomic, assign) NSInteger location; /**< 章节内字符偏移*/
@property (nonatomic, copy) NSString *summary; /**< 摘要(当页开头约40字)*/
@property (nonatomic, assign) NSTimeInterval createDate; /**< 创建时间*/

@end
