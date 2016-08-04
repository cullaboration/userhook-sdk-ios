/*
 * Copyright (c) 2015 - present, Cullaboration Media, LLC.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import "CustomFieldViewController.h"
#import <UserHook/UserHook.h>

@implementation CustomFieldViewController {
    NSInteger currentScore;
}


-(void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // load the previously stored score
    currentScore = [[NSUserDefaults standardUserDefaults] integerForKey:@"score"];
    _scoreLabel.text = [NSString stringWithFormat:@"%li", (long)currentScore];
}



- (IBAction)clickedAddToScore:(id)sender {
    
    // increment the user score
    currentScore++;
    _scoreLabel.text = [NSString stringWithFormat:@"%li", (long)currentScore];
    
    // save the current score so we can retrieve it later
    [[NSUserDefaults standardUserDefaults] setInteger:currentScore forKey:@"score"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    // send the custom field to User Hook
    NSMutableDictionary * customFields = [NSMutableDictionary dictionary];
    [customFields setValue:[NSNumber numberWithInteger:currentScore] forKey:@"score"];
    
    [UserHook updateCustomFields:customFields];
    
    
}
@end
