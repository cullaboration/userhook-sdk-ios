/*
 * Copyright (c) 2015 - present, Cullaboration Media, LLC.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import <StoreKit/StoreKit.h>
#import "UHRater.h"
#import "UserHook.h"

@interface UHRater()

@property (nonatomic, strong) NSTimer * skTimer;

@end

@implementation UHRater


static UHRater * _sharedInstance;

+(UHRater *) sharedInstance {
    
    if (_sharedInstance == nil) {
        _sharedInstance = [[self alloc] init];
    };
    
    return _sharedInstance;
}

-(id) init {
    self = [super init];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(skRatingWindow:) name:UIWindowDidBecomeVisibleNotification object:nil];
    
    return self;
}

-(void) dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void) skRatingWindow:(NSNotification *) notification {
    
    UIWindow * window = notification.object;
    
    if ([[[window class] description] hasPrefix:@"SKStore"]) {
        NSLog(@"rating window open");
        
        // cancel the fallback timer
        [self.skTimer invalidate];
        
        // release current rater instance
        _sharedInstance = nil;
    }
    
    
}

+(void) rateApp {
    
    UHRater * rater = [self sharedInstance];
    
    [rater _rateApp];
}

-(void) _rateApp {
    
    if ([[UserHook sharedInstance] applicationData].itunes_id) {
        
        // check if current ios version supports new StoreKit rating
        if ([SKStoreReviewController class]) {
            [SKStoreReviewController requestReview];
            
            // create a fallback timer
            // give the app 1 second to display the storekit review prompt, otherwise fallback to the iTunes store url
            // iOS by default limits how often the user sees the prompt and users will have the option to turn off all
            // prompts. So this fallback timer addresses this concern.
            self.skTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(openStoreUrl) userInfo:nil repeats:NO];
            
        }
        else {
            // open this app's page in itunes
            [self openStoreUrl];
        }
        
        // mark that this user has "rated" this app
        [UserHook markRated];
        
    }
}

-(void) openStoreUrl {
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"itms-apps://itunes.apple.com/app/id%@", [[UserHook sharedInstance] applicationData].itunes_id]]];
}


@end
