//
//  RKReadStatusBar.m
//  Reader
//
//  Created by Rzk on 2019/11/11.
//  Copyright © 2019 Rzk. All rights reserved.
//

#import "RKReadStatusBar.h"

#define kFontSize 12

@interface RKReadStatusBar()

@property (nonatomic, strong) UILabel *time; /**< 时间*/

@property (nonatomic, strong) UIImageView *batteryImage; /**< 电池*/
@property (nonatomic, strong) UILabel *batteryNum; /**< 电量数据*/

@property (nonatomic, strong) UILabel *name; /**< 书名、章节、进度*/
@property (nonatomic, strong) UILabel *pageNum; /**< 页码*/

@end

@implementation RKReadStatusBar
#pragma mark - lifeCycle
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        if ([[RKUserConfig sharedInstance].bgImageName isEqualToString:@"black"]) {
            self.backgroundColor = [UIColor colorWithWhite:1 alpha:0.2f];
        } else {
            self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.2f];
        }
        [self addSubview:self.time];
        [self.time mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self).mas_offset(3);
            make.centerY.equalTo(self);
        }];
        
        [self addSubview:self.batteryImage];
        [self.batteryImage mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.time.mas_right).mas_offset(3);
            make.centerY.equalTo(self);
        }];
        
        [self addSubview:self.batteryNum];
        [self.batteryNum mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.batteryImage.mas_right).mas_offset(3);
            make.centerY.equalTo(self);
        }];
        
        [self addSubview:self.name];
        [self.name mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self);
            make.centerY.equalTo(self);
        }];
        
        [self addSubview:self.pageNum];
        [self.pageNum mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self).mas_offset(-3);
            make.centerY.equalTo(self);
        }];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReciveBatteryStateDidChangeNotification:) name:UIDeviceBatteryStateDidChangeNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReciveBatteryLevelDidChangeNotification:) name:UIDeviceBatteryLevelDidChangeNotification object:nil];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
//    RKLog(@"---> %@ 销毁了",self.class);
}

#pragma mark - 事件


#pragma mark - func


#pragma mark - 通知
- (void)didReciveBatteryLevelDidChangeNotification:(NSNotification *)notification {
    RKLog(@"---- level");
}

- (void)didReciveBatteryStateDidChangeNotification:(NSNotification *)notification {
    RKLog(@"---- State");
}

#pragma mark - setting
- (void)setBook:(RKBook *)book {
    _book = book;
    
    self.time.text = @"00:00";
    
    self.batteryImage.image = [UIImage imageNamed:@"battery5"];
    
    self.batteryNum.text = @"100%";
    
    self.name.text = [NSString stringWithFormat:@"%@(%.2f%%)",book.name,book.progress*100];
    
    self.pageNum.text = [NSString stringWithFormat:@"%ld/%ld",(long)book.currentChapter.page + 1,(long)book.currentChapter.allPages];
    
    UIColor *textColor;
    if ([[RKUserConfig sharedInstance].bgImageName isEqualToString:@"black"]) {
        textColor = [UIColor colorWithWhite:1 alpha:[RKUserConfig sharedInstance].nightAlpha];
    } else {
        textColor = [UIColor colorWithHexString:[RKUserConfig sharedInstance].fontColor];
    }
    self.time.textColor = self.batteryNum.textColor = self.name.textColor = self.pageNum.textColor = textColor;
}

#pragma mark - getting
- (UIImageView *)batteryImage {
    if (!_batteryImage) {
        _batteryImage = [[UIImageView alloc] init];
    }
    return _batteryImage;
}

- (UILabel *)batteryNum {
    if (!_batteryNum) {
        _batteryNum = [[UILabel alloc] init];
        _batteryNum.font = [UIFont fontWithName:[RKUserConfig sharedInstance].fontName size:kFontSize];
    }
    return _batteryNum;
}

- (UILabel *)time {
    if (!_time) {
        _time = [[UILabel alloc] init];
        _time.font = [UIFont fontWithName:[RKUserConfig sharedInstance].fontName size:kFontSize];
    }
    return _time;
}

- (UILabel *)name {
    if (!_name) {
        _name = [[UILabel alloc] init];
        _name.font = [UIFont fontWithName:[RKUserConfig sharedInstance].fontName size:kFontSize];
    }
    return _name;
}

- (UILabel *)pageNum {
    if (!_pageNum) {
        _pageNum = [[UILabel alloc] init];
        _pageNum.font = [UIFont fontWithName:[RKUserConfig sharedInstance].fontName size:kFontSize];
    }
    return _pageNum;
}


@end
