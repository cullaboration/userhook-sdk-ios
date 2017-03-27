/*
 * Copyright (c) 2015 - present, Cullaboration Media, LLC.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import "UHRequest.h"
#import "UserHook.h"
#import "UHUser.h"

static NSString * const UHApplicationIdHeaderName = @"X-USERHOOK-APP-ID";
static NSString * const UHApplicationKeyHeaderName = @"X-USERHOOK-APP-KEY";
static NSString * const UHUserIdHeaderName = @"X-USERHOOK-USER-ID";
static NSString * const UHUserKeyHeaderName = @"X-USERHOOK-USER-KEY";

static NSString * const UHSdkHeaderName = @"X-USERHOOK-SDK";
NSString * const UHSdkHeaderPrefix = @"ios-";


static NSString * escapeString(NSString *unencodedString)
{
    if ([unencodedString isKindOfClass:[NSNumber class]]) {
        unencodedString = [(NSNumber *)unencodedString stringValue];
    }
    
    NSString *s = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL,
                                                                                        (CFStringRef)unencodedString,
                                                                                        NULL,
                                                                                        (CFStringRef)@"!*'\"();:@&=+$,/?%#[]% ",
                                                                                        kCFStringEncodingUTF8));
    return s;
    
}



@implementation UHRequest


+(UHRequest *) requestWithURL:(NSURL *) url {
    UHRequest * request = [super requestWithURL:url];
    [request addUserHookHeaders];
    return request;
}

+(UHRequest *) requestFromRequest:(NSURLRequest *)request {
    
    UHRequest * urequest = [super requestWithURL:[request URL]];
    [urequest addUserHookHeaders];
    
    
    urequest.HTTPMethod = request.HTTPMethod;
    
    if (request.HTTPBody) {
        urequest.HTTPBody = request.HTTPBody;
    }
    
    // add headers
    NSDictionary * headers = [request allHTTPHeaderFields];
    if ([headers valueForKey:@"Content-Type"]) {
        [urequest setValue:[headers valueForKey:@"Content-Type"] forHTTPHeaderField:@"Content-Type"];
    }
    
    return urequest;

}

+(UHRequest *) getRequestWithPath:(NSString *)path parameters:(NSDictionary *)parameters {
    UHRequest * request =  [self requestWithPath:path httpMethod:@"GET" parameters:parameters];
    [request addUserHookHeaders];
    return request;
}
+(UHRequest *) postRequestWithPath:(NSString *)path parameters:(NSDictionary *)parameters {
    UHRequest * request =  [self requestWithPath:path httpMethod:@"POST" parameters:parameters];
    [request addUserHookHeaders];
    return request;
}

+(UHRequest *) requestWithPath:(NSString *)path httpMethod:(NSString *)method parameters:(NSDictionary *)parameters {
    
    NSParameterAssert(path != nil);
    NSParameterAssert(method != nil);
    
    NSString * urlString;
    if (![path hasPrefix:@"http"]) {
        urlString = [NSString stringWithFormat:@"%@%@", UH_API_URL, path];
    }
    else {
        urlString = path;
    }
    
    if (parameters != nil && ![method isEqualToString:@"POST"]) {
        if ([urlString rangeOfString:@"?"].location == NSNotFound) {
            urlString = [urlString stringByAppendingString:[NSString stringWithFormat:@"?%@", [self parametersToQueryString:parameters]]];
        }
        else {
            urlString = [urlString stringByAppendingString:[NSString stringWithFormat:@"&%@", [self parametersToQueryString:parameters]]];
        }
    }
    
    
    UHRequest * request = [UHRequest requestWithURL:[NSURL URLWithString:urlString]];
    
    request.HTTPMethod = method;
    
    // add parameters
    if (parameters != nil && [method isEqualToString:@"POST"]) {
        request.HTTPBody = [[self parametersToQueryString:parameters] dataUsingEncoding:NSUTF8StringEncoding];
    }
    
    return request;
    
}

+(UHRequest *) requestWithUrl:(NSString *)url httpMethod:(NSString *)method parameters:(NSDictionary *)parameters {
    
    NSParameterAssert(url != nil);
    NSParameterAssert(method != nil);
    
    if (parameters != nil && ![method isEqualToString:@"POST"]) {
        if ([url rangeOfString:@"?"].location == NSNotFound) {
            url = [url stringByAppendingString:[NSString stringWithFormat:@"?%@", [self parametersToQueryString:parameters]]];
        }
        else {
            url = [url stringByAppendingString:[NSString stringWithFormat:@"&%@", [self parametersToQueryString:parameters]]];
        }
    }
    
    
    UHRequest * request = [UHRequest requestWithURL:[NSURL URLWithString:url]];
    
    request.HTTPMethod = method;
    
    // add parameters
    if (parameters != nil && [method isEqualToString:@"POST"]) {
        request.HTTPBody = [[self parametersToQueryString:parameters] dataUsingEncoding:NSUTF8StringEncoding];
    }
    
    return request;
    
}
     
-(void) addUserHookHeaders {
    // add application headers
    [self setValue:[[UserHook sharedInstance] applicationId] forHTTPHeaderField:UHApplicationIdHeaderName];
    [self setValue:[[UserHook sharedInstance] apiKey] forHTTPHeaderField:UHApplicationKeyHeaderName];
    
    // add user headers
    if ([UHUser userId] != nil) {
        [self setValue:[UHUser userId] forHTTPHeaderField:UHUserIdHeaderName];
        [self setValue:[UHUser key] forHTTPHeaderField:UHUserKeyHeaderName];
    }
    
    // add sdk header
    [self setValue:[NSString stringWithFormat:@"%@%@", UHSdkHeaderPrefix,  UH_SDK_VERSION] forHTTPHeaderField:UHSdkHeaderName];

}

+ (NSString *)parametersToQueryString:(NSDictionary *) parameters
{
    NSMutableString *queryString = [[NSMutableString alloc] init];
    NSArray *keys = [parameters allKeys];
    
    if ([keys count] > 0) {
        for (id key in keys) {
            id value = [parameters objectForKey:key];
            
            if (![queryString isEqualToString:@""]) {
                [queryString appendString:@"&"];
            }
            
            if (nil != key && nil != value) {
                [queryString appendFormat:@"%@=%@", escapeString(key), escapeString(value)];
            } else if (nil != key) {
                [queryString appendFormat:@"%@", escapeString(key)];
            }
        }
    }
    
    return queryString;
}

+(BOOL) hasUserHookHeaders:(NSURLRequest *) request {
    NSDictionary * headers = [request allHTTPHeaderFields];
    return ([headers valueForKey:UHApplicationIdHeaderName] != nil && [headers valueForKey:UHApplicationKeyHeaderName] != nil
        && [headers valueForKey:UHUserKeyHeaderName] != nil && [headers valueForKey:UHUserIdHeaderName] != nil
          && [headers valueForKey:UHSdkHeaderName] != nil   );
}


+(NSDictionary *) dataParamsToDictionary:(NSData *)data {
    
    NSString * paramsString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    paramsString = [self unescapeString:paramsString];
    
    NSMutableDictionary * dict = [NSMutableDictionary dictionary];
    
    for (NSString * pairString in [paramsString componentsSeparatedByString:@"&"]) {
        
        NSArray * pair = [pairString componentsSeparatedByString:@"="];
        
        if ([pair count] < 2) {
            continue;
        }
        
        // add to dictionary
        [dict setValue:pair[1] forKey:pair[0]];
        
    }
    
    return dict;
}

+(NSString *) unescapeString:(NSString *) string {
    
    return [[string stringByReplacingOccurrencesOfString:@"+" withString:@" "] stringByRemovingPercentEncoding];
}
@end
