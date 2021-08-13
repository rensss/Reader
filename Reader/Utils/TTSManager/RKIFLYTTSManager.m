//
//  RKIFLYTTSManager.m
//  Reader
//
//  Created by Rzk on 2021/8/12.
//  Copyright © 2021 RK. All rights reserved.
//

#import "RKIFLYTTSManager.h"
#import "TTSConfig.h"

#define kIFlyAppid @"c98826dd"

@implementation RKIFLYTTSManager

#pragma mark - lifeCycle
- (instancetype)init {
    self = [super init];
    if (self) {
        [self initSynthesizer];
    }
    return self;
}

#pragma mark -- initSynthesizer
- (void)initSynthesizer {
    //设置语音合成的启动参数
//    [[IFlySpeechUtility getUtility] setParameter:@"tts" forKey:[IFlyResourceUtil ENGINE_START]];
    //获得语音合成的单例
//    _iFlySpeechSynthesizer = [IFlySpeechSynthesizer sharedInstance];
//    //set speed,range from 1 to 100.
//    [_iFlySpeechSynthesizer setParameter:[NSString stringWithFormat:@"%.0f",RKUserConfig.sharedInstance.rate*100] forKey:[IFlySpeechConstant SPEED]];
//    //set volume,range from 1 to 100.
//    [_iFlySpeechSynthesizer setParameter:[NSString stringWithFormat:@"%.0f",RKUserConfig.sharedInstance.volume*100] forKey:[IFlySpeechConstant VOLUME]];
//    //set pitch,range from 1 to 100.
//    [_iFlySpeechSynthesizer setParameter:[NSString stringWithFormat:@"%.0f",RKUserConfig.sharedInstance.pitchMultiplier*100] forKey:[IFlySpeechConstant PITCH]];
//    //设置协议委托对象
//    _iFlySpeechSynthesizer.delegate = self;
//    //设置本地引擎类型
//    [_iFlySpeechSynthesizer setParameter:[IFlySpeechConstant TYPE_LOCAL] forKey:[IFlySpeechConstant ENGINE_TYPE]];
//    //设置发音人为小燕
//    [_iFlySpeechSynthesizer setParameter:@"xiaoyan" forKey:[IFlySpeechConstant VOICE_NAME]];
    
    
    TTSConfig *instance = [[TTSConfig alloc] init];
    if (instance == nil) { return; }
    
    //TTS singleton
    if (_iFlySpeechSynthesizer == nil) {
        _iFlySpeechSynthesizer = [IFlySpeechSynthesizer sharedInstance];
    }
    
    _iFlySpeechSynthesizer.delegate = self;
    
    //set the resource path, only for offline TTS
    NSString *resPath = [[NSBundle mainBundle] resourcePath];
    NSString *newResPath = [[NSString alloc] initWithFormat:@"%@/aisound/common.jet;%@/aisound/xiaoyan.jet;%@/aisound/xiaofeng.jet",resPath,resPath,resPath];
    
    NSArray *pathArray = [newResPath componentsSeparatedByString:@";"];
    [pathArray enumerateObjectsUsingBlock:^(NSString *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        BOOL result = [[NSFileManager defaultManager] fileExistsAtPath:obj];
        DDLogInfo(@"%@ - %@", obj, result ? @"YES" : @"NO");
    }];
    
    [[IFlySpeechUtility getUtility] setParameter:@"tts" forKey:[IFlyResourceUtil ENGINE_START]];
    [_iFlySpeechSynthesizer setParameter:newResPath forKey:@"tts_res_path"];

    //set speed,range from 1 to 100.
    [_iFlySpeechSynthesizer setParameter:instance.speed forKey:[IFlySpeechConstant SPEED]];
    
    //set volume,range from 1 to 100.
    [_iFlySpeechSynthesizer setParameter:instance.volume forKey:[IFlySpeechConstant VOLUME]];
    
    //set pitch,range from 1 to 100.
    [_iFlySpeechSynthesizer setParameter:instance.pitch forKey:[IFlySpeechConstant PITCH]];
    
    //set sample rate
    [_iFlySpeechSynthesizer setParameter:instance.sampleRate forKey:[IFlySpeechConstant SAMPLE_RATE]];
    
    //set TTS speaker
    [_iFlySpeechSynthesizer setParameter:instance.vcnName forKey:[IFlySpeechConstant VOICE_NAME]];
    
    //set text encoding mode
    [_iFlySpeechSynthesizer setParameter:@"unicode" forKey:[IFlySpeechConstant TEXT_ENCODING]];
    
    //set engine type
    [_iFlySpeechSynthesizer setParameter:instance.engineType forKey:[IFlySpeechConstant ENGINE_TYPE]];
    
}

#pragma mark - func
- (void)startSpeechWithContent:(NSString *)string {
    self.currentContent = string;
    
    _iFlySpeechSynthesizer.delegate = self;
    
    [_iFlySpeechSynthesizer startSpeaking:string];
    if (_iFlySpeechSynthesizer.isSpeaking) {
        _state = Playing;
    }
}

- (void)stop {
    [_iFlySpeechSynthesizer stopSpeaking];
}

- (void)pause {
    [_iFlySpeechSynthesizer pauseSpeaking];
}

- (void)continueSpeaking {
    [_iFlySpeechSynthesizer resumeSpeaking];
}

#pragma mark - IFlySpeechSynthesizerDelegate

/**
 callback of starting playing
 Notice：
    Only apply to normal TTS
 **/
- (void)onSpeakBegin {
    self.isCanceled = NO;
    _state = Playing;
    
    if ([self.delegate respondsToSelector:@selector(onSpeakBeginForRKIFLYTTSManager:)]) {
        [self.delegate onSpeakBeginForRKIFLYTTSManager:self];
    }
}

/**
 callback of buffer progress
 Notice：
    Only apply to normal TTS
 **/
- (void)onBufferProgress:(int)progress message:(NSString *)msg {
    DDLogInfo(@"buffer progress %2d%%. msg: %@.", progress, msg);
    
    if ([self.delegate respondsToSelector:@selector(onBufferProgress:message:RKIFLYTTSManager:)]) {
        [self.delegate onBufferProgress:progress message:msg RKIFLYTTSManager:self];
    }
}

/**
 callback of playback progress
 Notice：
    Only apply to normal TTS
 **/
- (void)onSpeakProgress:(int)progress beginPos:(int)beginPos endPos:(int)endPos {
    DDLogInfo(@"speak progress %2d%%, beginPos=%d, endPos=%d", progress, beginPos, endPos);
    
    if ([self.delegate respondsToSelector:@selector(onSpeakProgress:beginPos:endPos:RKIFLYTTSManager:)]) {
        [self.delegate onSpeakProgress:progress beginPos:beginPos endPos:endPos RKIFLYTTSManager:self];
    }
}

/**
 callback of pausing player
 Notice：
    Only apply to normal TTS
 **/
- (void)onSpeakPaused {
    _state = Paused;
    
    if ([self.delegate respondsToSelector:@selector(onSpeakPausedForRKIFLYTTSManager:)]) {
        [self.delegate onSpeakPausedForRKIFLYTTSManager:self];
    }
}

/**
 callback of TTS completion
 **/
- (void)onCompleted:(IFlySpeechError *)error {
    
    if (error.errorCode != 0) {
        self.hasError = YES;
        NSString *message = [NSString stringWithFormat:@"code:%d\ntype:%d\nmessage:%@", error.errorCode, error.errorType, error.errorDesc];
        DDLogError(@"error:\n%@", message);
        
        if(error.errorCode == 10102) {
            RKAlertMessage(@"缺乏离线资源文件", kKeyWindow);
        } else {
            RKAlertMessageShowInWindowAndDelay(message, 5);
        }
        return;
    }
   
    NSString *text;
    if (self.isCanceled) {
        text = @"合成已取消";
    } else if (error.errorCode == 0) {
        text = @"合成结束";
    }
    
    _state = NotStart;
    
    DDLogInfo(@"---- %@", text);
    
    if ([self.delegate respondsToSelector:@selector(onCompletedRKIFLYTTSManager:)]) {
        [self.delegate onCompletedRKIFLYTTSManager:self];
    }
}

@end
