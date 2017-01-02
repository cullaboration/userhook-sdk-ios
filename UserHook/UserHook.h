/*
 * Copyright (c) 2015 - present, Cullaboration Media, LLC.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import <Foundation/Foundation.h>
#import "UHHookPoint.h"
#import "UHHostedPageViewController.h"
#import "UHUser.h"
#import "UHPage.h"
#import "UHApplication.h"
#import "UHMessageMeta.h"
#import "UHOperation.h"
#import "UHHandlers.h"

#define UH_SDK_VERSION @"1.3.1"
#define UH_API_VERSION @"1"
#define UH_API_URL @"https://api.userhook.com/"
#define UH_HOST_URL @"https://formhost.userhook.com/"
#define UH_PROTOCOL @"uh"

#define UH_NotificationNewFeedback @"UHNewFeedback"


#define UH_DEBUG 0

#define UH_TIME_BETWEEN_SESSIONS_IN_SECONDS 600 // 10 minutes

#if UH_DEBUG
#   define UH_LOG(fmt, ...) NSLog(fmt, ##__VA_ARGS__)
#else
#   define UH_LOG(...)
#endif




@interface UserHook : NSObject

@property (nonatomic, copy, readonly) NSString * applicationId;
@property (nonatomic, copy, readonly) NSString * apiKey;
@property (nonatomic, assign) BOOL hasNewFeedback;
@property (nonatomic, copy) NSString * promptNibName;


@property (nonatomic, copy) NSString * navControllerClassName;
@property (nonatomic, copy) UHPayloadHandler payloadHandler;

+(void) setApplicationId:(NSString *) applicationId apiKey:(NSString *) apiKey;
+(UserHook *) sharedInstance;


// really only useful to help with testing
+(void) setSharedInstance:(UserHook *) instance;

+(void) setPayloadHandler:(UHPayloadHandler) payloadHandler;

// find the view controller that is currently displaying on the screen
+(UIViewController *) topViewController;

#pragma mark - feedback settings
// the title to use for the feedback screen (ie. "Feedback" or "Support")
+(void) setFeedbackScreenTitle:(NSString *) feedbackScreenTitle;
+(NSString *) feedbackScreenTitle;
+(void) setFeedbackCustomFields:(NSDictionary *) feedbackCustomFields;
+(NSDictionary *) feedbackCustomFields;


# pragma mark - session tracking
+(void) updateSessionData:(NSDictionary * )data;
+(void) updateCustomFields:(NSDictionary * )data;
+(void) updateCustomFields:(NSDictionary *)data handler:(UHResponseHandler) handler;

-(void) setApplicationData:(UHApplication *) application;

+(void) markRated;
+(void) updatePurchasedItem:(NSString *)sku forAmount:(NSNumber *)price;
+(void) updatePurchasedItem:(NSString *)sku forAmount:(NSNumber *)pric handler:(UHResponseHandler) handler;

# pragma mark - hook points
+(void) fetchHookPoint:(UHHookPointHandler) handler;
+(void) trackHookPointDisplay:(UHHookPoint *) hookPoint;
+(void) trackHookPointInteraction:(UHHookPoint *) hookPoint;

# pragma mark - hosted pages
+(UHHostedPageViewController *) createHostedPageViewController:(NSString *) pagePath;
+(UHHostedPageViewController *) createFeedbackViewController;
+(void) fetchPageNames:(UHArrayHandler) handler;

#pragma mark - push messaging
+(void) registerDeviceToken:(NSData *) deviceToken;
+(void) registerDeviceTokenString:(NSString *) tokenString;
+(void) registerForPush:(NSDictionary *) launchOptions;
+(void) handlePushNotification:(NSDictionary *) userInfo;
+(BOOL) isPushFromUserHook:(NSDictionary *) notificationUserInfo;

#pragma mark - actions
+(void) rateThisApp;
+(void) displayRatePrompt:(NSString *) message positiveButtonTitle:(NSString *) positiveTitle negativeButtonTitle:(NSString *) negativeTitle;
+(void) displaySurvey:(NSString *) surveyId title:(NSString *) surveyTitle hookpointId:(NSString *) hookpointId;
+(void) displayFeedback;
+(void) displayFeedbackPrompt:(NSString *)message positiveButtonTitle:(NSString *) positiveTitle negativeButtonTitle:(NSString *) negativeTitle;
+(void) handlePayload:(NSDictionary *) payload;
+(void) displayPrompt:(NSString *) message button1:(UHMessageMetaButton *) button1 button2:(UHMessageMetaButton *) button2;
+(void) displayStaticPage:(NSString *)slug title:(NSString *)title;
@end
