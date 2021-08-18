//
//  TTSConfig.m
//  MSCDemo_UI
//
//  Created by wangdan on 15-4-25.
//  Copyright (c) 2015年 iflytek. All rights reserved.
//

#import "TTSConfig.h"

@implementation TTSConfig

- (id)init {
    self  = [super init];
    if (self) {
        [self defaultSetting];
        return  self;
    }
    return nil;
}

+ (TTSConfig *)sharedInstance {
    static TTSConfig  * instance = nil;
    static dispatch_once_t predict;
    dispatch_once(&predict, ^{
        instance = [[TTSConfig alloc] init];
    });
    return instance;
}


- (void)defaultSetting {
    _speed = [NSString stringWithFormat:@"%.0f",RKUserConfig.sharedInstance.rate*100];
    _volume = [NSString stringWithFormat:@"%.0f",RKUserConfig.sharedInstance.volume*100];
    _pitch = [NSString stringWithFormat:@"%.0f",RKUserConfig.sharedInstance.pitchMultiplier*100];
    _sampleRate = @"16000";
    _engineType = RKUserConfig.sharedInstance.engineType;
    _vcnName = @"xiaoyan";
}


@end
