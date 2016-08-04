/*
 * Copyright (c) 2015 - present, Cullaboration Media, LLC.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import <Foundation/Foundation.h>
#import "UserHook.h"

@interface UHMessageTemplate : NSObject

+(UHMessageTemplate *) sharedInstance;

-(void) addToCache:(NSString *) key value:(NSString *) value;

-(BOOL) hasTemplate:(NSString *) name;

-(NSString *) renderTemplate:(UHMessageMeta *) meta;

@end
