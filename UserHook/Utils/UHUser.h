/*
 * Copyright (c) 2015 - present, Cullaboration Media, LLC.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import <Foundation/Foundation.h>

@interface UHUser : NSObject

+(NSString *) userId;
+(void) setUserId:(NSString *) userId;

+(NSString *) key;
+(void) setKey:(NSString *) key;

+(void) clearUser;

@end
