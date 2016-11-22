/*
 * Copyright (c) 2015 - present, Cullaboration Media, LLC.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import "UHPush.h"
#import "UserHook.h"
#import "UHOperation.h"

// debug builds will use the push sandbox environment, so we need to check for that
#ifdef DEBUG
static NSString * pushEnvironment = @"dev";
#else
static NSString * pushEnvironment = @"prod";
#endif

@implementation UHPush

+(void) registerDeviceToken:(NSData *)deviceToken {
    
    NSString * deviceTokenString = [self convertToNSString:deviceToken];
    [self registerDeviceTokenString:deviceTokenString];
    
}


+(void) registerDeviceTokenString:(NSString *)tokenString {
    
    UHOperation * operation = [UHOperation new];
    [operation registerDeviceToken:tokenString forEnvironment:pushEnvironment retryCount:1];
}

+ (NSString *) convertToNSString:(NSData *)deviceToken {
    NSString *tokenStr = [deviceToken description];
    NSString *pushToken = [[[tokenStr
                             stringByReplacingOccurrencesOfString:@"<" withString:@""]
                            stringByReplacingOccurrencesOfString:@">" withString:@""]
                           stringByReplacingOccurrencesOfString:@" " withString:@""];
    return pushToken;
}


+(void) trackPushOpen:(NSDictionary *) userInfo {
    
    if (userInfo) {
        
        UHOperation * operation = [UHOperation new];
        [operation trackPushOpen:userInfo forEnvironment:pushEnvironment];
        
    }
}

+(NSDictionary *) getPushPayload:(NSDictionary * )notificationUserInfo {
    if (notificationUserInfo) {
        return [notificationUserInfo valueForKeyPath:@"data.payload"];
    }
    else {
        return nil;
    }
}

+(BOOL) isPushFromUserHook:(NSDictionary *) notificationUserInfo {
    if (notificationUserInfo) {
        NSString * source = [notificationUserInfo valueForKeyPath:@"data.source"];
        
        return source && [source isEqualToString:@"userhook"];
    }
    
    return NO;
}



@end
