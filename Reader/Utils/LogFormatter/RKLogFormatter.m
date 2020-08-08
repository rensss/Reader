//
//  RKLogFormatter.m
//  Reader
//
//  Created by Rzk on 2020/8/8.
//  Copyright © 2020 Rzk. All rights reserved.
//

#import "RKLogFormatter.h"

@implementation RKLogFormatter

#pragma mark - delegate
- (NSString *)formatLogMessage:(DDLogMessage *)logMessage {
    NSString *logLevel;
    switch (logMessage->_flag) {
        case DDLogFlagError : logLevel = @"❗️Error"; break;
        case DDLogFlagWarning : logLevel = @"⚠️Warning"; break;
        case DDLogFlagInfo : logLevel = @"ℹ️Info"; break;
        case DDLogFlagDebug : logLevel = @"🔧Debug"; break;
        default : logLevel = @"🚩default"; break;
    }
    //以上是根据不同的类型 定义不同的标记字符
    return [NSString stringWithFormat:@"%@ %@[line:%zd]: %@\n", logLevel, logMessage->_function, logMessage->_line, logMessage->_message];
}

@end
