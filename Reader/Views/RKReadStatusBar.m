//
//  RKReadStatusBar.m
//  Reader
//
//  Created by Rzk on 2019/11/11.
//  Copyright © 2019 Rzk. All rights reserved.
//

#import "RKReadStatusBar.h"
#include <dlfcn.h>
//#import <IOKit/IOPowerSources.h>

//IOPowerSources.h，IOPSKeys.h，IOKit
#define kFontSize 12.0

@interface RKReadStatusBar()

@property (nonatomic, strong) NSTimer *updateTime; /**< 更新时间*/

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
            make.height.mas_equalTo(10);
            make.left.mas_equalTo(self).mas_offset(3);
            make.bottom.mas_equalTo(self).mas_offset(-1);
        }];
        
        [self addSubview:self.batteryNum];
        [self.batteryNum mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(10);
            make.top.mas_equalTo(self).mas_offset(1);
            make.left.mas_equalTo(self).mas_offset(3);
        }];
        
        [self addSubview:self.batteryImage];
        [self.batteryImage mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(7);
            make.centerY.mas_equalTo(self.batteryNum);
            make.left.mas_equalTo(self.batteryNum.mas_right).mas_offset(3);
        }];
        
        [self addSubview:self.pageNum];
        [self.pageNum mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(self).mas_offset(-3);
            make.centerY.mas_equalTo(self);
        }];
        
        [self addSubview:self.name];
        [self.name mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(self);
            make.centerY.mas_equalTo(self);
            make.right.mas_equalTo(self.pageNum.mas_left).mas_offset(-5);
            make.left.mas_equalTo(self.batteryImage.mas_right).mas_offset(5);
        }];
        
        [self.batteryImage setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
        [self.name setContentCompressionResistancePriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];
        
        [[UIDevice currentDevice] setBatteryMonitoringEnabled:YES];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReciveBatteryStateDidChangeNotification:) name:UIDeviceBatteryStateDidChangeNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReciveBatteryLevelDidChangeNotification:) name:UIDeviceBatteryLevelDidChangeNotification object:nil];
        
        [self checkBattery:[UIDevice currentDevice]];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
//    DDLogVerbose(@"---> %@ 销毁了",self.class);
}

#pragma mark - func
- (void)updateCurrentTime {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"HH:mm:ss"];

    NSDate *datenow = [NSDate date];
    NSString *currentTimeString = [formatter stringFromDate:datenow];
    
    self.time.text = currentTimeString;
}

- (void)remove {
    [self.updateTime invalidate];
    self.updateTime = nil;
}

/// 根据电量设置图片
- (void)checkBattery:(UIDevice *)device {
    
    float level = device.batteryLevel;
    
//    DDLogVerbose(@"---- level = %f",level);
    
    self.batteryNum.text = [NSString stringWithFormat:@"%.0f",level*100];
    if (level > 0 && level < 0.2f) {
        self.batteryImage.image = [[UIImage imageNamed:@"battery0"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    } else if (level >= 0.2f && level < 0.4f) {
        self.batteryImage.image = [[UIImage imageNamed:@"battery1"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    } else if (level >= 0.4f && level < 0.6f) {
        self.batteryImage.image = [[UIImage imageNamed:@"battery2"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    } else if (level >= 0.6f && level < 0.8f) {
        self.batteryImage.image = [[UIImage imageNamed:@"battery3"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    } else if (level >= 0.8f && level < 0.9f) {
        self.batteryImage.image = [[UIImage imageNamed:@"battery4"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    } else {
        self.batteryImage.image = [[UIImage imageNamed:@"battery5"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    }
    
    if (device.batteryState == UIDeviceBatteryStateCharging) {
        self.batteryImage.tintColor = [UIColor systemGreenColor];
    } else {
        if ([[RKUserConfig sharedInstance].bgImageName isEqualToString:@"black"]) {
            self.batteryImage.tintColor = [UIColor colorWithWhite:1 alpha:[RKUserConfig sharedInstance].nightAlpha];
        } else {
            self.batteryImage.tintColor = [UIColor colorWithHexString:[RKUserConfig sharedInstance].fontColor];
        }
    }
}

- (NSDictionary *)FCPrivateBatteryStatus {
    static mach_port_t *s_klOMasterPortDefault;
    static kern_return_t (*s_IORegistryEntryCreateCFProperties)(mach_port_t entry, CFMutableDictionaryRef *properties, CFAllocatorRef allocator, UInt32 options);
    static mach_port_t (*s_IOServiceGetMatchingService)(mach_port_t masterPort, CFDictionaryRef matching CF_RELEASES_ARGUMENT);
    static CFMutableDictionaryRef (*s_IOServiceMatching)(const char *name);
    
    static CFMutableDictionaryRef g_powerSourceService;
    static mach_port_t g_platformExpertDevice;
    
    static BOOL foundSymbols = NO;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        /*
         dlopen以指定模式打开指定的动态连接库文件，并返回一个句柄给调用进程，dlerror返回出现的错误，dlsym通过句柄和连接符名称获取函数名或者变量名，dlclose来卸载打开的库。 dlopen打开模式如下：
         RTLD_LAZY 暂缓决定，等有需要时再解出符号
         RTLD_NOW 立即决定，返回前解除所有未决定的符号
         */
        void* handle = dlopen("/System/Library/Frameworks/I0Kit.framework/Versions/A/I0Kit", RTLD_LAZY);
        s_IORegistryEntryCreateCFProperties = dlsym(handle, "IORegistryEntryCreateCFProperties");
        s_klOMasterPortDefault = dlsym(handle, "klOMasterPortDefault");
        s_IOServiceMatching = dlsym(handle, "IOServiceMatching");
        s_IOServiceGetMatchingService = dlsym(handle, "IOServiceGetMatchingService");
        if (s_IORegistryEntryCreateCFProperties && s_IOServiceMatching && s_IOServiceGetMatchingService) {
            g_powerSourceService = s_IOServiceMatching("IOPMPowerSource");
            g_platformExpertDevice = s_IOServiceGetMatchingService(*s_klOMasterPortDefault, g_powerSourceService);
            foundSymbols = (g_powerSourceService && g_platformExpertDevice);
        }
    });
    if (!foundSymbols) return nil;
    CFMutableDictionaryRef prop = NULL;
    s_IORegistryEntryCreateCFProperties(g_platformExpertDevice, &prop, 0, 0);
    return prop ? ((NSDictionary *) CFBridgingRelease(prop)) : nil;
}

#pragma mark - 通知
- (void)didReciveBatteryLevelDidChangeNotification:(NSNotification *)notification {
    UIDevice *device = notification.object;
    [self checkBattery:device];
}

- (void)didReciveBatteryStateDidChangeNotification:(NSNotification *)notification {
    UIDevice *device = notification.object;
    [self checkBattery:device];
}

#pragma mark - setting
- (void)setBook:(RKBook *)book {
    _book = book;
    
    [self.updateTime fire];
    
    self.name.text = [NSString stringWithFormat:@"%@ (%.2f%%)",book.name,book.progress*100];
    
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

- (UILabel *)time {
    if (!_time) {
        _time = [[UILabel alloc] init];
        _time.font = [UIFont fontWithName:[RKUserConfig sharedInstance].fontName size:kFontSize-3];
    }
    return _time;
}

- (UIImageView *)batteryImage {
    if (!_batteryImage) {
        _batteryImage = [[UIImageView alloc] init];
    }
    return _batteryImage;
}

- (UILabel *)batteryNum {
    if (!_batteryNum) {
        _batteryNum = [[UILabel alloc] init];
        _batteryNum.font = [UIFont fontWithName:[RKUserConfig sharedInstance].fontName size:kFontSize-3];
    }
    return _batteryNum;
}

- (UILabel *)name {
    if (!_name) {
        _name = [[UILabel alloc] init];
        _name.numberOfLines = 2;
        _name.adjustsFontSizeToFitWidth = YES;
        _name.minimumScaleFactor = 7/kFontSize;
        _name.textAlignment = NSTextAlignmentCenter;
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

- (NSTimer *)updateTime {
    if (!_updateTime) {
        _updateTime = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(updateCurrentTime) userInfo:nil repeats:YES];
    }
    return _updateTime;
}

@end
