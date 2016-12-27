/*
 * Copyright (c) 2015 - present, Cullaboration Media, LLC.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>

@interface UHWebView : UIView<UIWebViewDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate>

- (void) setWebViewDelegate:(id <UIWebViewDelegate>) delegate;
- (void)loadRequest:(NSURLRequest *)request;
- (void)loadHTMLString:(NSString *)string baseURL:(NSURL *)baseURL;

-(void) setScrollable:(BOOL) scrollable;
-(void) setBackgroundTransparent;
@end
