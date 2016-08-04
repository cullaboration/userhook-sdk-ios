/*
 * Copyright (c) 2015 - present, Cullaboration Media, LLC.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import <Foundation/Foundation.h>

@class UHHookPoint;

typedef void(^UHHookPointHandler)(UHHookPoint * hookpoint);

@interface UHHookPoint : NSObject

@property (nonatomic, strong) NSString * id;
@property (nonatomic, strong) NSString * name;
@property (nonatomic, strong) NSString * type;

@property (nonatomic, strong) NSString * applicationName;
@property (nonatomic, strong) NSString * itunesId;


+(id) createWithData:(NSDictionary *)data;
-(id) initWithData:(NSDictionary *)data;
+(NSString *) type;

-(void) execute;

@end

