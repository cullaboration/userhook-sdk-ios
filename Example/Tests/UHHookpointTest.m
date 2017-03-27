//
//  UHHookpointTest.m
//  UserHook
//
//  Created by Matt Johnston on 9/30/16.
//  Copyright © 2016 mattjohnston. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>

#import <UserHook/UserHook.h>
#import <UserHook/UHHookPointMessage.h>
#import <UserHook/UHHookPointAction.h>
#import <UserHook/UHHookPointSurvey.h>
#import <UserHook/UHHookPoint.h>
#import <UserHook/UHMessageView.h>

@interface UHHookpointTest : XCTestCase

@end

@implementation UHHookpointTest

-(void) testMessageHookpointFromModel {
    
    
    UHHookPointModel * model = [UHHookPointModel new];
    model.type = UHHookPointTypeMessage;
    
    UHHookPoint * hookpoint = [UHHookPoint createWithModel:model];
    
    XCTAssertEqual([hookpoint class], [UHHookPointMessage class]);
    
};


-(void) testSurveyHookpointFromModel {
    
    UHHookPointModel * model = [UHHookPointModel new];
    
    model.meta = @{@"survey":@"123",@"publicTitle":@"A Title"};;
    model.type = UHHookPointTypeSurvey;
    
    UHHookPointSurvey * hookpoint = [UHHookPoint createWithModel:model];
    
    
    XCTAssertEqual([hookpoint class], [UHHookPointSurvey class]);
    
    XCTAssertNotNil(hookpoint.surveyId);
    XCTAssertNotNil(hookpoint.publicTitle);
    
    // did meta info parse correctly
    XCTAssertEqual(hookpoint.surveyId, @"123");
    XCTAssertEqual(hookpoint.publicTitle, @"A Title");
    
}


-(void) testActionHookpointFromDictionary {
    
    
    UHHookPointModel * model = [UHHookPointModel new];
    model.type = UHHookPointTypeAction;
    model.meta = @{@"payload":@"{\"action\":\"action name\"}"};
    
    UHHookPointAction * hookpoint = [UHHookPoint createWithModel:model];
    
    
    XCTAssertEqual([hookpoint class], [UHHookPointAction class]);
    
    // did payload parse correctly?
    XCTAssertNotNil(hookpoint.payload);
    XCTAssertEqualObjects([hookpoint.payload valueForKey:@"action"], @"action name");
    
}

-(void) testExecuteActionHookPoint {
    
    
    id uhMock = OCMClassMock([UserHook class]);
    
    UHHookPointAction * hookpoint = [UHHookPointAction new];
    NSDictionary * payload = @{@"one":@"two"};
    
    hookpoint.payload = payload;
    
    
    OCMExpect([uhMock handlePayload:payload]);
    OCMExpect([uhMock trackHookPointInteraction:hookpoint]);
    
    [hookpoint execute];
    
    OCMVerifyAll(uhMock);
    [uhMock stopMocking];
    
}

-(void) testHookPointMessageShow {
    
    
    UHHookPointMessage * hookpoint = [UHHookPointMessage new];
    
    id messageMock = OCMClassMock([UHMessageView class]);
    
    OCMStub([messageMock canDisplay]).andReturn(true);
    OCMExpect([messageMock createViewForHookPoint:hookpoint]).andReturn(messageMock);
    OCMExpect([messageMock showDialog]);
    
    [hookpoint addAndShowView];
    
    OCMVerifyAll(messageMock);
}

-(void) testHookPointMessageDontShow {
    
    
    UHHookPointMessage * hookpoint = [UHHookPointMessage new];
    
    id messageMock = OCMClassMock([UHMessageView class]);
    
    OCMStub([messageMock canDisplay]).andReturn(false);
    OCMReject([messageMock showDialog]);
    
    [hookpoint addAndShowView];
    
    OCMVerifyAll(messageMock);
}

@end
