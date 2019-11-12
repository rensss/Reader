//
//  RKReadStatusBar.m
//  Reader
//
//  Created by Rzk on 2019/11/11.
//  Copyright © 2019 Rzk. All rights reserved.
//

#import "RKReadStatusBar.h"

@interface RKReadStatusBar()

@property (nonatomic, strong) UIImageView *batteryImage; /**< 电池*/
@property (nonatomic, strong) UILabel *batteryNum; /**< 电量数据*/

@property (nonatomic, strong) UILabel *time; /**< 时间*/

@property (nonatomic, strong) UILabel *name; /**< 书名、章节、进度*/
@property (nonatomic, strong) UILabel *pageNum; /**< 页码*/

@end

@implementation RKReadStatusBar
#pragma mark - lifeCycle
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        if ([[RKUserConfig sharedInstance].bgImageName isEqualToString:@"black"]) {
            self.backgroundColor = [UIColor colorWithWhite:1 alpha:0.2f];
        }
        [self addSubview:self.batteryImage];
        [self addSubview:self.batteryNum];
        [self addSubview:self.time];
        [self addSubview:self.name];
        [self addSubview:self.pageNum];
        
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReciveBatteryStateDidChangeNotification:) name:UIDeviceBatteryStateDidChangeNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReciveBatteryLevelDidChangeNotification:) name:UIDeviceBatteryLevelDidChangeNotification object:nil];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    RKLog(@"--- %@ 销毁了",self.class);
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
    }
    return _batteryNum;
}

- (UILabel *)time {
    if (!_time) {
        
    }
    return _time;
}

- (UILabel *)name {
    if (!_name) {
        
    }
    return _name;
}

- (UILabel *)pageNum {
    if (!_pageNum) {
        
    }
    return _pageNum;
}


@end
