/*
 * Copyright (c) 2015 - present, Cullaboration Media, LLC.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import "UHUser.h"

#define UH_USER_ID @"UH_userid"
#define UH_USER_KEY @"UH_userkey"

@implementation UHUser

+(NSString *) userId {
   return [[NSUserDefaults standardUserDefaults] valueForKey:UH_USER_ID];
   
}

+(void) setUserId:(NSString *) userId {
    if (userId != nil && ![userId isEqualToString:@""]) {
        [[NSUserDefaults standardUserDefaults] setValue:userId forKey:UH_USER_ID];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

+(NSString *) key {
    return [[NSUserDefaults standardUserDefaults] valueForKey:UH_USER_KEY];
    
}

+(void) setKey:(NSString *) key {
    if (key != nil && ![key isEqualToString:@""]) {
        [[NSUserDefaults standardUserDefaults] setValue:key forKey:UH_USER_KEY];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

+(void) clearUser {
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:UH_USER_ID];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:UH_USER_KEY];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
