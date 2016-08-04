/*
 * Copyright (c) 2015 - present, Cullaboration Media, LLC.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import "UHHookPointSurvey.h"
#import "UserHook.h"


@implementation UHHookPointSurvey

+(NSString *) type {
    return @"survey";
}

-(id) initWithData:(NSDictionary *)data {
    self = [super initWithData:data];
    
    
    if ([data valueForKeyPath:@"hookpoint.meta.survey"]) {
        _surveyId = [data valueForKeyPath:@"hookpoint.meta.survey"];
    }
    
    if ([data valueForKeyPath:@"hookpoint.meta.publicTitle"]) {
        _publicTitle = [data valueForKeyPath:@"hookpoint.meta.publicTitle"];
    }
    
    return  self;
    
}



-(void) execute {
    
    if (_surveyId) {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [UserHook displaySurvey:_surveyId title:_publicTitle hookpointId:self.id];
        
        
    });
    
    
    [UserHook trackHookPointDisplay:self];
        
    }
}


@end
