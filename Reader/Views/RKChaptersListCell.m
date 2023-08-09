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

@end

@implementation RKChaptersListCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self.contentView addSubview:self.titleMarqueeView];
        [self.titleMarqueeView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.contentView.mas_top).mas_offset(0);
            make.bottom.equalTo(self.contentView.mas_bottom).mas_offset(0);
            make.leading.equalTo(self.contentView.mas_leading).mas_offset(8);
            make.trailing.equalTo(self.contentView.mas_trailing).mas_offset(-8);
        }];
//        [self.contentView addSubview:self.titleView];
//        [self.titleView mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.top.mas_offset(0);
//            make.left.mas_offset(8);
//            make.bottom.mas_offset(0);
//            make.right.mas_offset(-8);
//        }];
    }
    return self;
}

#pragma mark - 代理
#pragma mark -- RKMarqueeViewDelegate
- (NSUInteger)numberOfDataForMarqueeView:(RKMarqueeView *)marqueeView {
    return 1;
}

- (void)createItemView:(UIView *)itemView forMarqueeView:(RKMarqueeView *)marqueeView {
    UILabel *content = [[UILabel alloc] initWithFrame:itemView.bounds];
    content.font = [UIFont systemFontOfSize:18.0f];
    content.tag = 2345;
    if ([[RKUserConfig sharedInstance].bgImageName isEqualToString:@"reader_bg_2"] || [[RKUserConfig sharedInstance].bgImageName isEqualToString:@"black"]) {
        content.textColor = [UIColor colorWithHexString:@"ffffff" withAlpha:0.6f];
    }
    
    [itemView addSubview:content];
}

- (void)updateItemView:(UIView *)itemView atIndex:(NSUInteger)index forMarqueeView:(RKMarqueeView *)marqueeView {
    UILabel *content = [itemView viewWithTag:2345];
    content.text = [self.chapter.title stringByTrimmingCharactersInSet];
}

- (CGFloat)itemViewWidthAtIndex:(NSUInteger)index forMarqueeView:(RKMarqueeView *)marqueeView {
    // 指定条目在显示数据源内容时的视图宽度，仅[UUMarqueeViewDirectionLeftward]时被调用。
    // ### 在数据源不变的情况下，宽度可以仅计算一次并缓存复用。
    UILabel *content = [[UILabel alloc] init];
    content.font = [UIFont systemFontOfSize:18.0f];
    content.text = self.chapter.title;
    return content.intrinsicContentSize.width;
}

#pragma mark - setting
- (void)setChapter:(RKChapter *)chapter {
    _chapter = chapter;
    self.titleView.text = [self.chapter.title stringByTrimmingCharactersInSet];
    [self.titleMarqueeView reloadData];
}

- (void)setIsCurrent:(BOOL)isCurrent {
    _isCurrent = isCurrent;
    
    if (_isCurrent) {
        if ([RKUserConfig sharedInstance].isChapterListAutoScroll) {
            [self.titleMarqueeView start];
        }
    } else {
        [self.titleMarqueeView pause];
    }
}


#pragma mark - getting
- (RKMarqueeView *)titleMarqueeView {
    if (!_titleMarqueeView) {
        _titleMarqueeView = [[RKMarqueeView alloc] initWithFrame:CGRectZero direction:RKMarqueeViewDirectionLeftward];
        _titleMarqueeView.timeIntervalPerScroll = 0.0f;
        _titleMarqueeView.userInteractionEnabled = NO;
        _titleMarqueeView.scrollSpeed = 60.0f;
        _titleMarqueeView.itemSpacing = 20.0f;
        _titleMarqueeView.delegate = self;
    }
    return _titleMarqueeView;
}

- (UILabel *)titleView {
    if (!_titleView) {
        _titleView = [[UILabel alloc] init];
        _titleView.font = [UIFont systemFontOfSize:18.0f];
        if ([[RKUserConfig sharedInstance].bgImageName isEqualToString:@"reader_bg_2"] || [[RKUserConfig sharedInstance].bgImageName isEqualToString:@"black"]) {
            _titleView.textColor = [UIColor colorWithHexString:@"ffffff" withAlpha:0.6f];
        }
    }
    return _titleView;
}

@end
