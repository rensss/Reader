//
//  RKTTSManager.m
//  Reader
//
//  Created by Rzk on 2021/7/15.
//  Copyright © 2021 RK. All rights reserved.
//

#import "RKTTSManager.h"
#import <AVFoundation/AVFoundation.h>

@interface RKTTSManager () <AVSpeechSynthesizerDelegate>

@property (nonatomic, strong) AVSpeechSynthesizer *synth; /**< */

@end

@implementation RKTTSManager

#pragma mark - lifeCycle
- (void)dealloc {
    DDLogInfo(@"---- %@ dealloc!", self);
}

#pragma mark - func
- (void)startSpeechWithContent:(NSString *)string {
    self.currentContent = string;
    
    // 语音播报
    AVSpeechUtterance *utterance = [AVSpeechUtterance speechUtteranceWithString:string];
    
    // 音调
    utterance.pitchMultiplier = RKUserConfig.sharedInstance.pitchMultiplier;
    // 音速
    utterance.rate = RKUserConfig.sharedInstance.rate;
    // 音量
    utterance.volume = RKUserConfig.sharedInstance.volume;
    
    // 中式发音
    AVSpeechSynthesisVoice *voice = [AVSpeechSynthesisVoice voiceWithLanguage:@"zh-CN"];
    utterance.voice = voice;
    
    DDLogInfo(@"---- %f -- %f -- %f", RKUserConfig.sharedInstance.pitchMultiplier, RKUserConfig.sharedInstance.rate, RKUserConfig.sharedInstance.volume);
    
    self.synth = [[AVSpeechSynthesizer alloc] init];
    self.synth.delegate = self;
    [self.synth speakUtterance:utterance];
    
    if (@available(iOS 13.0, *)) {
        self.synth.mixToTelephonyUplink = YES;
    }
}

- (void)stop {
    [self.synth stopSpeakingAtBoundary:AVSpeechBoundaryImmediate];
    
    self.synth.delegate = nil;
    self.synth = nil;
}

- (void)pause {
    [self.synth pauseSpeakingAtBoundary:AVSpeechBoundaryImmediate];
}

- (void)continueSpeaking {
    [self.synth continueSpeaking];
}

#pragma mark - delegate
#pragma mark -- AVSpeechSynthesizerDelegate
- (void)speechSynthesizer:(AVSpeechSynthesizer *)synthesizer didStartSpeechUtterance:(AVSpeechUtterance *)utterance {
    DDLogInfo(@"---- didStartSpeechUtterance");
    if ([self.delegate respondsToSelector:@selector(didStartSpeechUtteranceForRKTTSManager:)]) {
        [self.delegate didStartSpeechUtteranceForRKTTSManager:self];
    }
}

- (void)speechSynthesizer:(AVSpeechSynthesizer *)synthesizer didFinishSpeechUtterance:(AVSpeechUtterance *)utterance{
    DDLogInfo(@"---- didFinishSpeechUtterance");
    if ([self.delegate respondsToSelector:@selector(didFinishSpeechUtteranceForRKTTSManager:)]) {
        [self.delegate didFinishSpeechUtteranceForRKTTSManager:self];
    }
}

- (void)speechSynthesizer:(AVSpeechSynthesizer *)synthesizer didPauseSpeechUtterance:(AVSpeechUtterance *)utterance {
    DDLogInfo(@"---- didPauseSpeechUtterance");
    if ([self.delegate respondsToSelector:@selector(didPauseSpeechUtteranceForRKTTSManager:)]) {
        [self.delegate didPauseSpeechUtteranceForRKTTSManager:self];
    }
}

- (void)speechSynthesizer:(AVSpeechSynthesizer *)synthesizer didContinueSpeechUtterance:(AVSpeechUtterance *)utterance {
    DDLogInfo(@"---- didContinueSpeechUtterance");
    if ([self.delegate respondsToSelector:@selector(didContinueSpeechUtteranceForRKTTSManager:)]) {
        [self.delegate didContinueSpeechUtteranceForRKTTSManager:self];
    }
}

- (void)speechSynthesizer:(AVSpeechSynthesizer *)synthesizer didCancelSpeechUtterance:(AVSpeechUtterance *)utterance {
    DDLogInfo(@"---- didCancelSpeechUtterance");
    if ([self.delegate respondsToSelector:@selector(didCancelSpeechUtteranceForRKTTSManager:)]) {
        [self.delegate didCancelSpeechUtteranceForRKTTSManager:self];
    }
}

- (void)speechSynthesizer:(AVSpeechSynthesizer *)synthesizer willSpeakRangeOfSpeechString:(NSRange)characterRange utterance:(AVSpeechUtterance *)utterance {
    NSString *willString = [utterance.speechString substringWithRange:characterRange];
    DDLogInfo(@"---- willSpeakRangeOfSpeechString -- %@", willString);
    if ([self.delegate respondsToSelector:@selector(RKTTSManager:willSpeakRangeOfSpeechString:utterance:)]) {
        [self.delegate RKTTSManager:self willSpeakRangeOfSpeechString:characterRange utterance:utterance];
    }
}

@end
