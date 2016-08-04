/*
 * Copyright (c) 2015 - present, Cullaboration Media, LLC.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import "UHFeed.h"

@class UHPushData;

@interface UHPushFeed : UHFeed

@property (nonatomic, strong) UHPushData * data;

@end

@interface UHPushData : JSONModel

@property (nonatomic, assign) BOOL registered;
@property (nonatomic, assign) BOOL tracked;

@end
           
           
