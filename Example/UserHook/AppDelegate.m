/*
 * Copyright (c) 2015 - present, Cullaboration Media, LLC.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import "AppDelegate.h"
#import <UserHook/UserHook.h>


#import "MFSideMenu.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    // set appearance styles
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    [[UINavigationBar appearance] setBarTintColor:[UIColor colorWithRed:60.0/255.0 green:141.0/255.0 blue:188.0/255.0 alpha:1.0]];
    NSDictionary *textTitleOptions = [NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor], NSForegroundColorAttributeName, nil];
    [[UINavigationBar appearance] setTitleTextAttributes:textTitleOptions];
    
    
    // setup view controllers
    UIStoryboard *storyboard =[UIStoryboard storyboardWithName:[[NSBundle mainBundle].infoDictionary objectForKey:@"UIMainStoryboardFile"] bundle:[NSBundle mainBundle]];
    
    MFSideMenuContainerViewController * container = (MFSideMenuContainerViewController *)self.window.rootViewController;
    
    // load the HomeViewController into the main content area
    UINavigationController * navigationController = [storyboard instantiateViewControllerWithIdentifier:@"nav"];
    navigationController.navigationBar.tintColor = [UIColor whiteColor];
    [container setCenterViewController:navigationController];
    
    // add the left menu
    UIViewController * menu = [storyboard instantiateViewControllerWithIdentifier:@"menu"];
    [container setLeftMenuViewController:menu];
    
    
    
    // setup UserHook
    
    /*
     This demo project assumes there is a plist file in your project called userhook.plist with an entry for UserHookApplicationId and UserHookApplicationKey.
     You may instead hard code your keys directly or use a different method of securing your keys.
     */
    NSDictionary *dictionary = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"userhook" ofType:@"plist"]];
    NSString * applicationId = [dictionary objectForKey:@"UserHookApplicationId"];
    NSString * applicationKey = [dictionary objectForKey:@"UserHookApplicationKey"];
    
    [UserHook setApplicationId:applicationId apiKey:applicationKey];
    
    [UserHook setPayloadHandler:^(NSDictionary *payload) {
        
        
        // This is code that is run when a payload from a push message or action is received. The payload is the dictionary of values that was created in the User Hook admin page
        // in the paylod section. You can use the payload to enable deep linking within your app.
        
        if (payload) {
            for (NSString * key in [payload allKeys]) {
                
                NSLog(@"action key = %@, value = %@", key, [payload valueForKey:key]);
            }
        }

    }];
    
    // setup push messaging
    [UserHook registerForPush:launchOptions];
    
    // setup feedback settings
    // the title used for the feedback screen (ie. "Feedback","Support", etc)
    [UserHook setFeedbackScreenTitle:@"Feedback"];
    // You can pass additional custom fields to be included when a user submits feedback. This might include a username or user id.
    [UserHook setFeedbackCustomFields:@{@"username":@"john123"}];
    
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.

    // since the app just became active, we will try to load hookpoints
    [self loadHookpoints:@"launch"];

}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark - push notifications
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    
    // register push notification token with User Hook
    [UserHook registerDeviceToken:deviceToken];
    
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    
    // handle incoming push notifications
    if ([UserHook isPushFromUserHook:userInfo]) {
        [UserHook handlePushNotification:userInfo];
    }
    else {
        // push is from a different push provider
        // use the appropriate logic from that push provider
        // to handle push message
    }
    
}

#pragma mark - handle custom urls
-(BOOL) application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<NSString *,id> *)options {
    
    if ([[url scheme] isEqualToString:@"userhookdemo"]) {
        
        NSLog(@"handling custom url: %@", [url absoluteString]);
        
        // deep link to screen inside app
        NSString * host = [url host];
        
        // handle the url userhookdemo://product
        if ([host isEqualToString:@"product"]) {
            
            UIStoryboard *storyboard =[UIStoryboard storyboardWithName:[[NSBundle mainBundle].infoDictionary objectForKey:@"UIMainStoryboardFile"] bundle:[NSBundle mainBundle]];
            
            UIViewController * controller = [storyboard instantiateViewControllerWithIdentifier:@"buyProduct"];
            
            UINavigationController * navController = ((MFSideMenuContainerViewController *)self.window.rootViewController).centerViewController;
            
            [navController pushViewController:controller animated:YES];
            
        }
        
        return YES;
    }
    
    return NO;
}

-(void) loadHookpoints:(NSString *) event {
    
    // check for UserHooks
    [UserHook fetchHookPoint:event handler:^(UHHookPoint *hookpoint) {
        if(hookpoint) {
            [hookpoint execute];
        }
    }];
}

@end
