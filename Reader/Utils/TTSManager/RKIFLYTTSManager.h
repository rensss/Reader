//
//  RKIFLYTTSManager.h
//  Reader
//
//  Created by Rzk on 2021/8/12.
//  Copyright © 2021 RK. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <iflyMSC/iflyMSC.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_OPTIONS(NSInteger, SynthesizeType) {
    NomalType           = 5,    //Normal TTS
    UriType             = 6,    //URI TTS
};

//state of TTS
typedef NS_OPTIONS(NSInteger, Status) {
    NotStart            = 0,
    Playing             = 2,
    Paused              = 4,
};


@class RKIFLYTTSManager;
@protocol RKIFLYTTSManagerDelegate <NSObject>

@optional
- (void)onSpeakBeginForRKIFLYTTSManager:(RKIFLYTTSManager *)manager;
- (void)onSpeakPausedForRKIFLYTTSManager:(RKIFLYTTSManager *)manager;
- (void)onBufferProgress:(int)progress message:(NSString *)msg RKIFLYTTSManager:(RKIFLYTTSManager *)manager;
- (void)onSpeakProgress:(int)progress beginPos:(int)beginPos endPos:(int)endPos RKIFLYTTSManager:(RKIFLYTTSManager *)manager;
- (void)onCompletedRKIFLYTTSManager:(RKIFLYTTSManager *)manager;
//- (void)RKIFLYTTSManager:(RKIFLYTTSManager *)manager willSpeakRangeOfSpeechString:(NSRange)characterRange utterance:(AVSpeechUtterance *)utterance;

@end

@interface RKIFLYTTSManager : NSObject <IFlySpeechSynthesizerDelegate>

@property (nonatomic, weak) id<RKIFLYTTSManagerDelegate> delegate; /**< 代理*/
@property (nonatomic, copy) NSString *currentContent; /**< 当前阅读内容*/

@property (nonatomic, strong) IFlySpeechSynthesizer * iFlySpeechSynthesizer;

@property (nonatomic, assign) BOOL isCanceled;
@property (nonatomic, assign) BOOL hasError;

@property (nonatomic, assign) Status state;
@property (nonatomic, assign) SynthesizeType synType;

/// 开始阅读
/// @param string 内容
- (void)startSpeechWithContent:(NSString *)string;

/// 停止speak
- (void)stop;

/// 暂停
- (void)pause;

/// 继续
- (void)continueSpeaking;

@end

NS_ASSUME_NONNULL_END
