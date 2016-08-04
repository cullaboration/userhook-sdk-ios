/*
 * Copyright (c) 2015 - present, Cullaboration Media, LLC.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import "UHHookPoint.h"
#import "UHHookPointRatingPrompt.h"
#import "UHHookPointMessage.h"
#import "UHHookPointSurvey.h"
#import "UHHookPointAction.h"
#import "UHHookPointActionPrompt.h"

@implementation UHHookPoint


+(id) createWithData:(NSDictionary *)data {
    
    UHHookPoint * object;
    
    
    if ([data valueForKey:@"hookpoint"]) {
        
        
        NSDictionary * hookpoint = [data valueForKey:@"hookpoint"];
        NSString * type = [hookpoint valueForKey:@"type"];
        
        if ([type isEqualToString:[UHHookPointRatingPrompt type]]) {
            object = [[UHHookPointRatingPrompt alloc] initWithData:data];
        }
        else if ([type isEqualToString:[UHHookPointMessage type]]) {
            object = [[UHHookPointMessage alloc] initWithData:data];
        }
        else if ([type isEqualToString:[UHHookPointAction type]]) {
            object = [[UHHookPointAction alloc] initWithData:data];
        }
        
        else if ([type isEqualToString:[UHHookPointActionPrompt type]]) {
            object = [[UHHookPointActionPrompt alloc] initWithData:data];
        }
        else if ([type isEqualToString:[UHHookPointSurvey type]]) {
            object = [[UHHookPointSurvey alloc] initWithData:data];
        }
        else  {
            object = [[UHHookPoint alloc] initWithData:data];
        }
        
    }
    
    return object;
    
}

+(NSString *) type {
    return @"hookpoint";
}

-(void) execute {
    // override in subclass
}

-(id) initWithData:(NSDictionary *)data {
    self = [super init];
    
    NSDictionary * hookpoint = [data valueForKey:@"hookpoint"];
    
    _id = [hookpoint valueForKey:@"id"];
    _name = [hookpoint valueForKey:@"name"];
    _type = [hookpoint valueForKey:@"type"];
    
    
    if ([data valueForKey:@"application"]) {
        NSDictionary * application = [data valueForKey:@"application"];
        
            _applicationName = [application valueForKey:@"name"];
            _itunesId = [application valueForKey:@"itunes_id"];
        
    }
    
    
    
    return self;
}

@end
