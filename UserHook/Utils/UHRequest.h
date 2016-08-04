/*
 * Copyright (c) 2015 - present, Cullaboration Media, LLC.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import <Foundation/Foundation.h>


@interface UHRequest : NSMutableURLRequest

+(UHRequest *) requestWithPath:(NSString *)path httpMethod:(NSString *)method parameters:(NSDictionary *)parameters;

+(UHRequest *) getRequestWithPath:(NSString *)path parameters:(NSDictionary *)parameters;
+(UHRequest *) postRequestWithPath:(NSString *)path parameters:(NSDictionary *)parameters;


+(BOOL) hasUserHookHeaders:(NSURLRequest *)request;
+(UHRequest *) requestFromRequest:(NSURLRequest *) request;
+ (NSString *)parametersToQueryString:(NSDictionary *) parameters;

@end
