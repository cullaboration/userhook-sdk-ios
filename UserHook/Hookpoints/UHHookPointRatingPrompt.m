/*
 * Copyright (c) 2015 - present, Cullaboration Media, LLC.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import "UHHookPointRatingPrompt.h"
#import "UserHook.h"

@implementation UHHookPointRatingPrompt


+(NSString *) type {
    return @"rating prompt";
}

-(id) initWithData:(NSDictionary *)data {
    self = [super initWithData:data];
    
    
    NSDictionary * hookpoint = [data valueForKey:@"hookpoint"];
    NSDictionary * meta = [hookpoint valueForKey:@"meta"];
    if (meta) {
        
        if ([meta valueForKey:@"negativeButtonLabel"]) {
            _negativeButtonLabel = [meta valueForKey:@"negativeButtonLabel"];
        }
        if ([meta valueForKey:@"positiveButtonLabel"]) {
            _positiveButtonLabel = [meta valueForKey:@"positiveButtonLabel"];
        }
        if ([meta valueForKey:@"promptMessage"]) {
            _promptMessage = [meta valueForKey:@"promptMessage"];
        }
    }
    
    
    return  self;
    
}

-(void) execute {
    
    [UserHook displayRatePrompt:_promptMessage positiveButtonTitle:_positiveButtonLabel negativeButtonTitle:_negativeButtonLabel];
    
    [UserHook trackHookPointDisplay:self];
}

@end
