/*
 * Copyright (c) 2015 - present, Cullaboration Media, LLC.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import "UHMessageMeta.h"

@implementation UHMessageMeta

-(NSDictionary *) toQueryParams {
    
    NSMutableDictionary * params = [NSMutableDictionary dictionary];
    
    NSDictionary * dict = [self toDictionary];
    
    for (NSString * key in [dict allKeys]) {
        
        if ([[dict objectForKey:key] isKindOfClass:[NSDictionary class]]) {
            
        }
        else {
            [params setObject:[dict objectForKey:key] forKey:key];
        }
    }
    
    
    
    return params;
}

+(BOOL)propertyIsOptional:(NSString*)propertyName
{
    return YES;
}

@end

@implementation UHMessageMetaButton
+(BOOL)propertyIsOptional:(NSString*)propertyName
{
    return YES;
}

@end


@implementation UHMessageMetaImage

+(BOOL)propertyIsOptional:(NSString*)propertyName
{
    return YES;
}

@end