/*
 * Copyright (c) 2015 - present, Cullaboration Media, LLC.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import <Foundation/Foundation.h>

#import <JSONModel/JSONModel.h>

static NSString * const UHMessageTypeImage = @"image";
static NSString * const UHMessageTypeTwoButtons = @"twobuttons";
static NSString * const UHMessageTypeOneButton = @"onebutton";
static NSString * const UHMessageTypeNoButtons = @"nobuttons";
static NSString * const UHMessageTypeNps = @"nps";
static NSString * const UHMessageTypeNpsFeedback = @"nps_feedback";


static NSString * const UHMessageClickClose = @"close";
static NSString * const UHMessageClickRate = @"rate";
static NSString * const UHMessageClickFeedback = @"feedback";
static NSString * const UHMessageClickUri = @"uri";
static NSString * const UHMessageClickAction = @"action";
static NSString * const UHMessageClickSurvey = @"survey";

@class UHMessageMetaButton;
@class UHMessageMetaImage;

@interface UHMessageMeta : JSONModel

@property (nonatomic, strong) NSString * displayType;
@property (nonatomic, strong) NSString * body;
@property (nonatomic, strong) UHMessageMetaButton * button1;
@property (nonatomic, strong) UHMessageMetaButton * button2;

// used by NPS prompts
@property (nonatomic, strong) NSString * feedback_body;
@property (nonatomic, strong) NSString * feedback;
@property (nonatomic, strong) NSString * least;
@property (nonatomic, strong) NSString * most;

-(NSDictionary *) toQueryParams;

@end

typedef void(^UHMessageMetaButtonClickHandler)();

@interface UHMessageMetaButton : JSONModel

@property (nonatomic, strong) NSString * title;
@property (nonatomic, strong) NSString * click;
@property (nonatomic, strong) NSString * uri;
@property (nonatomic, strong) NSString * survey;
@property (nonatomic, strong) NSString * survey_title;
@property (nonatomic, strong) NSString * payload;
@property (nonatomic, strong) UHMessageMetaImage * image;

@property (nonatomic, copy) UHMessageMetaButtonClickHandler clickHandler;

@end

@interface UHMessageMetaImage : JSONModel

@property (nonatomic, strong) NSString * url;
@property (nonatomic, strong) NSNumber * height;
@property (nonatomic, strong) NSNumber * width;

@end
