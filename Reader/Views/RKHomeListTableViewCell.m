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
    [bgView autoPinEdgesToSuperviewEdges];
    
    UIImageView *coverImage = [UIImageView new];
    self.coverImage = coverImage;
    coverImage.backgroundColor = [UIColor cyanColor];
    [bgView addSubview:coverImage];
    [coverImage autoSetDimension:ALDimensionWidth toSize:60];
    [coverImage autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsMake(5, 5, 5, 0) excludingEdge:ALEdgeRight];
    
    UILabel *name = [UILabel new];
    self.name = name;
    [bgView addSubview:name];
    name.text = @"书名";
    name.textColor = [UIColor blackColor];
    name.font = [UIFont systemFontOfSize:16];
    [name autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:coverImage withOffset:8];
    
    UILabel *chapter = [UILabel new];
    self.chapter = chapter;
    [bgView addSubview:chapter];
    chapter.text = @"当前章节";
    chapter.font = [UIFont systemFontOfSize:10];
    chapter.textColor = [UIColor darkTextColor];
    [chapter autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:coverImage withOffset:8];
    
    UILabel *progress = [UILabel new];
    self.progress = progress;
    [bgView addSubview:progress];
    progress.text = @"0.00%";
    progress.font = [UIFont systemFontOfSize:10];
    progress.textColor = [UIColor darkTextColor];
    [progress autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:coverImage withOffset:8];
    
    UILabel *size = [UILabel new];
    self.size = size;
    [bgView addSubview:size];
    size.text = @"0.00M";
    size.font = [UIFont systemFontOfSize:10];
    size.textColor = [UIColor darkTextColor];
    [size autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:coverImage withOffset:8];
    
    NSArray *sub = @[name,chapter,progress,size];
    [sub autoDistributeViewsAlongAxis:ALAxisVertical alignedTo:ALAttributeVertical withFixedSpacing:5];
    
    UIImageView *topImage = [UIImageView new];
    self.topImage = topImage;
    [bgView addSubview:topImage];
    topImage.image = [UIImage imageNamed:@"top"];
    [topImage autoSetDimensionsToSize:CGSizeMake(18, 18)];
    [topImage autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:5];
    [topImage autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:5];
}

#pragma mark - setting
- (void)setBook:(RKBook *)book {
    _book = book;
    
    self.name.text = book.name;
    self.chapter.text = book.chapter.chapterName;
    self.progress.text = [NSString stringWithFormat:@"%.2f",book.progress];
    self.size.text = [NSString stringWithFormat:@"%.2f",book.size/1024];
    if (book.isTop) {
        self.topImage.hidden = NO;
    } else {
        self.topImage.hidden = YES;
    }
}

@end
