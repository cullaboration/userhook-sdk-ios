//
//  UHRequestTest.m
//  UserHook
//
//  Created by Matt Johnston on 9/30/16.
//  Copyright © 2016 mattjohnston. All rights reserved.
//

#import <UserHook/UHRequest.h>
#import <UserHook/UserHook.h>

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>

@interface UHRequestTest : XCTestCase

@end

@implementation UHRequestTest

- (void)setUp {
    [super setUp];
    
    
    id sharedMock = OCMClassMock([UserHook class]);
    OCMStub([sharedMock sharedInstance]).andReturn(sharedMock);
    OCMStub([sharedMock applicationId]).andReturn(@"app123");
    OCMStub([sharedMock apiKey]).andReturn(@"key123");
    
    id uhUserMock = OCMClassMock([UHUser class]);
    OCMStub([uhUserMock userId]).andReturn(@"testuser123");
    OCMStub([uhUserMock key]).andReturn(@"testuserkey123");
    
    
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

-(void) testAddHeadersToRequest {
    
    UHRequest * request = [UHRequest getRequestWithPath:@"test" parameters:@{@"one":@"1",@"two":@"2"}];
    
    XCTAssertEqualObjects([[request URL] absoluteString] ,@"https://api.userhook.com/test?one=1&two=2");
    XCTAssertEqualObjects(request.HTTPMethod, @"GET");
    
    NSDictionary * headers = [request allHTTPHeaderFields];
    XCTAssertEqualObjects([headers valueForKey:@"X-USERHOOK-APP-ID"], @"app123");
    XCTAssertEqualObjects([headers valueForKey:@"X-USERHOOK-APP-KEY"], @"key123");
    XCTAssertEqualObjects([headers valueForKey:@"X-USERHOOK-USER-ID"] , @"testuser123");
    XCTAssertEqualObjects([headers valueForKey:@"X-USERHOOK-USER-KEY"] , @"testuserkey123");
    
    XCTAssertTrue([UHRequest hasUserHookHeaders:request]);

    
}

-(void) testPostRequest {
    
    UHRequest * request = [UHRequest postRequestWithPath:@"test" parameters:@{@"one":@"1",@"two":@"2"}];
    
    XCTAssertEqualObjects([[request URL] absoluteString] ,@"https://api.userhook.com/test");
    XCTAssertEqualObjects(request.HTTPMethod, @"POST");
    
    // parameters should be stored in the request body
    NSData * body = request.HTTPBody;
    NSString * bodyString = [[NSString alloc] initWithData:body encoding:NSUTF8StringEncoding];
    XCTAssertEqualObjects(bodyString, @"one=1&two=2");
    
    
    NSDictionary * headers = [request allHTTPHeaderFields];
    XCTAssertEqualObjects([headers valueForKey:@"X-USERHOOK-APP-ID"], @"app123");
    XCTAssertEqualObjects([headers valueForKey:@"X-USERHOOK-APP-KEY"], @"key123");
    XCTAssertEqualObjects([headers valueForKey:@"X-USERHOOK-USER-ID"] , @"testuser123");
    XCTAssertEqualObjects([headers valueForKey:@"X-USERHOOK-USER-KEY"] , @"testuserkey123");

}


@end
