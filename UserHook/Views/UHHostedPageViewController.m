/*
 * Copyright (c) 2015 - present, Cullaboration Media, LLC.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import "UHHostedPageViewController.h"
#import "UHWebView.h"
#import "UHHookpoint.h"
#import "UserHook.h"
#import "UHRequest.h"

@interface UHHostedPageViewController ()

@property (nonatomic, strong) UHWebView * webView;
@property (nonatomic, strong) UHRequest * request;
@end

@implementation UHHostedPageViewController


-(id) initWithPageName:(NSString *)pageName {
    self = [self init];
    
    NSString * url = [NSString stringWithFormat:@"%@page/%@", UH_HOST_URL, pageName];
    _request = [UHRequest getRequestWithPath:url parameters:nil];
    
    return self;
}

-(id) initWithPageUrl:(NSString *) url {
    self = [self init];
    
    _request = [UHRequest getRequestWithPath:url parameters:nil];
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    
    _webView = [[UHWebView alloc] init];
    _webView.delegate = self;
    
    
    [self.view addSubview:_webView];
    
    [_webView setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [self.view addConstraints:[NSLayoutConstraint
                               constraintsWithVisualFormat:@"H:|-0-[_webView]-0-|"
                               options:NSLayoutFormatDirectionLeadingToTrailing
                               metrics:nil
                               views:NSDictionaryOfVariableBindings(_webView)]];
    
    
    
    [self.view addConstraints:[NSLayoutConstraint
                               constraintsWithVisualFormat:@"V:|-0-[_webView]-0-|"
                               options:NSLayoutFormatDirectionLeadingToTrailing
                               metrics:nil
                               views:NSDictionaryOfVariableBindings(_webView)]];
    
    
    [_webView loadRequest:_request];
    
    if (self.navigationController && [self.navigationController.viewControllers count] == 1) {
        UIBarButtonItem * doneBtn = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(clickedClose)];
        self.navigationItem.leftBarButtonItem = doneBtn;
    }
    
    
}

-(void) clickedClose {
    
    if (self.navigationController) {
        [self.navigationController dismissViewControllerAnimated:YES completion:^{
            
        }];
    }
    else {
        [self dismissViewControllerAnimated:YES completion:^{
            
        }];
    }
}


/*
 since UHHostPage wants to be the webview delegate, we need to pass this to the UHWebView object because
 it has some logic to include request headers
 */

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    
    if ([[[request URL] scheme] isEqualToString:UH_PROTOCOL]) {
        // callback from webview to close this view
        if ([[[request URL] host] isEqualToString:@"close"]) {
            [self clickedClose];
            return NO;
        }
        // track the user interaction for this hookpoint and then close the view
        else if ([[[request URL] host] isEqualToString:@"trackInteractionAndClose"]) {
            NSString * hookpointId = [[request URL] path];
            if (hookpointId && ![hookpointId isEqualToString:@"/"]) {
                hookpointId = [hookpointId stringByReplacingOccurrencesOfString:@"/" withString:@""];
                UHHookPoint * hookPoint = [[UHHookPoint alloc] init];
                hookPoint.id = hookpointId;
                [UserHook trackHookPointInteraction:hookPoint];
            }
            [self clickedClose];
            return NO;
        }
    }
    
    return [_webView webView:webView shouldStartLoadWithRequest:request navigationType:navigationType];
}



@end
