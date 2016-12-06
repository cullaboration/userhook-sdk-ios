/*
 * Copyright (c) 2015 - present, Cullaboration Media, LLC.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import "UHHookPointMessage.h"
#import "UHMessageView.h"
#import "UserHook.h"

@interface UHHookPointMessage()



@end

@implementation UHHookPointMessage

+(NSString *) type {
    return @"message";
}

-(id) initWithData:(NSDictionary *)data {
    self = [super initWithData:data];
    
    
    NSDictionary * hookpoint = [data valueForKey:@"hookpoint"];
    
    NSError * error;
    self.meta = [[UHMessageMeta alloc] initWithDictionary:[hookpoint valueForKey:@"meta"] error:&error];
    if (error) {
        UH_LOG(@"error parsing message meta: %@", [error localizedDescription]);
    }
    
    return  self;
    
}

-(void) execute {
    
    if ([UHMessageView canDisplay]) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            UHMessageView * messageView = [UHMessageView createViewForHookPoint:self];
            UIViewController * rootController = [UserHook topViewController];
            messageView.frame = rootController.view.frame;
            [rootController.view addSubview:messageView];
            
            
            [messageView showDialog];
            
        });
    }
    
}


@end
