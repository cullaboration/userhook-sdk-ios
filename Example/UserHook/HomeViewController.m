/*
 * Copyright (c) 2015 - present, Cullaboration Media, LLC.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import "HomeViewController.h"

#import "MFSideMenu.h"
#import <UserHook/UserHook.h>
#import "AppDelegate.h"

@implementation HomeViewController


-(void) viewDidLoad {
    
    // respond to the User Hook new feedback response
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showFeedback) name:UH_NotificationNewFeedback object:nil];
    
}

-(void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (IBAction)clickedMenu:(id)sender {
    
    [self.menuContainerViewController toggleLeftSideMenuCompletion:nil];
    
}

- (IBAction)clickedReloadHookpoints:(id)sender {
    
    [((AppDelegate *)[UIApplication sharedApplication].delegate) loadHookpoints];
}

-(void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
}




#pragma mark - UserHook


-(void) showFeedback {
    
    [UserHook displayFeedbackPrompt:@"You have a new response to your recently submitted feedback. Do you want to read it now?" positiveButtonTitle:@"Read Now" negativeButtonTitle:@"Later"];
    
}



@end
