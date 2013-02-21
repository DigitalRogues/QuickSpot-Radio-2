//
//  LumberjackFormatter.m
//  QuickSpot Radio
//
//  Created by punk on 2/6/13.
//  Copyright (c) 2013 Digital Rogues. All rights reserved.
//

#import "LumberjackFormatter.h"

@implementation LumberjackFormatter


- (NSString*)formatLogMessage:(DDLogMessage *)logMessage
{
    NSString* logLevel = nil;
    switch (logMessage->logLevel) {
        case LOG_FLAG_ERROR : logLevel = @"E"; break;
        case LOG_FLAG_WARN  : logLevel = @"W"; break;
        case LOG_FLAG_INFO  : logLevel = @"I"; break;
        default             : logLevel = @"V"; break;
    }
    
    return [NSString stringWithFormat:@"[%@]:[%@ %@]:[Line %d] %@",
            logLevel,
            logMessage.fileName,
            logMessage.methodName,
            logMessage->lineNumber,
            logMessage->logMsg];
}


@end
