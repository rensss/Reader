//
//  RKChaptersListCell.m
//  Reader
//
//  Created by Rzk on 2020/4/23.
//  Copyright © 2020 Rzk. All rights reserved.
//

#import "RKChaptersListCell.h"

@interface RKChaptersListCell () <RKMarqueeViewDelegate>

@property (nonatomic, strong) RKMarqueeView *titleMarqueeView; /**< 标题*/
@property (nonatomic, strong) UILabel *titleView; /**< 章节名*/
@property (nonatomic, assign) CGFloat itemViewWidth; /**< title 宽度缓存 */

@end

@implementation RKChaptersListCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self.contentView addSubview:self.titleMarqueeView];
        [self.titleMarqueeView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_offset(0);
            make.left.mas_offset(8);
            make.bottom.mas_offset(0);
            make.right.mas_offset(-8);
        }];
        
        [self.contentView addSubview:self.titleView];
        [self.titleView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_offset(0);
            make.left.mas_offset(8);
            make.bottom.mas_offset(0);
            make.right.mas_offset(-8);
        }];
    }
    return self;
}

#pragma mark - 代理
#pragma mark -- RKMarqueeViewDelegate
- (NSUInteger)numberOfDataForMarqueeView:(RKMarqueeView *)marqueeView {
    return 1;
}

- (void)createItemView:(UIView *)itemView forMarqueeView:(RKMarqueeView *)marqueeView {
    UILabel *content = [[UILabel alloc] init];
    content.font = [UIFont systemFontOfSize:20];
    content.text = [self.chapter.title stringByTrimmingWhitespaceAndAllNewLine];
    if ([[RKUserConfig sharedInstance].bgImageName isEqualToString:@"reader_bg_2"] || [[RKUserConfig sharedInstance].bgImageName isEqualToString:@"black"]) {
        content.textColor = [UIColor colorWithHexString:@"ffffff"];
    } else {
        content.textColor = [UIColor colorWithHexString:@"000000"];
    }
    [itemView addSubview:content];
    [content mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(itemView);
    }];
}

- (void)updateItemView:(UIView *)itemView atIndex:(NSUInteger)index forMarqueeView:(RKMarqueeView *)marqueeView {
    for (UIView *sub in itemView.subviews) {
        if ([sub isKindOfClass:[UILabel class]]) {
            UILabel *label = (UILabel *)sub;
            label.text = [self.chapter.title stringByTrimmingWhitespaceAndAllNewLine];
        }
    }
}

- (CGFloat)itemViewWidthAtIndex:(NSUInteger)index forMarqueeView:(RKMarqueeView *)marqueeView {
    // 指定条目在显示数据源内容时的视图宽度，仅[UUMarqueeViewDirectionLeftward]时被调用。
    // 在数据源不变的情况下，宽度可以仅计算一次并缓存复用。
    return self.itemViewWidth;
}

#pragma mark - setting
- (void)setChapter:(RKChapter *)chapter {
    _chapter = chapter;
    
    self.titleView.text = [self.chapter.title stringByTrimmingWhitespaceAndAllNewLine];
    self.itemViewWidth = [self.titleView.text boundingRectWithSize:CGSizeMake(1000, 50) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:20]} context:nil].size.width;
    
    if (self.isCurrent) {
        [self.titleMarqueeView reloadData];
    }
}

- (void)setIsCurrent:(BOOL)isCurrent {
    _isCurrent = isCurrent;
    
    if (isCurrent) {
        self.accessoryType = UITableViewCellAccessoryCheckmark;
        self.titleView.hidden = YES;
        self.titleMarqueeView.hidden = NO;
        [self.titleMarqueeView reloadData];
        [self.titleMarqueeView start];
    } else {
        self.accessoryType = UITableViewCellAccessoryNone;
        self.titleView.hidden = NO;
        self.titleMarqueeView.hidden = YES;
    }
}


#pragma mark - getting
- (RKMarqueeView *)titleMarqueeView {
    if (!_titleMarqueeView) {
        _titleMarqueeView = [[RKMarqueeView alloc] initWithFrame:CGRectZero direction:RKMarqueeViewDirectionLeftward];
        _titleMarqueeView.timeIntervalPerScroll = 0.0f;
        _titleMarqueeView.userInteractionEnabled = NO;
        _titleMarqueeView.scrollSpeed = 60.0f;
        _titleMarqueeView.itemSpacing = 10.0f;
        _titleMarqueeView.delegate = self;
        _titleMarqueeView.hidden = YES;
    }
    return _titleMarqueeView;
}

- (UILabel *)titleView {
    if (!_titleView) {
        _titleView = [[UILabel alloc] init];
        _titleView.font = [UIFont systemFontOfSize:18.0f];
        if ([[RKUserConfig sharedInstance].bgImageName isEqualToString:@"reader_bg_2"] || [[RKUserConfig sharedInstance].bgImageName isEqualToString:@"black"]) {
            _titleView.textColor = [UIColor colorWithHexString:@"ffffff" withAlpha:0.6f];
        } else {
            _titleView.textColor = [UIColor colorWithHexString:@"000000"];
        }
    }
    return _titleView;
}

@end
