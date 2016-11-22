//
//  UHOperationTest.m
//  UserHook
//
//  Created by Matt Johnston on 10/3/16.
//  Copyright © 2016 mattjohnston. All rights reserved.
//

#import <XCTest/XCTest.h>

#import <UserHook/UserHook.h>
#import <UserHook/UHOperation.h>
#import <UserHook/UHDeviceInfo.h>
#import <UserHook/UHHookPointSurvey.h>
#import <UserHook/UHRequest.h>
#import <UserHook/UHMessageTemplate.h>
#import <OCMock/OCMock.h>

@interface UHOperationTest : XCTestCase

@end

// used to test private methods
@interface UHOperation (UnitTest)

-(void) handleUpdateSession:(NSData *) data handler:(UHResponseHandler) handler;
-(void) handleFetchHookpoint:(NSData *) data handler:(UHHookPointHandler) handler;
-(void) handleFetchPageNames:(NSData *) data handler:(UHArrayHandler) handler;
-(void) handleFetchMessageTemplates:(NSData *) data;

@end

@implementation UHOperationTest {
    
    id sharedMock;
}

- (void)setUp {
    [super setUp];
    
    sharedMock = OCMClassMock([UserHook class]);
    OCMStub([sharedMock sharedInstance]).andReturn(sharedMock);
    OCMStub([sharedMock applicationId]).andReturn(@"app123");
    OCMStub([sharedMock apiKey]).andReturn(@"key123");
    
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

-(void) testHandleUpdateSession {
    
    id uhUserMock = OCMClassMock([UHUser class]);
    
    id notificationMock = OCMObserverMock();
    [[NSNotificationCenter defaultCenter] addMockObserver:notificationMock name:UH_NotificationNewFeedback object:nil];
    
    
    // stub expectations
    OCMExpect([uhUserMock setUserId:@"user456"]);
    OCMExpect([uhUserMock setKey:@"userkey456"]);
    OCMExpect([sharedMock setHasNewFeedback:YES]);
    [[notificationMock expect] notificationWithName:UH_NotificationNewFeedback object:[OCMArg any] userInfo:[OCMArg any]];
    
    
    NSString * responseString = @"{\"status\":\"success\", \"data\":{\"user\":\"user456\",\"key\":\"userkey456\", \"new_feedback\":true}}";
    NSData * responseData = [responseString dataUsingEncoding:NSUTF8StringEncoding];
    
    UHOperation * operation = [[UHOperation alloc] init];
    
    [operation handleUpdateSession:responseData handler:nil];
    
    [notificationMock verify];
    OCMVerifyAll(uhUserMock);
    OCMVerifyAll(sharedMock);
    
    [[NSNotificationCenter defaultCenter] removeObserver:notificationMock];
    
}

-(void) testHandleFetchHookpoints {
    
    NSString * responseString = @"{\"status\":\"success\", \"data\":{\"hookpoint\": {\"id\":\"hookpoint123\",\"type\":\"survey\",\"name\":\"test survey\"}}}";
    NSData * responseData = [responseString dataUsingEncoding:NSUTF8StringEncoding];
    
    UHOperation * operation = [[UHOperation alloc] init];
    
    XCTestExpectation * expectation = [self expectationWithDescription:@"handler called"];
    
    [operation handleFetchHookpoint:responseData handler:^(UHHookPoint *hookpoint) {
        
        // expect handler to be called
        XCTAssertEqualObjects(hookpoint.id, @"hookpoint123");
        XCTAssertEqualObjects(hookpoint.type, @"survey");
        XCTAssertTrue([hookpoint isKindOfClass:[UHHookPointSurvey class]]);
        
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:1.0 handler:^(NSError * _Nullable error) {
        
    }];
    
}

-(void) testUpdateSession {
    
    // mock network session
    id urlSessionMock = OCMClassMock([NSURLSession class]);
    id mockDataTask = [OCMockObject mockForClass:[NSURLSessionTask class]];
    OCMStub([urlSessionMock dataTaskWithRequest:[OCMArg any] completionHandler:[OCMArg any]]).andReturn(mockDataTask);
    OCMExpect([mockDataTask resume]);
    OCMStub([urlSessionMock sharedSession]).andReturn(urlSessionMock);
    
    // mock user
    id userMock = OCMClassMock([UHUser class]);
    OCMStub([userMock userId]).andReturn(@"user456");
    
    
    // create parameters for request
    NSMutableDictionary * parameters = [NSMutableDictionary dictionaryWithDictionary:@{}];
    [parameters setObject:[UHUser userId] forKey:@"user"];
    [parameters setObject:@"ios" forKey:@"os"];
    [parameters setObject:UH_SDK_VERSION forKey:@"sdk"];
    [parameters setObject:[UHDeviceInfo osVersion] forKey:@"os_version"];
    [parameters setObject:[UHDeviceInfo device] forKey:@"device"];
    [parameters setObject:[UHDeviceInfo locale] forKey:@"locale"];
    [parameters setObject:[UHDeviceInfo appVersion] forKey:@"app_version"];
    [parameters setObject:[NSNumber numberWithFloat:[UHDeviceInfo timezoneOffset]] forKey:@"timezone_offset"];
    
    // mock request
    id requestMock = OCMClassMock([UHRequest class]);
    OCMExpect([requestMock postRequestWithPath:@"session" parameters:parameters]);
    
    
    // make operation call
    UHOperation * operation = [[UHOperation alloc] init];
    [operation updateSessionData:@{} handler:nil];
    
    
    OCMVerifyAll(requestMock);
    OCMVerifyAll(urlSessionMock);
    OCMVerifyAll(mockDataTask);
}



-(void) testFetchHookPoint {
    
    // mock network session
    id urlSessionMock = OCMClassMock([NSURLSession class]);
    id mockDataTask = [OCMockObject mockForClass:[NSURLSessionTask class]];
    OCMStub([urlSessionMock sharedSession]).andReturn(urlSessionMock);
    OCMStub([urlSessionMock dataTaskWithRequest:[OCMArg any] completionHandler:[OCMArg any]]).andReturn(mockDataTask);
    OCMExpect([mockDataTask resume]);
   
    // mock user
    id userMock = OCMClassMock([UHUser class]);
    OCMStub([userMock userId]).andReturn(@"user456");
    
    
    // create parameters for request
    NSDictionary * parameters = [NSDictionary dictionaryWithObjectsAndKeys:[UHUser userId], @"user", nil];
    
    // mock request
    id requestMock = OCMClassMock([UHRequest class]);
    OCMExpect([requestMock getRequestWithPath:@"hookpoint/next" parameters:parameters]);
    
    
    // make operation call
    UHOperation * operation = [[UHOperation alloc] init];
    [operation fetchHookpoint:nil];
    
    
    OCMVerifyAll(requestMock);
    OCMVerifyAll(urlSessionMock);
    OCMVerifyAll(mockDataTask);
}



-(void) testTrackHookPointDisplay {
    
    
    UHHookPoint * hookPoint = [[UHHookPoint alloc] init];
    hookPoint.id = @"hookpoint123";
    
    // mock network session
    id urlSessionMock = OCMClassMock([NSURLSession class]);
    id mockDataTask = [OCMockObject mockForClass:[NSURLSessionTask class]];
    OCMStub([urlSessionMock dataTaskWithRequest:[OCMArg any] completionHandler:[OCMArg any]]).andReturn(mockDataTask);
    OCMExpect([mockDataTask resume]);
    OCMStub([urlSessionMock sharedSession]).andReturn(urlSessionMock);
    
    // mock user
    id userMock = OCMClassMock([UHUser class]);
    OCMStub([userMock userId]).andReturn(@"user456");
    
    
    // create parameters for request
    NSDictionary * parameters = [NSDictionary dictionaryWithObjectsAndKeys:[UHUser userId], @"user", hookPoint.id, @"hookpoint", @"display",@"action", nil];
    
    // mock request
    id requestMock = OCMClassMock([UHRequest class]);
    OCMExpect([requestMock postRequestWithPath:@"hookpoint/track" parameters:parameters]);
    
    
    // make operation call
    UHOperation * operation = [[UHOperation alloc] init];
    [operation trackHookpointDisplay:hookPoint];
    
    
    OCMVerifyAll(requestMock);
    OCMVerifyAll(urlSessionMock);
    OCMVerifyAll(mockDataTask);
}


-(void) testTrackHookPointInteraction {
    
    
    UHHookPoint * hookPoint = [[UHHookPoint alloc] init];
    hookPoint.id = @"hookpoint123";
    
    // mock network session
    id urlSessionMock = OCMClassMock([NSURLSession class]);
    id mockDataTask = [OCMockObject mockForClass:[NSURLSessionTask class]];
    OCMStub([urlSessionMock sharedSession]).andReturn(urlSessionMock);
    OCMStub([urlSessionMock dataTaskWithRequest:[OCMArg any] completionHandler:[OCMArg any]]).andReturn(mockDataTask);
    OCMExpect([mockDataTask resume]);
    
    // mock user
    id userMock = OCMClassMock([UHUser class]);
    OCMStub([userMock userId]).andReturn(@"user456");
    
    
    // create parameters for request
    NSDictionary * parameters = [NSDictionary dictionaryWithObjectsAndKeys:[UHUser userId], @"user", hookPoint.id, @"hookpoint", @"interact",@"action", nil];
    
    // mock request
    id requestMock = OCMClassMock([UHRequest class]);
    OCMExpect([requestMock postRequestWithPath:@"hookpoint/track" parameters:parameters]);
    
    
    // make operation call
    UHOperation * operation = [[UHOperation alloc] init];
    [operation trackHookpointInteraction:hookPoint];
    
    
    OCMVerifyAll(requestMock);
    OCMVerifyAll(urlSessionMock);
    OCMVerifyAll(mockDataTask);
}


-(void) testRegisterPushToken {
    
    NSString * deviceToken = @"pushToken123";
    NSString * environment = @"dev";
    
    // mock network session
    id urlSessionMock = OCMClassMock([NSURLSession class]);
    id mockDataTask = [OCMockObject mockForClass:[NSURLSessionTask class]];
    OCMStub([urlSessionMock sharedSession]).andReturn(urlSessionMock);
    OCMStub([urlSessionMock dataTaskWithRequest:[OCMArg any] completionHandler:[OCMArg any]]).andReturn(mockDataTask);
    OCMExpect([mockDataTask resume]);
    
    // mock user
    id userMock = OCMClassMock([UHUser class]);
    OCMStub([userMock userId]).andReturn(@"user456");
    
    
    // create parameters for request
    NSMutableDictionary * parameters = [NSMutableDictionary dictionary];
    
    [parameters setObject:[UHUser userId] forKey:@"user"];
    [parameters setObject:@"ios" forKey:@"os"];
    [parameters setObject:UH_SDK_VERSION forKey:@"sdk"];
    [parameters setObject:deviceToken forKey:@"token"];
    [parameters setObject:environment forKey:@"env"];
    [parameters setObject:[NSNumber numberWithFloat:[UHDeviceInfo timezoneOffset]] forKey:@"timezone_offset"];
    
    // mock request
    id requestMock = OCMClassMock([UHRequest class]);
    OCMExpect([requestMock postRequestWithPath:@"push/register" parameters:parameters]);
    
    
    // make operation call
    UHOperation * operation = [[UHOperation alloc] init];
    [operation registerDeviceToken:deviceToken forEnvironment:environment retryCount:0];
    
    
    OCMVerifyAll(requestMock);
    OCMVerifyAll(urlSessionMock);
    OCMVerifyAll(mockDataTask);
    
}


-(void) testTrackPushOpen {
    
    NSString * environment = @"dev";
    
    // mock network session
    id urlSessionMock = OCMClassMock([NSURLSession class]);
    id mockDataTask = [OCMockObject mockForClass:[NSURLSessionTask class]];
    OCMStub([urlSessionMock sharedSession]).andReturn(urlSessionMock);
    OCMStub([urlSessionMock dataTaskWithRequest:[OCMArg any] completionHandler:[OCMArg any]]).andReturn(mockDataTask);
    OCMExpect([mockDataTask resume]);
    
    // mock user
    id userMock = OCMClassMock([UHUser class]);
    OCMStub([userMock userId]).andReturn(@"user456");
    
    
    // create parameters for request
    NSMutableDictionary * parameters = [NSMutableDictionary dictionary];
    
    [parameters setObject:[UHUser userId] forKey:@"user"];
    [parameters setObject:@"ios" forKey:@"os"];
    [parameters setObject:UH_SDK_VERSION forKey:@"sdk"];
    [parameters setObject:environment forKey:@"env"];
    [parameters setObject:@"{\"one\":\"two\"}" forKey:@"payload"];
    
    
    // mock request
    id requestMock = OCMClassMock([UHRequest class]);
    OCMExpect([requestMock postRequestWithPath:@"push/open" parameters:parameters]);
    
    
    // make operation call
    UHOperation * operation = [[UHOperation alloc] init];
    [operation trackPushOpen:@{@"one":@"two"} forEnvironment:environment];
    
    
    OCMVerifyAll(requestMock);
    OCMVerifyAll(urlSessionMock);
    OCMVerifyAll(mockDataTask);
    
}


-(void) testFetchPageNaems {
    
    
    // mock network session
    id urlSessionMock = OCMClassMock([NSURLSession class]);
    id mockDataTask = [OCMockObject mockForClass:[NSURLSessionTask class]];
    OCMStub([urlSessionMock sharedSession]).andReturn(urlSessionMock);
    
    OCMStub([urlSessionMock dataTaskWithRequest:[OCMArg any] completionHandler:[OCMArg any]]).andReturn(mockDataTask);
    OCMExpect([mockDataTask resume]);
    
    // mock request
    id requestMock = OCMClassMock([UHRequest class]);
    OCMExpect([requestMock getRequestWithPath:@"page" parameters:nil]);
    
    
    // make operation call
    UHOperation * operation = [[UHOperation alloc] init];
    [operation fetchPageNames:nil];
    
    
    OCMVerifyAll(requestMock);
    OCMVerifyAll(urlSessionMock);
    OCMVerifyAll(mockDataTask);
    
}

-(void) testHandlePageNames {
    
    NSString * responseString = @"{\"status\":\"success\", \"data\":[{\"name\":\"First\", \"slug\":\"first\"}, {\"name\":\"Second\",\"slug\":\"second\"}]}";
    NSData * responseData = [responseString dataUsingEncoding:NSUTF8StringEncoding];
    
    UHOperation * operation = [[UHOperation alloc] init];
    
    XCTestExpectation * expectation = [self expectationWithDescription:@"handler called"];
    
    [operation handleFetchPageNames:responseData handler:^(NSArray *items) {
        XCTAssertEqual([items count], 2);
        
        UHPage * page1 = (UHPage *)[items objectAtIndex:0];
        UHPage * page2 = (UHPage *)[items objectAtIndex:1];
        
        XCTAssertEqualObjects(@"First", page1.name);
        XCTAssertEqualObjects(@"first", page1.slug);
        XCTAssertEqualObjects(@"Second", page2.name);
        XCTAssertEqualObjects(@"second", page2.slug);
        
        
        [expectation fulfill];
    }];
    
    
    
    [self waitForExpectationsWithTimeout:1.0 handler:^(NSError * _Nullable error) {
        
    }];
    
}

-(void) testFetchMessageTemplates {
    
    // mock network session
    id urlSessionMock = OCMClassMock([NSURLSession class]);
    id mockDataTask = [OCMockObject mockForClass:[NSURLSessionTask class]];
    OCMStub([urlSessionMock sharedSession]).andReturn(urlSessionMock);
    
    OCMStub([urlSessionMock dataTaskWithRequest:[OCMArg any] completionHandler:[OCMArg any]]).andReturn(mockDataTask);
    OCMExpect([mockDataTask resume]);
    
    // mock request
    id requestMock = OCMClassMock([UHRequest class]);
    OCMExpect([requestMock getRequestWithPath:@"https://formhost.userhook.com/message/templates"  parameters:nil]);
    
    
    // make operation call
    UHOperation * operation = [[UHOperation alloc] init];
    [operation fetchMessageTemplates];
    
    
    OCMVerifyAll(requestMock);
    OCMVerifyAll(urlSessionMock);
    OCMVerifyAll(mockDataTask);
}


-(void) testHandleFetchMessageTemplates {
    
    NSString * responseString = @"{\"status\":\"success\", \"templates\":{\"one\":\"first template\",\"second\":\"second template\"}}";
    NSData * responseData = [responseString dataUsingEncoding:NSUTF8StringEncoding];
    
    
    id templateCacheMock = OCMClassMock([UHMessageTemplate class]);
    OCMStub([templateCacheMock sharedInstance]).andReturn(templateCacheMock);
    
    OCMExpect([templateCacheMock addToCache:@"one" value:@"first template"]);
    OCMExpect([templateCacheMock addToCache:@"second" value:@"second template"]);
    
    
    UHOperation * operation = [[UHOperation alloc] init];
    [operation handleFetchMessageTemplates:responseData];
    
    OCMVerifyAll(templateCacheMock);
    
}


@end
