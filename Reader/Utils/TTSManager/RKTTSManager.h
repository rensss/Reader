//
//  RKTTSManager.h
//  Reader
//
//  Created by Rzk on 2021/7/15.
//  Copyright © 2021 RK. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

@class RKTTSManager;
@protocol RKTTSManagerDelegate <NSObject>

@optional
- (void)didStartSpeechUtteranceForRKTTSManager:(RKTTSManager *)manager;
- (void)didFinishSpeechUtteranceForRKTTSManager:(RKTTSManager *)manager;
- (void)didPauseSpeechUtteranceForRKTTSManager:(RKTTSManager *)manager;
- (void)didContinueSpeechUtteranceForRKTTSManager:(RKTTSManager *)manager;
- (void)didCancelSpeechUtteranceForRKTTSManager:(RKTTSManager *)manager;
- (void)RKTTSManager:(RKTTSManager *)manager willSpeakRangeOfSpeechString:(NSRange)characterRange utterance:(AVSpeechUtterance *)utterance;

@end

@interface RKTTSManager : NSObject

@property (nonatomic, weak) id<RKTTSManagerDelegate> delegate; /**< 代理*/
@property (nonatomic, copy) NSString *currentContent; /**< 当前阅读内容*/
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
