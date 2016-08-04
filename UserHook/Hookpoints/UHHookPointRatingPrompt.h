/*
 * Copyright (c) 2015 - present, Cullaboration Media, LLC.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import "UHHookPoint.h"

__deprecated_msg("UHHookPointRatingPrompt has been replaced by UHHookPointMessage")
@interface UHHookPointRatingPrompt : UHHookPoint

@property (nonatomic, strong) NSString * negativeButtonLabel;
@property (nonatomic, strong) NSString * positiveButtonLabel;
@property (nonatomic, strong) NSString * promptMessage;

@end
