/*
 * Copyright (c) 2015 - present, Cullaboration Media, LLC.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import <UIKit/UIKit.h>
#import "UHMessageMeta.h"
#import "UHHookPointMessage.h"

@class UHMessageView;

typedef void(^UHMessageViewHandler)(UHMessageView * dialogView);

@interface UHMessageView : UIView<UIWebViewDelegate>

+(UHMessageView *) createViewForMeta:(UHMessageMeta *) meta;
+(UHMessageView *) createViewForHookPoint:(UHHookPointMessage *) hookpoint;

-(void)showDialog;
-(void)hideDialog;

+(BOOL) canDisplay;



@end
