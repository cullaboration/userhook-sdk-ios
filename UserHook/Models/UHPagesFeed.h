/*
 * Copyright (c) 2015 - present, Cullaboration Media, LLC.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import "UHFeed.h"
#import "UHPage.h"

@interface UHPagesFeed : UHFeed

@property (nonatomic, strong) NSArray<UHPage> * data;

@end
