/*
 * Copyright (c) 2015 - present, Cullaboration Media, LLC.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import <JSONModel/JSONModel.h>
#import "UHApplication.h"
#import "UHFeed.h"

@class UHSessionData;

@interface UHSessionFeed : UHFeed

@property (nonatomic, strong) UHSessionData * data;

@end

@interface UHSessionData : JSONModel

@property (nonatomic, strong) NSString * user;
@property (nonatomic, strong) NSString * key;
@property (nonatomic, assign) BOOL new_feedback;
@property (nonatomic, strong) UHApplication * application;

@end

