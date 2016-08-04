/*
 * Copyright (c) 2015 - present, Cullaboration Media, LLC.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import "UHWebView.h"
#import "UserHook.h"
#import "UHRequest.h"

@implementation UHWebView

-(void)awakeFromNib {
    self.delegate = self;
}

-(BOOL) webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    
    
    if ([[request.URL absoluteString] hasPrefix:UH_HOST_URL]) {
        
        // see if request has the user hook headers
        if (![UHRequest hasUserHookHeaders:request]) {
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                dispatch_async(dispatch_get_main_queue(), ^{
                    UHRequest* urequest = [UHRequest requestFromRequest:request];
                    
                    // reload the new request with the user hook headers
                    [self loadRequest:urequest];
                });
            });
            
            return NO;
        }
    }
    
    return YES;

    
}


@end
