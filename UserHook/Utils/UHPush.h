/*
 * Copyright (c) 2015 - present, Cullaboration Media, LLC.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import <Foundation/Foundation.h>

@interface UHPush : NSObject

+(void) registerDeviceToken:(NSData *)deviceToken;
+(void) registerDeviceTokenString:(NSString *)tokenString;

+(void) trackPushOpen:(NSDictionary *) launchOptions;

+(NSDictionary *) getPushPayload:(NSDictionary * )notificationUserInfo;

+(BOOL) isPushFromUserHook:(NSDictionary *) notificationUserInfo;

@end
