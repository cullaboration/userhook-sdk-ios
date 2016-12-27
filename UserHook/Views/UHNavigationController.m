/*
 * Copyright (c) 2015 - present, Cullaboration Media, LLC.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import "UHNavigationController.h"

@interface UHNavigationController ()

@end

@implementation UHNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



/*
 This is needed because an image picker opened in a webview may not be on the same
 window heirarchy.
 */
-(void)dismissViewControllerAnimated:(BOOL)flag completion:(void (^)(void))completion
{
    if ( self.presentedViewController || !completion) {
        [super dismissViewControllerAnimated:flag completion:completion];
    }
    
}


@end
