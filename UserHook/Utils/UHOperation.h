/*
 * Copyright (c) 2015 - present, Cullaboration Media, LLC.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import <Foundation/Foundation.h>

#import "UHHookPoint.h"
#import "UHHandlers.h"



@interface UHOperation : NSObject


-(void) createSession;
-(void) updateSessionData:(NSDictionary *) params;
-(void) updateSessionData:(NSDictionary *) params handler:(UHResponseHandler) handler;

-(void) fetchHookpoint:(UHHookPointHandler) handler;
-(void) trackHookpointDisplay:(UHHookPoint *) hookPoint;
-(void) trackHookpointInteraction:(UHHookPoint *) hookPoint;

-(void) fetchPageNames:(UHArrayHandler)handler;

-(void) registerDeviceToken:(NSString * )deviceToken forEnvironment:(NSString *)environment retryCount:(int)retryCount;
-(void) trackPushOpen:(NSDictionary * )params forEnvironment:(NSString *)environment;

-(void) fetchMessageTemplates;
@end
