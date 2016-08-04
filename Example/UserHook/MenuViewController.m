/*
 * Copyright (c) 2015 - present, Cullaboration Media, LLC.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import "MenuViewController.h"

#import <UserHook/UserHook.h>


@implementation MenuViewController {
    
    NSMutableArray * menuItems;
    NSMutableArray * appItems;
    
    NSMutableArray * staticPages;
    
}


-(void) viewDidLoad {
    [super viewDidLoad];
    
    [self createMenuItems];
    [self loadStaticPages];
    
}

-(void) createMenuItems {
    
    menuItems = [NSMutableArray array];
    
    NSDictionary * feedback = [NSDictionary dictionaryWithObjectsAndKeys:@"Feedback", @"title",@"feedback",@"type", nil];
    NSDictionary * rate = [NSDictionary dictionaryWithObjectsAndKeys:@"Rate This App", @"title",@"rate",@"type", nil];
    [menuItems addObject:feedback];
    [menuItems addObject:rate];
    
    if (staticPages) {
        
        for (UHPage * page in staticPages) {
            NSDictionary * pageItem = [NSDictionary dictionaryWithObjectsAndKeys:page.name, @"title",@"page",@"type", page.slug,@"slug", nil];
            [menuItems addObject:pageItem];
        }
    }
    
    appItems = [NSMutableArray array];
    
    NSDictionary * clearSession = [NSDictionary dictionaryWithObjectsAndKeys:@"Clear User Session", @"title",@"clearSession",@"type", nil];
    NSDictionary * clearUser = [NSDictionary dictionaryWithObjectsAndKeys:@"Clear User Hook User", @"title",@"clearUser",@"type", nil];
    [appItems addObject:clearSession];
    [appItems addObject:clearUser];
    
}

-(void) loadStaticPages {
    
    staticPages = [NSMutableArray array];
    
    // fetch the static page names from the server
    [UserHook fetchPageNames:^(NSArray *items) {
        
        [staticPages addObjectsFromArray:items];
        
        [self createMenuItems];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
        
    }];
    
}

#pragma mark - table delegate methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (section == 0) {
        return [menuItems count];
    }
    else if (section == 1) {
        return [appItems count];
    }
    else {
        return 0;
    }
    
}

-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}


-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSArray * itemArray;
    
    if (indexPath.section == 0) {
        itemArray = menuItems;
    }
    else {
        itemArray = appItems;
    }
    
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"menuItem"];
    
    UILabel * label = (UILabel *)[cell viewWithTag:1];
    
    label.text = [[itemArray objectAtIndex:indexPath.row] valueForKey:@"title"];
    
    return cell;
    
    
}

-(CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"sectionHeader"];
    return cell.frame.size.height;
}

-(UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"sectionHeader"];
    UILabel * label = (UILabel *)[cell viewWithTag:1];
    
    if (section == 0) {
        label.text = @"APP EXAMPLES";
    }
    else if (section == 1) {
        label.text = @"DEMP APP ADMIN FUNCTIONS";
    }
    else {
        label.text = @"";
    }
    
    return cell;
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSArray * itemArray;
    
    if (indexPath.section == 0) {
        itemArray = menuItems;
    }
    else {
        itemArray = appItems;
    }
    
    NSDictionary * item = [itemArray objectAtIndex:indexPath.row];
    
    if ([[item valueForKey:@"type"] isEqualToString:@"feedback"]) {
        
        [UserHook displayFeedback];
        
        
    }
    else if ([[item valueForKey:@"type"] isEqualToString:@"page"]) {
        
        NSString * slug  = [item valueForKey:@"slug"];
        UHHostedPageViewController * page = [UserHook createHostedPageViewController:slug];
        page.navigationItem.title = [item valueForKey:@"title"];
        
        UINavigationController * navController  = [[UINavigationController alloc] initWithRootViewController:page];
        [self presentViewController:navController animated:YES completion:nil];
        
    }
    else if ([[item valueForKey:@"type"] isEqualToString:@"rate"]) {
        
        
        // show a prompt before sending to the rating screen
        // this allows users the app to route unhappy users to the feedback screen
        // instead of the rating screen
        
        UHMessageMetaButton * button1 = [[UHMessageMetaButton alloc] init];
        button1.title = @"Yes";
        [button1 setClickHandler:^() {
            [self showRatePrompt];
        }];
        
        UHMessageMetaButton * button2 = [[UHMessageMetaButton alloc] init];
        button2.title = @"No";
        [button2 setClickHandler:^() {
            [self showFeedbackPromptOnNoRating];
        }];
        
        [UserHook displayPrompt:@"We are glad you downloaded the app. Are you enjoying using it?" button1:button1 button2:button2];
        
        
        
    }
    else if ([[item valueForKey:@"type"] isEqualToString:@"clearSession"]) {
        
        // clear the session for this user in the demo app
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"score"];
        
        // force the creation of a new session. In a production app you would never do this. The SDK handles
        // all session tracking.
        UHOperation * op = [[UHOperation alloc] init];
        [op createSession];
        
        // show alert to user confirming the purchase
        UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"Clear Session" message:@"Your session data has been cleared." preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *okAction = [UIAlertAction
                                   actionWithTitle:@"OK"
                                   style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction *action)
                                   {
                                       
                                   }];
        
        [alert addAction:okAction];
        
        
        [self presentViewController:alert animated:YES completion:nil];
        
        
    }
    
    else if ([[item valueForKey:@"type"] isEqualToString:@"clearUser"]) {
        
        // clear the session for this user in the demo app
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"score"];
        
        // used just in the demo app. In a production app there is no reason to call this
        [UHUser clearUser];
        
        // Since we just cleared the user, get a new User Hook session which will also automatically
        // create a new User Hook user record on the server and in the app. In a production app you would never do this.
        UHOperation * op = [[UHOperation alloc] init];
        [op createSession];
        
        
        // show alert to user confirming the purchase
        UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"Clear User" message:@"User Hook user has been cleared." preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *okAction = [UIAlertAction
                                   actionWithTitle:@"OK"
                                   style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction *action)
                                   {
                                       
                                   }];
        
        [alert addAction:okAction];
        
        
        [self presentViewController:alert animated:YES completion:nil];
        
        
    }
    
}


-(void) showFeedbackPromptOnNoRating {
    
    [UserHook displayFeedbackPrompt:@"We are sorry to hear that you aren't enjoying the app. Do you mind sending us some feedback on how to make it better?" positiveButtonTitle:@"Sure" negativeButtonTitle:@"Not Now"];
    
       
}

-(void) showRatePrompt {
    
    [UserHook displayRatePrompt:@"Do you mind leaving us a rating and review in the App Store?" positiveButtonTitle:@"Yes" negativeButtonTitle:@"Not Now"];
    
}


@end
