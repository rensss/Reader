//
//  RKBookmarkListCell.h
//  Reader
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface RKBookmarkListCell : UITableViewCell

@property (nonatomic, strong) RKBookmark *bookmark; /**< 书签*/
@property (nonatomic, copy) NSString *chapterTitle; /**< 所属章节名*/

@end

NS_ASSUME_NONNULL_END
