//
//  RKBookmarkListCell.m
//  Reader
//

#import "RKBookmarkListCell.h"

@interface RKBookmarkListCell ()

@property (nonatomic, strong) UILabel *titleLabel; /**< 章节名*/
@property (nonatomic, strong) UILabel *summaryLabel; /**< 摘要*/
@property (nonatomic, strong) UILabel *dateLabel; /**< 时间*/

@end

@implementation RKBookmarkListCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self.contentView addSubview:self.dateLabel];
        [self.dateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_offset(10);
            make.right.mas_offset(-8);
        }];
        [self.dateLabel setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
        [self.dateLabel setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];

        [self.contentView addSubview:self.titleLabel];
        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_offset(8);
            make.left.mas_offset(8);
            make.right.mas_lessThanOrEqualTo(self.dateLabel.mas_left).mas_offset(-8);
        }];

        [self.contentView addSubview:self.summaryLabel];
        [self.summaryLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.titleLabel.mas_bottom).mas_offset(4);
            make.left.mas_offset(8);
            make.right.mas_offset(-8);
            make.bottom.mas_lessThanOrEqualTo(0);
        }];
    }
    return self;
}

#pragma mark - setting
- (void)setBookmark:(RKBookmark *)bookmark {
    _bookmark = bookmark;

    self.summaryLabel.text = bookmark.summary;

    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"MM-dd HH:mm";
    self.dateLabel.text = [formatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:bookmark.createDate]];
}

- (void)setChapterTitle:(NSString *)chapterTitle {
    _chapterTitle = [chapterTitle copy];

    self.titleLabel.text = [chapterTitle stringByTrimmingWhitespaceAndAllNewLine];
}

#pragma mark - getting
- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = [UIFont boldSystemFontOfSize:15.0f];
        if ([[RKUserConfig sharedInstance].bgImageName isEqualToString:@"reader_bg_2"] || [[RKUserConfig sharedInstance].bgImageName isEqualToString:@"black"]) {
            _titleLabel.textColor = [UIColor colorWithHexString:@"ffffff"];
        } else {
            _titleLabel.textColor = [UIColor colorWithHexString:@"000000"];
        }
    }
    return _titleLabel;
}

- (UILabel *)summaryLabel {
    if (!_summaryLabel) {
        _summaryLabel = [[UILabel alloc] init];
        _summaryLabel.font = [UIFont systemFontOfSize:12.0f];
        _summaryLabel.numberOfLines = 2;
        _summaryLabel.textColor = kReadViewBottomTintColor;
    }
    return _summaryLabel;
}

- (UILabel *)dateLabel {
    if (!_dateLabel) {
        _dateLabel = [[UILabel alloc] init];
        _dateLabel.font = [UIFont systemFontOfSize:11.0f];
        _dateLabel.textColor = kReadViewBottomTintColor;
    }
    return _dateLabel;
}

@end
