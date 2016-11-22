/*
 * Copyright (c) 2015 - present, Cullaboration Media, LLC.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import "UHDeviceInfo.h"
#import <UIKit/UIKit.h>

@implementation UHDeviceInfo

+(NSString *) osVersion {
    return [[UIDevice currentDevice] systemVersion];
}

+(NSString *) device {
    
    return [[UIDevice currentDevice] model];
}

+(NSString *) locale {
    return [[NSLocale currentLocale] localeIdentifier];
}

+(NSString *) appVersion {
    NSString *result = [[NSBundle bundleForClass:[self class]] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    if ([result length] == 0)
        result = [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString*)kCFBundleVersionKey];
    
    return result;
}

+(float) timezoneOffset {
    return [[NSTimeZone systemTimeZone] secondsFromGMT];
}

@end
