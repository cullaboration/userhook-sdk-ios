/*
 * Copyright (c) 2015 - present, Cullaboration Media, LLC.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>

@interface UHHostedPageViewController : UIViewController<UIWebViewDelegate>

-(id) initWithPageName:(NSString *) pageName;
-(id) initWithPageUrl:(NSString *) url;

@end
