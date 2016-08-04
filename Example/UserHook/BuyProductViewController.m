/*
 * Copyright (c) 2015 - present, Cullaboration Media, LLC.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import "BuyProductViewController.h"

#import <UserHook/UserHook.h>

@implementation BuyProductViewController

- (IBAction)clickedBuyItem1:(id)sender {
    
    [self buyProduct:@"sku1" price:@0.99];
}

- (IBAction)clickedBuyItem2:(id)sender {
    [self buyProduct:@"sku2" price:@1.99];
}

-(void) buyProduct:(NSString *) sku price:(NSNumber *)price {
    
    // send the purchase data to User Hook
    [UserHook updatePurchasedItem:sku forAmount:price];
    
    // show alert to user confirming the purchase
    UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"Item Purchased" message:[NSString  stringWithFormat:@"You just bought %@ for $%@", sku, price] preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *okAction = [UIAlertAction
                               actionWithTitle:@"OK"
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction *action)
                               {
                                   
                               }];
    
    [alert addAction:okAction];
    
    
    [self presentViewController:alert animated:YES completion:nil];
    
    
}
@end
