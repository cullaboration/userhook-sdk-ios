//
//  UHHookpointTest.m
//  UserHook
//
//  Created by Matt Johnston on 9/30/16.
//  Copyright © 2016 mattjohnston. All rights reserved.
//

#import <XCTest/XCTest.h>

#import <UserHook/UHHookPointMessage.h>
#import <UserHook/UHHookPointAction.h>
#import <UserHook/UHHookPointSurvey.h>

@interface UHHookpointTest : XCTestCase

@end

@implementation UHHookpointTest


-(void) testMessageHookpointFromDictionary {
    
    NSDictionary * params = @{@"hookpoint" : @{@"type": [UHHookPointMessage type]}};
    
    UHHookPoint * hookpoint = [UHHookPoint createWithData:params];
    
    XCTAssertEqual([hookpoint class], [UHHookPointMessage class]);
    
};


-(void) testSurveyHookpointFromDictionary {
    

    
    NSDictionary * meta = @{@"survey":@"123",@"publicTitle":@"A Title"};
    NSDictionary * params = @{@"hookpoint" : @{@"type": [UHHookPointSurvey type], @"meta": meta}};
    params = [params mutableCopy];
    
    UHHookPointSurvey * hookpoint = [UHHookPoint createWithData:params];
    
    
    XCTAssertEqual([hookpoint class], [UHHookPointSurvey class]);
    
    XCTAssertNotNil(hookpoint.surveyId);
    XCTAssertNotNil(hookpoint.publicTitle);
    
    // did meta info parse correctly
    XCTAssertEqual(hookpoint.surveyId, @"123");
    XCTAssertEqual(hookpoint.publicTitle, @"A Title");
    
}


-(void) testActionHookpointFromDictionary {
    
    NSDictionary * meta = @{@"payload":@"{\"action\":\"action name\"}"};
    
    NSDictionary * params = @{@"hookpoint" : @{@"type": [UHHookPointAction type], @"meta":meta}};
    
    UHHookPointAction * hookpoint = [UHHookPoint createWithData:params];
    
    
    XCTAssertEqual([hookpoint class], [UHHookPointAction class]);
    
    // did payload parse correctly?
    XCTAssertNotNil(hookpoint.payload);
    XCTAssertEqualObjects([hookpoint.payload valueForKey:@"action"], @"action name");
    
}

@end
