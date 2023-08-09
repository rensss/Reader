//
//  RKIFLYTTSManager.m
//  Reader
//
//  Created by Rzk on 2021/8/12.
//  Copyright © 2021 RK. All rights reserved.
//

#import "RKIFLYTTSManager.h"
#import "TTSConfig.h"

#define kIFlyAppid @"0c589578"

@implementation RKIFLYTTSManager

#pragma mark - lifeCycle
- (instancetype)init {
    self = [super init];
    if (self) {
        [self initSynthesizer];
    }
    return self;
}

- (void)dealloc {
    DDLogInfo(@"%@ 销毁了!", [self class]);
}

#pragma mark -- initSynthesizer
- (void)initSynthesizer {
    TTSConfig *instance = [[TTSConfig alloc] init];
    if (instance == nil) { return; }
    //设置语音合成的启动参数
    [[IFlySpeechUtility getUtility] setParameter:@"tts" forKey:[IFlyResourceUtil ENGINE_START]];
    //获得语音合成的单例
    _iFlySpeechSynthesizer = [IFlySpeechSynthesizer sharedInstance];
    //设置协议委托对象
    _iFlySpeechSynthesizer.delegate = self;
    //set speed,range from 1 to 100.
    [_iFlySpeechSynthesizer setParameter:instance.speed forKey:[IFlySpeechConstant SPEED]];
    //set volume,range from 1 to 100.
    [_iFlySpeechSynthesizer setParameter:instance.volume forKey:[IFlySpeechConstant VOLUME]];
    //set pitch,range from 1 to 100.
    [_iFlySpeechSynthesizer setParameter:instance.pitch forKey:[IFlySpeechConstant PITCH]];
    //设置本地引擎类型，普通版设置为TYPE_LOCAL，高品质版设置为TYPE_LOCAL_XTTS
    [_iFlySpeechSynthesizer setParameter:instance.engineType forKey:[IFlySpeechConstant ENGINE_TYPE]];
    //设置发音人为小燕
    [_iFlySpeechSynthesizer setParameter:instance.vcnName forKey:[IFlySpeechConstant VOICE_NAME]];
    //获取离线语音合成发音人资源文件路径。以发音人小燕为例，请确保资源文件的存在。
    NSString *resPath = [[NSBundle mainBundle] resourcePath];
    NSString *vcnResPath = [[NSString alloc] initWithFormat:@"%@/aisound/common.jet;%@/aisound/xiaoyan.jet",resPath,resPath];
    //设置离线语音合成发音人资源文件路径
    [_iFlySpeechSynthesizer setParameter:vcnResPath forKey:@"tts_res_path"];
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
    } else {
        text = @"合成结束";
    }
    
    _state = NotStart;
    
    DDLogInfo(@"---- %@", text);
    
    if ([self.delegate respondsToSelector:@selector(onCompletedRKIFLYTTSManager:)]) {
        [self.delegate onCompletedRKIFLYTTSManager:self];
    }
}

@end
