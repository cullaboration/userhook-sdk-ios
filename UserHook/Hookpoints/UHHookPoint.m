/*
 * Copyright (c) 2015 - present, Cullaboration Media, LLC.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import "UHHookPoint.h"
#import "UHHookPointMessage.h"
#import "UHHookPointSurvey.h"
#import "UHHookPointAction.h"

@implementation UHHookPoint


+(id) createWithData:(NSDictionary *)data {
    
    UHHookPoint * object;
    
    
    if ([data valueForKey:@"hookpoint"]) {
        
        
        NSDictionary * hookpoint = [data valueForKey:@"hookpoint"];
        NSString * type = [hookpoint valueForKey:@"type"];
        
        // backporting for version 1.0
        if ([type isEqualToString:@"rating prompt"]) {
            
            UHMessageMeta * uhmeta = [[UHMessageMeta alloc] init];
            uhmeta.displayType = UHMessageTypeTwoButtons;
            
            UHMessageMetaButton * button1 = [[UHMessageMetaButton alloc] init];
            UHMessageMetaButton * button2 = [[UHMessageMetaButton alloc] init];
            
            button1.click = UHMessageClickRate;
            button2.click = UHMessageClickClose;
            
            NSDictionary * hookpoint = [data valueForKey:@"hookpoint"];
            NSDictionary * meta = [hookpoint valueForKey:@"meta"];
            if (meta) {
                
                if ([meta valueForKey:@"negativeButtonLabel"]) {
                    button2.title = [meta valueForKey:@"negativeButtonLabel"];
                }
                if ([meta valueForKey:@"positiveButtonLabel"]) {
                    button1.title = [meta valueForKey:@"positiveButtonLabel"];
                }
                if ([meta valueForKey:@"promptMessage"]) {
                    uhmeta.body = [meta valueForKey:@"promptMessage"];
                }
            }
            
            uhmeta.button1 = button1;
            uhmeta.button2 = button2;
            
            object = [[UHHookPointMessage alloc] initWithData:data];
            ((UHHookPointMessage *)object).meta = uhmeta;
        }
        else if ([type isEqualToString:[UHHookPointMessage type]]) {
            object = [[UHHookPointMessage alloc] initWithData:data];
        }
        else if ([type isEqualToString:[UHHookPointAction type]]) {
            object = [[UHHookPointAction alloc] initWithData:data];
        }
        // backporting for version 1.0
        else if ([type isEqualToString:@"action prompt"]) {
            
            UHMessageMeta * uhmeta = [[UHMessageMeta alloc] init];
            uhmeta.displayType = UHMessageTypeTwoButtons;
            
            UHMessageMetaButton * button1 = [[UHMessageMetaButton alloc] init];
            UHMessageMetaButton * button2 = [[UHMessageMetaButton alloc] init];
            
            button1.click = UHMessageClickAction;
            button2.click = UHMessageClickClose;
            
            NSDictionary * hookpoint = [data valueForKey:@"hookpoint"];
            NSDictionary * meta = [hookpoint valueForKey:@"meta"];
            if (meta) {
                
                if ([meta valueForKey:@"negativeButtonLabel"]) {
                    button2.title = [meta valueForKey:@"negativeButtonLabel"];
                }
                if ([meta valueForKey:@"positiveButtonLabel"]) {
                    button1.title = [meta valueForKey:@"positiveButtonLabel"];
                }
                if ([meta valueForKey:@"promptMessage"]) {
                    uhmeta.body = [meta valueForKey:@"promptMessage"];
                }
                if ([meta valueForKey:@"payload"]) {
                    button1.payload = [meta valueForKey:@"payload"];
                }
            }
            
            
            uhmeta.button1 = button1;
            uhmeta.button2 = button2;
            
            object = [[UHHookPointMessage alloc] initWithData:data];
            ((UHHookPointMessage *)object).meta = uhmeta;
            
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
