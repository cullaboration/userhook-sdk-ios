/*
 * Copyright (c) 2015 - present, Cullaboration Media, LLC.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import <Foundation/Foundation.h>
#import <JSONModel/JSONModel.h>

@interface UHApplication : JSONModel

@property (nonatomic, strong) NSString * name;
@property (nonatomic, strong) NSString * itunes_id;

@end
