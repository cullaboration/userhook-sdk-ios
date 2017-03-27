/*
 * Copyright (c) 2015 - present, Cullaboration Media, LLC.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import "UHHookPointFeed.h"
#import <JSONModel/JSONModel.h>

@implementation UHHookPointFeed


+(JSONKeyMapper*)keyMapper {
    return [[JSONKeyMapper alloc] initWithDictionary:@{
                                                       @"data.hookpoint": @"hookpoint"
                                                       }];
}


@end
