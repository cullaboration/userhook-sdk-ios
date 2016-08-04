/*
 * Copyright (c) 2015 - present, Cullaboration Media, LLC.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import "UHHookPointActionPrompt.h"
#import "UserHook.h"

@implementation UHHookPointActionPrompt

+(NSString *) type {
    return @"action prompt";
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
    
    
    UHMessageMetaButton * button1 = [[UHMessageMetaButton alloc] init];
    button1.title = _positiveButtonLabel;
    [button1 setClickHandler:^() {
        
        [UserHook handlePayload:self.payload];
        
        [UserHook trackHookPointInteraction:self];
        
    }];
    
    UHMessageMetaButton * button2 = [[UHMessageMetaButton alloc] init];
    button2.title = _negativeButtonLabel;
    button2.click = UHMessageClickClose;
    
    [UserHook displayPrompt:_promptMessage button1:button1 button2:button2];
    
    
    [UserHook trackHookPointDisplay:self];
}


@end
