//
//  RKHomeListTableViewCell.m
//  Reader
//
//  Created by Rzk on 2019/4/22.
//  Copyright © 2019 Rzk. All rights reserved.
//

#import "RKHomeListTableViewCell.h"

@interface RKHomeListTableViewCell ()

@property (nonatomic, strong) UIImageView *coverImage; /**< 封面图*/
@property (nonatomic, strong) UILabel *name; /**< 书名*/
@property (nonatomic, strong) UILabel *chapter; /**< 当前章节*/
@property (nonatomic, strong) UILabel *progress; /**< 进度*/
@property (nonatomic, strong) UILabel *size; /**< 大小*/
@property (nonatomic, strong) UIImageView *topImage; /**< 置顶*/

@end

@implementation RKHomeListTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self initUI];
    }
    return self;
}

#pragma mark - func
- (void)initUI {
    
    UIView *bgView = [UIView new];
    [self.contentView addSubview:bgView];
    [bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(self.contentView);
    }];
    
    UIImageView *coverImage = [UIImageView new];
    self.coverImage = coverImage;
    [bgView addSubview:coverImage];
    CGFloat height = 100;
    CGFloat width = height*kCoverImageWidth/kCoverImageHeight;
    [coverImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(width, height));
        make.top.equalTo(bgView).mas_offset(10);
        make.left.equalTo(bgView).mas_offset(10);
    }];
    
    UILabel *name = [UILabel new];
    self.name = name;
    [bgView addSubview:name];
    name.text = @"书名";
    name.textColor = [UIColor blackColor];
    name.font = [UIFont systemFontOfSize:16];
    
    UILabel *chapter = [UILabel new];
    self.chapter = chapter;
    [bgView addSubview:chapter];
    chapter.text = @"当前章节";
    chapter.font = [UIFont systemFontOfSize:14];
    chapter.textColor = [UIColor darkTextColor];
    
    UILabel *progress = [UILabel new];
    self.progress = progress;
    [bgView addSubview:progress];
    progress.text = @"0.00%";
    progress.font = [UIFont systemFontOfSize:12];
    progress.textColor = [UIColor darkTextColor];
    
    UILabel *size = [UILabel new];
    self.size = size;
    [bgView addSubview:size];
    size.text = @"0.00M";
    size.font = [UIFont systemFontOfSize:12];
    size.textColor = [UIColor darkTextColor];

    NSArray *sub = @[name,chapter,progress,size];
    [sub mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(coverImage.mas_right).mas_offset(8);
        make.right.mas_offset(-23);
    }];
    // 固定每项的长高
    [sub mas_distributeViewsAlongAxis:MASAxisTypeVertical withFixedItemLength:16 leadSpacing:10 tailSpacing:10];
    // 固定每个间隔的量
//    [sub mas_distributeViewsAlongAxis:MASAxisTypeVertical withFixedSpacing:5 leadSpacing:10 tailSpacing:10];
    
    UIImageView *topImage = [UIImageView new];
    self.topImage = topImage;
    [bgView addSubview:topImage];
    topImage.image = [UIImage imageNamed:@"top"];
    [topImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(18, 18));
        make.right.mas_offset(-5);
        make.top.mas_offset(5);
    }];
}

#pragma mark - setting
- (void)setBook:(RKBook *)book {
    _book = book;
    
    self.name.text = book.name;
    self.chapter.text = book.currentChapter.title;
    self.coverImage.image = [UIImage imageNamed:book.coverImage];
    self.progress.text = [NSString stringWithFormat:@"%.2f%%",book.progress];
    self.size.text = [NSString stringWithFormat:@"%.2fM",book.size];
    if (book.isTop) {
        self.topImage.hidden = NO;
    } else {
        self.topImage.hidden = YES;
    }
}

@end
