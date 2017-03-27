/*
 * Copyright (c) 2015 - present, Cullaboration Media, LLC.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import <JSONModel/JSONModel.h>

@protocol UHHookPointModel

@end

@interface UHHookPointModel : JSONModel

@property (nonatomic, strong) NSString * id;
@property (nonatomic, strong) NSString * type;

@property (nonatomic, strong) NSDictionary<Optional> * meta;

@end
