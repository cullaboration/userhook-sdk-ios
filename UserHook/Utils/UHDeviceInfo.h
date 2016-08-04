/*
 * Copyright (c) 2015 - present, Cullaboration Media, LLC.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import <Foundation/Foundation.h>

@interface UHDeviceInfo : NSObject

+(NSString *) osVersion;
+(NSString *) device;
+(NSString *) locale;
+(NSString *) appVersion;
+(float) timezoneOffset;

@end
