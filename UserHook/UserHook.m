/*
 * Copyright (c) 2015 - present, Cullaboration Media, LLC.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import <UIKit/UIKit.h>
#import "UserHook.h"
#import "UHOperation.h"
#import "UHRequest.h"
#import "UHPush.h"
#import "UHApplication.h"
#import "UHMessageView.h"
#import "UHMessageMeta.h"
#import "UHNavigationController.h"

@interface UserHook()

@property (nonatomic, assign) BOOL sessionStarted;
@property (nonatomic, assign) double sessionStartTime;
@property (nonatomic, assign) double backgroundTime;
@property (nonatomic, strong) UHApplication * application;
@property (nonatomic, strong) NSString * feedbackScreenTitle;
@property (nonatomic, strong) NSDictionary * feedbackCustomFields;

@end

@implementation UserHook

static UserHook * _sharedInstance;

@synthesize hasNewFeedback;

-(id) initWithApplicationId:(NSString *) applicationId apiKey:(NSString *)apiKey {
    if (self = [super init]) {
        _applicationId = [applicationId copy];
        _apiKey = [apiKey copy];
        _sessionStarted = NO;
        _sessionStartTime = CFAbsoluteTimeGetCurrent();
        _backgroundTime = CFAbsoluteTimeGetCurrent();
        
        _promptNibName = @"UHPromptView";
        
        UH_LOG(@"UserHook initialized");
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willTerminate:) name:UIApplicationWillTerminateNotification object:nil];
    }
    
    return self;
}

+(void) setApplicationId:(NSString *)applicationId apiKey:(NSString *)apiKey {
    if (_sharedInstance == nil) {
        _sharedInstance = [[UserHook alloc] initWithApplicationId:applicationId apiKey:apiKey];
        
        [UserHook createSession];
    }
}

-(void) setApplicationData:(UHApplication *) application {
    self.application = application;
}

+(UserHook *) sharedInstance {
    if (_sharedInstance == nil || (_sharedInstance.applicationId == nil || _sharedInstance.apiKey == nil)) {
        UH_LOG(@"Application Id and API Key have not been properly set.");
        _sharedInstance = [[UserHook alloc] init];
    }
    
    return  _sharedInstance;
}

// really only useful to help with testing
+(void) setSharedInstance:(UserHook *) instance {
    _sharedInstance = instance;
}

-(void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

+(void) setPayloadHandler:(UHPayloadHandler)payloadHandler {
    [UserHook sharedInstance].payloadHandler = payloadHandler;
}

+(UIViewController *) topViewController {
    
    UIViewController * rootController = [UIApplication sharedApplication].keyWindow.rootViewController;
    while (rootController.presentedViewController) rootController = rootController.presentedViewController;
    
    return rootController;
}

#pragma mark - feedback settings
+(void) setFeedbackScreenTitle:(NSString *)feedbackScreenTitle {
    
    [UserHook sharedInstance].feedbackScreenTitle = feedbackScreenTitle;
}

+(NSString *) feedbackScreenTitle {
    if ([UserHook sharedInstance].feedbackScreenTitle) {
        return [UserHook sharedInstance].feedbackScreenTitle;
    }
    else {
        return @"Feedback";
    }
}

+(void) setFeedbackCustomFields:(NSDictionary *)feedbackCustomFields {
    [UserHook sharedInstance].feedbackCustomFields = feedbackCustomFields;
}

+(NSDictionary *) feedbackCustomFields {
    if ([UserHook sharedInstance].feedbackCustomFields) {
        return [UserHook sharedInstance].feedbackCustomFields;
    }
    else {
        return nil;
    }
}


+(void) createSession {
    
    UH_LOG(@"creating user session");
    UHOperation * op = [[UHOperation alloc] init];
    [op createSession];
}

+(void) updateSessionData:(NSDictionary * )data {
    
    UH_LOG(@"updating user session");
    UHOperation * op = [[UHOperation alloc] init];
    [op updateSessionData:data];
}

+(void) updateCustomFields:(NSDictionary * )data {
    [self updateCustomFields:data handler:nil];
}

+(void) updateCustomFields:(NSDictionary * )data handler:(UHResponseHandler)handler {
    UH_LOG(@"updating custom fields");
    
    UHOperation * op = [[UHOperation alloc] init];
    
    NSMutableDictionary * customFieldData = [NSMutableDictionary dictionary];
    for (NSString * key in [data allKeys]) {
        [customFieldData setObject:data[key] forKey:[NSString stringWithFormat:@"custom_fields.%@",key]];
    }
    
    [op updateSessionData:customFieldData handler:handler];
}

+(void) markRated {
    
    UH_LOG(@"user rated app");
    UHOperation * op = [[UHOperation alloc] init];
    NSDictionary * data = [NSDictionary dictionaryWithObjectsAndKeys:@"true",@"rated", nil];
    [op updateSessionData:data];
}

+(void) updatePurchasedItem:(NSString *)sku forAmount:(NSNumber *)price {
    [self updatePurchasedItem:sku forAmount:price handler:nil];
}

+(void) updatePurchasedItem:(NSString *)sku forAmount:(NSNumber *)price handler:(UHResponseHandler)handler {
    
    UH_LOG(@"user purchased item");
    UHOperation * op = [[UHOperation alloc] init];
    NSDictionary * data = [NSDictionary dictionaryWithObjectsAndKeys:sku,@"purchases",price,@"purchases_amount", nil];
    [op updateSessionData:data handler:handler];
}

+(void) fetchHookPoint:(UHHookPointHandler)handler {
    UH_LOG(@"loading hookpoint");
    UHOperation * op = [[UHOperation alloc] init];
    [op fetchHookpoint:handler];
}

+(void) trackHookPointDisplay:(UHHookPoint *) hookPoint {
    UH_LOG(@"tracking hookpoint display");
    UHOperation * op = [[UHOperation alloc] init];
    [op trackHookpointDisplay:hookPoint];
}

+(void) trackHookPointInteraction:(UHHookPoint *) hookPoint {
    UH_LOG(@"tracking hookpoint interaction");
    UHOperation * op = [[UHOperation alloc] init];
    [op trackHookpointInteraction:hookPoint];
}

# pragma mark - session methods

- (void)didEnterBackground:(NSNotification *)notification
{
    double sessionLength = CFAbsoluteTimeGetCurrent() - _sessionStartTime;
    
    // send session length info to server
    if (sessionLength > 0) {
        UHOperation * op = [[UHOperation alloc] init];
        NSDictionary * params = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%f", floor(sessionLength)], @"session_time", nil];
        [op updateSessionData:params];
    }
    
    _backgroundTime = CFAbsoluteTimeGetCurrent();
    
    UH_LOG(@"App didEnterBackground");
}

- (void)willEnterForeground:(NSNotification *)notification
{
    // reset session start time
    _sessionStartTime = CFAbsoluteTimeGetCurrent();
    
    UH_LOG(@"App willEnterForeground");
    
    if (CFAbsoluteTimeGetCurrent() - _backgroundTime > UH_TIME_BETWEEN_SESSIONS_IN_SECONDS) {
        // mark this as a new session
        [UserHook createSession];
    }
}

- (void)willTerminate:(NSNotification *)notification
{
    
    double sessionLength = CFAbsoluteTimeGetCurrent() - _sessionStartTime;
    
    // send session length info to server
    if (sessionLength > 0) {
        UHOperation * op = [[UHOperation alloc] init];
        NSDictionary * params = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%f", floor(sessionLength)], @"session_time", nil];
        [op updateSessionData:params];
    }
    
    UH_LOG(@"App willTerminate");
}

# pragma mark - hosted pages

+(UHHostedPageViewController *) createHostedPageViewController:(NSString *) pagePath {
    UHHostedPageViewController * controller = [[UHHostedPageViewController alloc] initWithPageName:pagePath];
    return controller;
}

+(void) fetchPageNames:(UHArrayHandler) handler {
    
    UHOperation * op = [[UHOperation alloc] init];
    [op fetchPageNames:handler];
    
}

#pragma mark - feedback

+(UHHostedPageViewController *) createFeedbackViewController {
    NSMutableString * url = [NSMutableString stringWithFormat:@"%@feedback/", UH_HOST_URL];
    
    NSDictionary * customFields = [UserHook feedbackCustomFields];
    
    // add custom fields to query string
    if (customFields) {
        
        int i=0;
        NSMutableDictionary * convertedKeys = [NSMutableDictionary dictionary];
        for (NSString * key in [customFields allKeys]) {
            [convertedKeys setValue:key forKey:[NSString stringWithFormat:@"custom_fields[%i][name]", i]];
            [convertedKeys setValue:[customFields valueForKey:key] forKey:[NSString stringWithFormat:@"custom_fields[%i][value]", i]];
            i++;
        }
        
        NSString * queryString = [UHRequest parametersToQueryString:convertedKeys];
        [url appendFormat:@"?%@", queryString];
    }
    
    UHHostedPageViewController * controller = [[UHHostedPageViewController alloc] initWithPageUrl:url];
    return controller;
}

+(void) registerDeviceToken:(NSData *) deviceToken {
    [UHPush registerDeviceToken:deviceToken];
}

+(void) registerDeviceTokenString:(NSString *) tokenString {
    [UHPush registerDeviceTokenString:tokenString];
}


+(void) registerForPush:(NSDictionary *) launchOptions {
    
    UIApplication * application = [UIApplication sharedApplication];
    
    // Register for Push Notitications
    UIUserNotificationType userNotificationTypes = (UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound);
    UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:userNotificationTypes  categories:nil];
    if ([application respondsToSelector:@selector(registerUserNotificationSettings:)]) {
        [application registerUserNotificationSettings:settings];
        [application registerForRemoteNotifications];
    }
    
    
    if (launchOptions && [launchOptions valueForKey:UIApplicationLaunchOptionsRemoteNotificationKey]) {
        
        NSDictionary * userInfo = [launchOptions valueForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
        
        if ([UserHook isPushFromUserHook:userInfo]) {
            [UserHook handlePushNotification:userInfo];
        }
    }
    
    
}

+(BOOL) isPushFromUserHook:(NSDictionary *) notificationUserInfo {
    return [UHPush isPushFromUserHook:notificationUserInfo];
}

+(void) handlePushNotification:(NSDictionary *)userInfo {
    
    
    // The application was just brought from the background to the foreground,
    // so we consider the app as having been "opened by a push notification."
    if ([UIApplication sharedApplication].applicationState != UIApplicationStateActive) {
        [UHPush trackPushOpen:userInfo];
    }
    
    
    NSDictionary * payload = [UHPush getPushPayload:userInfo];
    
    // if this push message is for a feedback reply, tell the app there is new feedback
    if ([payload valueForKey:@"new_feedback"]) {
        [UserHook sharedInstance].hasNewFeedback = [[payload valueForKey:@"new_feedback"] boolValue];
        if ([UserHook sharedInstance].hasNewFeedback) {
            [[NSNotificationCenter defaultCenter] postNotificationName:UH_NotificationNewFeedback object:nil];
        }
    }
    
    // custom push handler
    if (_sharedInstance.payloadHandler) {
        _sharedInstance.payloadHandler(payload);
    }
    
    
    
}

#pragma mark - actions
+(void) rateThisApp {
    
    if ([UserHook sharedInstance].application.itunes_id) {
        
        // open this app's page in itunes
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"itms-apps://itunes.apple.com/app/id%@", _sharedInstance.application.itunes_id]]];
        
        // mark that this user has "rated" this app
        [UserHook markRated];
        
    }
}


+(void) displayRatePrompt:(NSString *) message positiveButtonTitle:(NSString *) positiveTitle negativeButtonTitle:(NSString *) negativeTitle {
    
    
    
    UHMessageMetaButton * button1 = [[UHMessageMetaButton alloc] init];
    button1.title = positiveTitle;
    button1.click = UHMessageClickRate;
    
    UHMessageMetaButton * button2 = [[UHMessageMetaButton alloc] init];
    button2.title = negativeTitle;
    button2.click = UHMessageClickClose;
    
    [self displayPrompt:message button1:button1 button2:button2];
    
    
}

+(void) displayFeedbackPrompt:(NSString *)message positiveButtonTitle:(NSString *) positiveTitle negativeButtonTitle:(NSString *) negativeTitle {
    
    
    UHMessageMetaButton * button1 = [[UHMessageMetaButton alloc] init];
    button1.title = positiveTitle;
    button1.click = UHMessageClickFeedback;
    
    UHMessageMetaButton * button2 = [[UHMessageMetaButton alloc] init];
    button2.title = negativeTitle;
    button2.click = UHMessageClickClose;
    
    [self displayPrompt:message button1:button1 button2:button2];
    
    
}

+(void) displaySurvey:(NSString *)surveyId title:(NSString *)surveyTitle hookpointId:(NSString *)hookpointId {
    
    UHHostedPageViewController * controller = [[UHHostedPageViewController alloc ] initWithPageUrl:[NSString stringWithFormat:@"%@survey/%@?hp=%@", UH_HOST_URL, surveyId, hookpointId]];
    
    controller.title = surveyTitle;
    
    
    [self displayUHController:controller];
}

+(void) displayFeedback {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        UHHostedPageViewController * controller = [UserHook createFeedbackViewController];
        controller.title = [UserHook feedbackScreenTitle];
        
        [self displayUHController:controller];
        
    });
    
}

+(void) displayUHController:(UHHostedPageViewController *) controller {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        // allow the navigation controller to be overridden
        Class navClass;
        if ([UserHook sharedInstance].navControllerClassName) {
            navClass = NSClassFromString([UserHook sharedInstance].navControllerClassName);
        }
        else {
            navClass = [UHNavigationController class];
        }
        
        UINavigationController * navController = [[navClass alloc] initWithRootViewController:controller];
        UIViewController * rootController = [UserHook topViewController];
        [rootController presentViewController:navController animated:YES completion:nil];
        
    });
}


+(void) displayPrompt:(NSString *) message button1:(UHMessageMetaButton *) button1 button2:(UHMessageMetaButton *) button2 {
    
    UHMessageMeta * meta = [[UHMessageMeta alloc] init];
    meta.body = message;
    
    if (button1 && button2) {
        meta.displayType = UHMessageTypeTwoButtons;
    }
    else if (button1) {
        meta.displayType = UHMessageTypeOneButton;
    }
    else {
        meta.displayType = UHMessageTypeNoButtons;
    }
    
    meta.button1 = button1;
    meta.button2 = button2;
    
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        
        UHMessageView * view = [UHMessageView createViewForMeta:meta];
        
        if ([UHMessageView canDisplay]) {
            UIViewController * rootController = [UserHook topViewController];
            view.frame = rootController.view.frame;
            [rootController.view addSubview:view];
            
            [view showDialog];
        }
        
    });
    
    
}

+(void) handlePayload:(NSDictionary *) payload {
    
    if ([UserHook sharedInstance].payloadHandler) {
        [UserHook sharedInstance].payloadHandler(payload);
    }
}

+(void) displayStaticPage:(NSString *)slug title:(NSString *)title {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        UHHostedPageViewController * controller = [self createHostedPageViewController:slug];
        controller.title = title;
        
        [self displayUHController:controller];
        
    });
    
    
}

@end
