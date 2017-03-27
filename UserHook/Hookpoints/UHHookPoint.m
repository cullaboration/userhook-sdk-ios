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
#import "UHHookPointNPS.h"

@implementation UHHookPoint

NSString * const UHHookPointTypeMessage = @"message";
NSString * const UHHookPointTypeAction = @"action";
NSString * const UHHookPointTypeSurvey = @"survey";
NSString * const UHHookPointTypeNPS = @"nps";


NSString * const UHHookPointTypeActionPrompt = @"action prompt";
NSString * const UHHookPointTypeRatingPrompt = @"rating prompt";

+(id) createWithModel:(UHHookPointModel *)model {
    
    UHHookPoint * object;
    
        if ([model.type isEqualToString:UHHookPointTypeMessage]) {
            object = [[UHHookPointMessage alloc] initWithModel:model];
        }
        else if ([model.type isEqualToString:UHHookPointTypeNPS]) {
            object = [[UHHookPointNPS alloc] initWithModel:model];
        }
        else if ([model.type isEqualToString:UHHookPointTypeAction]) {
            object = [[UHHookPointAction alloc] initWithModel:model];
        }
        
        else if ([model.type isEqualToString:UHHookPointTypeSurvey]) {
            object = [[UHHookPointSurvey alloc] initWithModel:model];
        }
    
        // backporting for version 1.0
        else if ([model.type isEqualToString:UHHookPointTypeRatingPrompt]) {
            
            UHMessageMeta * uhmeta = [[UHMessageMeta alloc] init];
            uhmeta.displayType = UHMessageTypeTwoButtons;
            
            UHMessageMetaButton * button1 = [[UHMessageMetaButton alloc] init];
            UHMessageMetaButton * button2 = [[UHMessageMetaButton alloc] init];
            
            button1.click = UHMessageClickRate;
            button2.click = UHMessageClickClose;
            
            if (model.meta) {
                
                if ([model.meta valueForKey:@"negativeButtonLabel"]) {
                    button2.title = [model.meta valueForKey:@"negativeButtonLabel"];
                }
                if ([model.meta valueForKey:@"positiveButtonLabel"]) {
                    button1.title = [model.meta valueForKey:@"positiveButtonLabel"];
                }
                if ([model.meta valueForKey:@"promptMessage"]) {
                    uhmeta.body = [model.meta valueForKey:@"promptMessage"];
                }
            }
            
            uhmeta.button1 = button1;
            uhmeta.button2 = button2;
            
            object = [[UHHookPointMessage alloc] initWithModel:model];
            ((UHHookPointMessage *)object).meta = uhmeta;
        }
        // backporting for version 1.0
        else if ([model.type isEqualToString:UHHookPointTypeActionPrompt]) {
            
            UHMessageMeta * uhmeta = [[UHMessageMeta alloc] init];
            uhmeta.displayType = UHMessageTypeTwoButtons;
            
            UHMessageMetaButton * button1 = [[UHMessageMetaButton alloc] init];
            UHMessageMetaButton * button2 = [[UHMessageMetaButton alloc] init];
            
            button1.click = UHMessageClickAction;
            button2.click = UHMessageClickClose;
            
            if (model.meta) {
                
                if ([model.meta valueForKey:@"negativeButtonLabel"]) {
                    button2.title = [model.meta valueForKey:@"negativeButtonLabel"];
                }
                if ([model.meta valueForKey:@"positiveButtonLabel"]) {
                    button1.title = [model.meta valueForKey:@"positiveButtonLabel"];
                }
                if ([model.meta valueForKey:@"promptMessage"]) {
                    uhmeta.body = [model.meta valueForKey:@"promptMessage"];
                }
                if ([model.meta valueForKey:@"payload"]) {
                    button1.payload = [model.meta valueForKey:@"payload"];
                }
            }
            
            
            uhmeta.button1 = button1;
            uhmeta.button2 = button2;
            
            object = [[UHHookPointMessage alloc] initWithModel:model];
            ((UHHookPointMessage *)object).meta = uhmeta;
            
        }
        else  {
            object = [[UHHookPoint alloc] initWithModel:model];
        }
        
    
    
    return object;
    
}


-(void) execute {
    // override in subclass
}

-(id) initWithModel:(UHHookPointModel *) model {
    self = [super init];
    
    _id = model.id;
    _type = model.type;
    
    
    return self;
}

@end
