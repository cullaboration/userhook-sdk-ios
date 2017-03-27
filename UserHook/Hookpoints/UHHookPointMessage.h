/*
 * Copyright (c) 2015 - present, Cullaboration Media, LLC.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import "UHHookPoint.h"
#import "UHMessageMeta.h"

@interface UHHookPointMessage : UHHookPoint


@property (nonatomic, strong) UHMessageMeta * meta;

-(void) addAndShowView;

@end
