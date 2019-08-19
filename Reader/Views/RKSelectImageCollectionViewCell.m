//
//  RKSelectImageCollectionViewCell.m
//  Reader
//
//  Created by Rzk on 2019/8/19.
//  Copyright © 2019 Rzk. All rights reserved.
//

#import "RKSelectImageCollectionViewCell.h"

@interface RKSelectImageCollectionViewCell ()

@property (nonatomic, strong) UIImageView *coverImage; /**< 图*/

@end

@implementation RKSelectImageCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self.contentView addSubview:self.coverImage];
    }
    return self;
}

- (void)setSelected:(BOOL)selected {
    if (selected) {
        self.coverImage.layer.borderColor = [UIColor orangeColor].CGColor;
        self.coverImage.layer.borderWidth = 2.0f;
    } else {
        self.coverImage.layer.borderColor = [UIColor clearColor].CGColor;
        self.coverImage.layer.borderWidth = 0.0f;
    }
}

#pragma mark - setting
- (void)setImageName:(NSString *)imageName {
    _imageName = imageName;
    self.coverImage.image = [UIImage imageNamed:imageName];
}

#pragma mark - getting
- (UIImageView *)coverImage {
    if (!_coverImage) {
        _coverImage = [[UIImageView alloc] initWithFrame:self.bounds];
        _coverImage.clipsToBounds = YES;
        _coverImage.contentMode = UIViewContentModeScaleAspectFill;
    }
    return _coverImage;
}

@end
