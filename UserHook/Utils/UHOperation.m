/*
 * Copyright (c) 2015 - present, Cullaboration Media, LLC.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import "UHOperation.h"
#import "UserHook.h"
#import "UHRequest.h"
#import "UHDeviceInfo.h"
#import "UHUser.h"
#import "UHPage.h"
#import "UHApplication.h"
#import "UHSessionFeed.h"
#import "UHPagesFeed.h"
#import "UHPushFeed.h"
#import "UHTemplatesFeed.h"
#import "UHMessageTemplate.h"

static NSString * const UHPathSession = @"session";
static NSString * const UHPathHookPointFetch = @"hookpoint/next";
static NSString * const UHPathHookPointTrack = @"hookpoint/track";
static NSString * const UHPathPages = @"page";
static NSString * const UHPathRegisterDevice = @"push/register";
static NSString * const UHPathTrackPushOpen = @"push/open";

static NSString * const UHPathMessageTemplates = @"message/templates";

static NSString * const UHHookPointDisplayAction = @"display";
static NSString * const UHHookPointInteractAction = @"interact";

// keep track of current hookpoint fetching status
static BOOL fetchingHookpoints;

@implementation UHOperation

-(void) createSession {
    
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSLocale *enUSPOSIXLocale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
    [dateFormatter setLocale:enUSPOSIXLocale];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZZZZZ"];
    
    NSString * date = [dateFormatter stringFromDate:[NSDate date]];
    
    NSMutableDictionary * parameters = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"1", @"sessions", date, @"last_launch", nil];
    
    
    
    [self updateSessionData:parameters];
    
    // prefetch message templates when a session is created
    [self fetchMessageTemplates];
}

-(void) updateSessionData:(NSDictionary *)params {
    [self updateSessionData:params handler:nil];
}

-(void) updateSessionData:(NSDictionary *) p handler:(UHResponseHandler)handler {
    
    NSMutableDictionary * parameters = [NSMutableDictionary dictionaryWithDictionary:p];
    
    if ([UHUser userId]) {
        [parameters setObject:[UHUser userId] forKey:@"user"];
    }
    
    
    [parameters setObject:@"ios" forKey:@"os"];
    [parameters setObject:UH_SDK_VERSION forKey:@"sdk"];
    [parameters setObject:[UHDeviceInfo osVersion] forKey:@"os_version"];
    [parameters setObject:[UHDeviceInfo device] forKey:@"device"];
    [parameters setObject:[UHDeviceInfo locale] forKey:@"locale"];
    [parameters setObject:[UHDeviceInfo appVersion] forKey:@"app_version"];
    [parameters setObject:[NSNumber numberWithFloat:[UHDeviceInfo timezoneOffset]] forKey:@"timezone_offset"];
    
    
    UHRequest * request = [UHRequest postRequestWithPath:UHPathSession parameters:parameters];
    
    NSURLSessionTask * task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        if (error) {
            UH_LOG(@"error updating session data on server: %@", [error localizedDescription]);
            return;
        }
        else if (!data) {
            UH_LOG(@"server did not return any data");
            return;
        }
        
        [self handleUpdateSession:data handler:handler];
        
        
    }];
    
    [task resume];
    
    
}

-(void) handleUpdateSession:(NSData *) data handler:(UHResponseHandler) handler {
    
    NSError *jsonError;
    UHSessionFeed  * feed = [[UHSessionFeed alloc] initWithData:data error:&jsonError];
    
    if ([feed.status isEqualToString:@"success"]) {
        // save user id
        [UHUser setUserId:feed.data.user];
        
        // save user key
        if (feed.data.key) {
            [UHUser setKey:feed.data.key];
        }
        
        if (feed.data.new_feedback) {
            [UserHook sharedInstance].hasNewFeedback = YES;
            [[NSNotificationCenter defaultCenter] postNotificationName:UH_NotificationNewFeedback object:nil];
        }
        
        // store some basic app information for later usage
        if (feed.data.application) {
            [[UserHook sharedInstance] setApplicationData:feed.data.application];
        }
        
        // pass successful result to handler
        if (handler) {
            handler(YES);
        }
        
    }
    else {
        // pass unsuccessful result to handler
        if (handler) {
            handler(NO);
        }
    }

}

-(void) fetchHookpoint:(UHHookPointHandler) handler {
    
    if (![UHUser userId]) {
        UH_LOG(@"cannot fetch hookpoint, user id is null");
        return;
    }
    
    // only allow one fetch operation at a time
    if (fetchingHookpoints) {
        return;
    }
    
    fetchingHookpoints = YES;
    
    NSDictionary * params = [NSDictionary dictionaryWithObjectsAndKeys:[UHUser userId], @"user", nil];
    
    UHRequest * request = [UHRequest getRequestWithPath:UHPathHookPointFetch parameters:params];
    
    NSURLSessionTask * task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        fetchingHookpoints = NO;
        
        if (error) {
            UH_LOG(@"error loading hookpoint: %@", [error localizedDescription]);
            if (handler) {
                handler(nil);
            }
            return;
        }
        else if (!data) {
            UH_LOG(@"server did not return any data");
            return;
        }
        
        [self handleFetchHookpoint:data handler:handler];
        
    }];
    
    [task resume];
    
    
}

-(void) handleFetchHookpoint:(NSData *) data handler:(UHHookPointHandler) handler {
    
    
    NSError *jsonError;
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data
                                                         options:NSJSONReadingMutableContainers
                                                           error:&jsonError];
    
    
    if ([[json valueForKey:@"status"] isEqualToString:@"success"]) {
        
        NSDictionary * data = [json valueForKey:@"data"];
        UHHookPoint * hookPoint;
        
        if ([data valueForKey:@"hookpoint"] != nil && [data valueForKey:@"hookpoint"] != (id)[NSNull null] && [[data valueForKey:@"hookpoint"] isKindOfClass:[NSDictionary class]]) {
            hookPoint = [UHHookPoint createWithData:[json valueForKey:@"data"]];
            
            if (handler) {
                handler(hookPoint);
            }
             
        }
        
    }
}

-(void) trackHookpointDisplay:(UHHookPoint *)hookPoint {
    [self trackHookpoint:hookPoint action:UHHookPointDisplayAction];
}


-(void) trackHookpointInteraction:(UHHookPoint *)hookPoint {
    [self trackHookpoint:hookPoint action:UHHookPointInteractAction];
}

-(void) trackHookpoint:(UHHookPoint *) hookPoint action:(NSString *)action {
    
    NSDictionary * params = [NSDictionary dictionaryWithObjectsAndKeys:[UHUser userId], @"user", hookPoint.id, @"hookpoint", action,@"action", nil];
    
    UHRequest * request = [UHRequest postRequestWithPath:UHPathHookPointTrack parameters:params];
    
    NSURLSessionTask * task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        if (error) {
            UH_LOG(@"error in operation: %@", [error localizedDescription]);
            return;
        }
        else if (!data) {
            UH_LOG(@"server did not return any data");
            return;
        }
        
        NSError *jsonError;
        UHFeed * feed = [[UHFeed alloc] initWithData:data error:&jsonError];
        
        if ([feed.status isEqualToString:@"success"]) {
            UH_LOG(@"hookpoint tracked %@", action);
        }
        
        
    }];
    
    [task resume];
    
    
    
}

-(void) fetchPageNames:(UHArrayHandler)handler  {
    
    
    UHRequest * request = [UHRequest getRequestWithPath:UHPathPages parameters:nil];
    NSURLSessionTask * task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        if (error) {
            UH_LOG(@"error fetching page names: %@", [error localizedDescription]);
            return;
        }
        else if (!data) {
            UH_LOG(@"server did not return any data");
            return;
        }
        
        [self handleFetchPageNames:data handler:handler];
        
    }];
    
    [task resume];
    
}

-(void) handleFetchPageNames:(NSData *) data handler:(UHArrayHandler) handler {
    
    NSError *jsonError;
    UHPagesFeed * feed = [[UHPagesFeed alloc] initWithData:data error:&jsonError];
    
    
    if ([feed.status isEqualToString:@"success"]) {
        
        UH_LOG(@"page names loaded");
        
        NSMutableArray * items = [NSMutableArray array];
        [items addObjectsFromArray:feed.data];
        
        if (handler) {
            handler(items);
        }
    }

    
}

-(void) fetchMessageTemplates  {
    
    
    UHRequest * request = [UHRequest getRequestWithPath:[NSString stringWithFormat:@"%@%@", UH_HOST_URL, UHPathMessageTemplates] parameters:nil];
    
    NSURLSessionTask * task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        if (error) {
            UH_LOG(@"error fetching message templates: %@", [error localizedDescription]);
            return;
        }
        else if (!data) {
            UH_LOG(@"server did not return any data");
            return;
        }
        
        [self handleFetchMessageTemplates:data];
        
    }];
    
    [task resume];
    
}

-(void) handleFetchMessageTemplates:(NSData *) data {
    
    NSError *jsonError;
    UHTemplatesFeed * feed = [[UHTemplatesFeed alloc] initWithData:data error:&jsonError];
    
    if (feed.templates) {
        
        for (NSString * name in [feed.templates allKeys]) {
            NSString * template = [feed.templates valueForKey:name];
            
            [[UHMessageTemplate sharedInstance] addToCache:name value:template];
        }
        
    }

}

-(void) registerDeviceToken:(NSString * )deviceToken forEnvironment:(NSString *)environment retryCount:(int)retryCount {
    
    NSMutableDictionary * parameters = [NSMutableDictionary dictionary];
    
    if ([UHUser userId]) {
        [parameters setObject:[UHUser userId] forKey:@"user"];
    }
    else {
        // we need a userId to register a token
        UH_LOG(@"no user id, waiting to register push token");
        
        if (retryCount < 2) {
            int nextRetry = retryCount++;
            // wait 5 seconds
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                [self registerDeviceToken:deviceToken forEnvironment:environment retryCount:nextRetry];
                
            });
            
            
        }
        
        return;
    }
    
    
    [parameters setObject:@"ios" forKey:@"os"];
    [parameters setObject:UH_SDK_VERSION forKey:@"sdk"];
    [parameters setObject:deviceToken forKey:@"token"];
    [parameters setObject:environment forKey:@"env"];
    [parameters setObject:[NSNumber numberWithFloat:[UHDeviceInfo timezoneOffset]] forKey:@"timezone_offset"];
    
    
    UHRequest * request = [UHRequest postRequestWithPath:UHPathRegisterDevice parameters:parameters];
    
    
    
    NSURLSessionTask * task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        if (error) {
            UH_LOG(@"error registering push token: %@", [error localizedDescription]);
            return;
        }
        else if (!data) {
            UH_LOG(@"server did not return any data");
            return;
        }
        
        NSError *jsonError;
        UHPushFeed * feed = [[UHPushFeed alloc] initWithData:data error:&jsonError];
        
        if ([feed.status isEqualToString:@"success"] && feed.data.registered) {
            UH_LOG(@"push token registered");
        }
        else {
            UH_LOG(@"push token not registered");
        }
        
    }];
    
    [task resume];
    
}

-(void) trackPushOpen:(NSDictionary * )params forEnvironment:(NSString *)environment {
    
    NSMutableDictionary * parameters = [NSMutableDictionary dictionary];
    
    if ([UHUser userId]) {
        [parameters setObject:[UHUser userId] forKey:@"user"];
    }
    else {
        // we need a userId to register a token
        return;
    }
    
    
    [parameters setObject:@"ios" forKey:@"os"];
    [parameters setObject:UH_SDK_VERSION forKey:@"sdk"];
    [parameters setObject:environment forKey:@"env"];
    
    NSError * err;
    NSData * jsonData = [NSJSONSerialization  dataWithJSONObject:params options:0 error:&err];
    NSString * payloadString = [[NSString alloc] initWithData:jsonData   encoding:NSUTF8StringEncoding];
    
    [parameters setObject:payloadString forKey:@"payload"];
    
    
    UHRequest * request = [UHRequest postRequestWithPath:UHPathTrackPushOpen parameters:parameters];
    
    
    
    NSURLSessionTask * task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        if (error) {
            UH_LOG(@"error tracking push open: %@", [error localizedDescription]);
            return;
        }
        else if (!data) {
            UH_LOG(@"server did not return any data");
            return;
        }
        
        NSError *jsonError;
        UHPushFeed * feed = [[UHPushFeed alloc] initWithData:data error:&jsonError];
        
        
        if ([feed.status isEqualToString:@"success"] && feed.data.tracked) {
            UH_LOG(@"push open tracked");
        }
        else {
            UH_LOG(@"push open not tracked");
        }
        
    }];
    
    [task resume];
    
}



-(void) dealloc {
    
}

@end
