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

-(id) initWithModel:(UHHookPointModel *)model {
    self = [super initWithModel:model];
    
    
    if (model.meta && [model.meta valueForKey:@"payload"]) {
        NSString * payloadString = [model.meta valueForKey:@"payload"];
        NSData * payloadData = [payloadString dataUsingEncoding:NSUTF8StringEncoding];
        NSError * error;
        _payload = [NSJSONSerialization JSONObjectWithData:payloadData options:0 error:&error];
        
        if (error) {
            UH_LOG(@"error parsing payload: %@", [error localizedDescription]);
        }
    }
    
    
    return  self;
    
}

-(void) execute {
    
    [UserHook handlePayload:self.payload];
    
    [UserHook trackHookPointInteraction:self];
    
}

@end
