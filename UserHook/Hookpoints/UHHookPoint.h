/*
 * Copyright (c) 2015 - present, Cullaboration Media, LLC.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import <Foundation/Foundation.h>
#import "UHHookPointModel.h"

@class UHHookPoint;

extern NSString * const UHHookPointTypeMessage;
extern NSString * const UHHookPointTypeAction;
extern NSString * const UHHookPointTypeSurvey;
extern NSString * const UHHookPointTypeNPS;

// deprecated hook point types
extern NSString * const UHHookPointTypeActionPrompt;
extern NSString * const UHHookPointTypeRatingPrompt;


typedef void(^UHHookPointHandler)(UHHookPoint * hookpoint);

@interface UHHookPoint : NSObject

@property (nonatomic, strong) NSString * id;
@property (nonatomic, strong) NSString * type;


+(id) createWithModel:(UHHookPointModel *) model;

-(id) initWithModel:(UHHookPointModel *)model;


-(void) execute;

@end

