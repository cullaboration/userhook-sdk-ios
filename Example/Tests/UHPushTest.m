//
//  UHPushTest.m
//  UserHook
//
//  Created by Matt Johnston on 10/7/16.
//  Copyright © 2016 mattjohnston. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <UserHook/UserHook.h>
#import <UserHook/UHPush.h>
#import <UserHook/UHOperation.h>

#import <OCMock/OCMock.h>

@interface UHPushTest : XCTestCase

@end

@implementation UHPushTest

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

-(void) testIsPushFromUserHook {
    
    NSDictionary * validData = @{@"data":@{@"source":@"userhook"}};
    NSDictionary * invalidData1 = @{@"data":@{@"source":@"otherPushProvider"}};
    NSDictionary * invalidData2 = @{@"data":@{}};
    
    XCTAssertTrue([UHPush isPushFromUserHook:validData]);
    XCTAssertFalse([UHPush isPushFromUserHook:invalidData1]);
    XCTAssertFalse([UHPush isPushFromUserHook:invalidData2]);
    
}

-(void) testGetPushPayload {
    
    NSDictionary * payload = @{@"one":@"two"};
    
    NSDictionary * validData = @{@"data":@{@"payload":payload}};
    NSDictionary * invalidData = @{@"data":@{}};
    
    XCTAssertEqualObjects([UHPush getPushPayload:validData], payload);
    XCTAssertNotEqualObjects([UHPush getPushPayload:invalidData], payload);
    XCTAssertNil([UHPush getPushPayload:invalidData]);
    
}

-(void) testRegisterPushToken {
    
    //mock operation
    id operationMock = OCMClassMock([UHOperation class]);
    OCMStub([operationMock new]).andReturn(operationMock);
    
    NSString * pushToken = @"pushToken123";
    NSData * data = [pushToken dataUsingEncoding:NSUTF8StringEncoding];
    
    // byte decoded version of the pushToken
    NSString * decodedToken = @"70757368546f6b656e313233";
    
    OCMExpect([operationMock registerDeviceToken:decodedToken forEnvironment:[OCMArg any] retryCount:1]);
    
    [UHPush registerDeviceToken:data];
    
    OCMVerifyAll(operationMock);
}

-(void) testTrackPushOpen {
    
    //mock operation
    id operationMock = OCMClassMock([UHOperation class]);
    OCMStub([operationMock new]).andReturn(operationMock);
    
    NSDictionary * userInfo = @{@"one":@"two"};
    
    
    OCMExpect([operationMock trackPushOpen:userInfo forEnvironment:[OCMArg any]]);
    
    
    [UHPush trackPushOpen:userInfo];
    
    OCMVerifyAll(operationMock);
}

@end
