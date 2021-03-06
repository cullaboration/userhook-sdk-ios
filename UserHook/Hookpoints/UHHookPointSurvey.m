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


-(id) initWithModel:(UHHookPointModel *)model {
    self = [super initWithModel:model];
    
    
    if (model.meta && [model.meta valueForKeyPath:@"survey"]) {
        _surveyId = [model.meta valueForKeyPath:@"survey"];
    }
    
    if (model.meta && [model.meta valueForKeyPath:@"publicTitle"]) {
        _publicTitle = [model.meta valueForKeyPath:@"publicTitle"];
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
