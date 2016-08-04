/*
 * Copyright (c) 2015 - present, Cullaboration Media, LLC.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import "UHHookPointAction.h"
#import "UserHook.h"

@implementation UHHookPointAction

+(NSString *) type {
    return @"action";
}


-(id) initWithData:(NSDictionary *)data {
    self = [super initWithData:data];
    
    
    NSDictionary * hookpoint = [data valueForKey:@"hookpoint"];
    NSDictionary * meta = [hookpoint valueForKey:@"meta"];
    if (meta) {
        
        
        if ([meta valueForKey:@"payload"]) {
            NSString * payloadString = [meta valueForKey:@"payload"];
            NSData * payloadData = [payloadString dataUsingEncoding:NSUTF8StringEncoding];
            NSError * error;
            _payload = [NSJSONSerialization JSONObjectWithData:payloadData options:0 error:&error];
            
            if (error) {
                UH_LOG(@"error parsing payload: %@", [error localizedDescription]);
            }
        }
    }
    
    
    return  self;
    
}

-(void) execute {
    
    [UserHook handlePayload:self.payload];
    
    [UserHook trackHookPointInteraction:self];
    
}

@end
