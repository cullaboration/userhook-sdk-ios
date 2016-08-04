/*
 * Copyright (c) 2015 - present, Cullaboration Media, LLC.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import "UHMessageTemplate.h"

@interface UHMessageTemplate()

@property (nonatomic, strong) NSCache * cache;

@end


static UHMessageTemplate * _sharedInstance;

@implementation UHMessageTemplate

-(id) init {
    self = [super init];
    
    self.cache = [[NSCache alloc] init];
    
    return self;
}

+(UHMessageTemplate *) sharedInstance {
    if (_sharedInstance == nil) {
        _sharedInstance = [[UHMessageTemplate alloc] init];
    }
    
    return  _sharedInstance;
}

-(void) addToCache:(NSString *) key value:(NSString *) value {
    [self.cache setObject:value forKey:key];
}

-(BOOL) hasTemplate:(NSString *)name {
    
    return [self.cache objectForKey:name] != nil;
}

-(NSString *) renderTemplate:(UHMessageMeta *) meta {
    
    NSString * html = [self.cache objectForKey:meta.displayType];
    
    // merge values into template
    if (meta.button1.title) {
        html = [html stringByReplacingOccurrencesOfString:@"<!-- button1 -->" withString:meta.button1.title];
    }
    
    if (meta.button2.title) {
        html = [html stringByReplacingOccurrencesOfString:@"<!-- button2 -->" withString:meta.button2.title];
    }
    
    if (meta.button1.image.url) {
        html = [html stringByReplacingOccurrencesOfString:@"<!-- image -->" withString:meta.button1.image.url];
    }
    
    if (meta.body) {
        html = [html stringByReplacingOccurrencesOfString:@"<!-- body -->" withString:meta.body];
    }
    
    return html;
    
}

@end
