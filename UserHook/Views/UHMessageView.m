/*
 * Copyright (c) 2015 - present, Cullaboration Media, LLC.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import "UHMessageView.h"
#import "UserHook.h"
#import "UHWebView.h"
#import "UHRequest.h"
#import "UHMessageTemplate.h"


@interface UHMessageView()

@property (strong, nonatomic) UIView *overlay;
@property (strong, nonatomic) UIView * contentView;
@property (strong, nonatomic) NSLayoutConstraint *contentHeight;
@property (strong, nonatomic) NSLayoutConstraint *contentWidth;
@property (strong, nonatomic) UHMessageMeta * meta;
@property (strong, nonatomic) UHHookPoint * hookpoint;
@property (assign, nonatomic) BOOL contentLoaded;
@property (assign, nonatomic) BOOL showAfterLoad;

@end

@implementation UHMessageView

-(id) init {
    self = [super init];
    
    // create background overlay
    self.overlay = [[UIView alloc] init];
    self.overlay.backgroundColor = [UIColor blackColor];
    self.overlay.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:self.overlay];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.overlay attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1.0 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.overlay attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.overlay attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.overlay attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeRight multiplier:1.0 constant:0]];
    
    _overlay.alpha = 0;
    
    
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideDialog)];
    [_overlay addGestureRecognizer:tap];
    
    return self;
}

+(UHMessageView *) createViewForMeta:(UHMessageMeta *) meta {
    
    UHMessageView * view = [[UHMessageView alloc] init];
    
    view.meta = meta;
    
    
    NSMutableDictionary * params = [NSMutableDictionary dictionary];
    [params setObject:[meta toJSONString] forKey:@"meta"];
    
    [view loadMessage:params];
    
    
    return view;
}

+(UHMessageView *) createViewForHookPoint:(UHHookPointMessage *) hookpoint {
    
    UHMessageView * view = [[UHMessageView alloc] init];
    view.hookpoint = hookpoint;
    view.meta = hookpoint.meta;
    
    NSMutableDictionary * params = [NSMutableDictionary dictionary];
    [params setValue:hookpoint.id forKey:@"id"];
    
    [view loadMessage:params];
    
    return view;
}


-(void)awakeFromNib {
    _overlay.alpha = 0;
    _contentView.alpha = 0;
    
    
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideDialog)];
    [_overlay addGestureRecognizer:tap];
    
}


/*
 Make request to server where the content of the message will be rendered into html.
 We make this request as a network call, instead of directly in the webview, to make sure the content
 is loaded completely before trying to display the message view to the user.
 */

-(void) loadMessage:(NSDictionary *) params {
    
    NSURLRequest * request;
    
    if ([self.meta.displayType isEqualToString:UHMessageTypeImage]) {
        if (self.meta.button1.image.url) {
            
            request = [NSURLRequest requestWithURL:[NSURL URLWithString:self.meta.button1.image.url]];
        }
        else {
            // don't show image prompt if the image is missing
            return;
        }
    }
    else if ([[UHMessageTemplate sharedInstance] hasTemplate:self.meta.displayType]) {
        
        [self createWebView];
        NSString * htmlContent = [[UHMessageTemplate sharedInstance] renderTemplate:self.meta];
        
        [(UIWebView *)self.contentView loadHTMLString:htmlContent baseURL:[NSURL URLWithString:UH_HOST_URL]];

        self.contentLoaded = YES;
        
       
        return;
        
    }
    else {
        request = [UHRequest postRequestWithPath:[NSString stringWithFormat:@"%@message", UH_HOST_URL] parameters:params];
    }
    
    
    
    NSURLSessionTask * task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
        
        if (error) {
            UH_LOG(@"error loading message view from server: %@", [error localizedDescription]);
            [self hideDialog];
            return;
        }
        else if (httpResponse.statusCode == 404 || httpResponse.statusCode == 500) {
            UH_LOG(@"server responded with status code: %li", (long)httpResponse.statusCode);
            [self hideDialog];
            return;
        }
        else if (!data) {
            UH_LOG(@"server did not return any data");
            [self hideDialog];
            return;
        }
        
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([self.meta.displayType isEqualToString:UHMessageTypeImage]) {
                
                
                [self createImageView];
                
                
                // set image content
                UIImageView * imageView = (UIImageView *)self.contentView;
                
                UIImage * image = [UIImage imageWithData:data];
                
                [imageView setImage:image];
                imageView.contentMode = UIViewContentModeScaleAspectFit;
                
                float height = [self.meta.button1.image.height floatValue];
                float width = [self.meta.button1.image.width floatValue];
                float aspect = height / width;
                
                float heightGutter = 40;
                float widthGutter = 40;
                
                float screenSpaceHeight = self.frame.size.height - heightGutter * 2;
                float screenSpaceWidth = self.frame.size.width - widthGutter * 2;
                
                if (height > screenSpaceHeight) {
                    height = screenSpaceHeight;
                    width = height / aspect;
                }
                
                if (width > screenSpaceWidth) {
                    width = screenSpaceWidth;
                    height = width * aspect;
                }
                
                self.contentHeight.constant = height;
                self.contentWidth.constant = width;
                
                [self layoutIfNeeded];
                
                self.contentLoaded = YES;
                
                // we were waiting for the content to load, now that is has, show the dialog
                if (self.showAfterLoad) {
                    [self showDialog];
                }
                
            }
            else {
                
                [self createWebView];
                NSString * htmlContent = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                
                [(UIWebView *)self.contentView loadHTMLString:htmlContent baseURL:[NSURL URLWithString:UH_HOST_URL]];
                
                self.contentLoaded = YES;
                
                
            }
            
            
        });
        
        
        
        
    }];
    
    [task resume];
}

-(void) createWebView {
    
    
    
    // create webview for message content
    UIWebView * webView = [[UHWebView alloc] init];
    webView.delegate = self;
    webView.backgroundColor = [UIColor clearColor];
    webView.opaque = NO;
    
    self.contentView = webView;
    
    self.contentView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:self.contentView];
    
    self.contentWidth = [NSLayoutConstraint constraintWithItem:self.contentView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeWidth multiplier:1.0 constant:280];
    // start with a small height so we can calculate the height of the content using the webview scroll size
    self.contentHeight = [NSLayoutConstraint constraintWithItem:self.contentView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeHeight multiplier:1.0 constant:10];
    [self addConstraint:self.contentWidth];
    [self addConstraint:self.contentHeight];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.contentView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.contentView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0]];
    
    webView.scrollView.scrollEnabled = NO;
    
    _contentView.alpha = 0;
    
    
    
}

-(void) createImageView {
    
    
    
    UIImageView * imageView = [[UIImageView alloc] init];
    self.contentView = imageView;
    
    imageView.backgroundColor = [UIColor redColor];
    imageView.userInteractionEnabled = YES;
    
    self.contentView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:self.contentView];
    
    self.contentWidth = [NSLayoutConstraint constraintWithItem:self.contentView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeWidth multiplier:1.0 constant:100];
    // start with a small height so we can calculate the height of the content using the webview scroll size
    self.contentHeight = [NSLayoutConstraint constraintWithItem:self.contentView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeHeight multiplier:1.0 constant:100];
    [self addConstraint:self.contentWidth];
    [self addConstraint:self.contentHeight];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.contentView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.contentView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0]];
    
    
    // add click action to image
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickedImage)];
    [imageView addGestureRecognizer:tap];
    
    _contentView.alpha = 0;
    
    
    
}


-(void)showDialog {
    
    if (self.contentLoaded) {
        
        _overlay.alpha = 0;
        _contentView.alpha = 0;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [UIView animateWithDuration:0.5 animations:^{
                _overlay.alpha = 0.5;
                _contentView.alpha = 1.0;
                
            } completion:^(BOOL finished) {
                
                if (self.hookpoint) {
                    [UserHook trackHookPointDisplay:self.hookpoint];
                }
            }];
            
        });
        
        
    }
    else {
        self.showAfterLoad = YES;
    }
    
}

-(void)hideDialog {
    
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.5 animations:^{
            _overlay.alpha = 0.0;
            _contentView.alpha = 0.0;
            
        } completion:^(BOOL finished) {
            [self removeFromSuperview];
        }];
        
    });
    
    
}



-(void) webViewDidFinishLoad:(UIWebView *)webView {
    
    _contentHeight.constant = webView.scrollView.contentSize.height;
    [self layoutIfNeeded];
    
    
    // disbale user selection
    [webView stringByEvaluatingJavaScriptFromString:@"document.documentElement.style.webkitUserSelect='none';"];
    // disable callout
    [webView stringByEvaluatingJavaScriptFromString:@"document.documentElement.style.webkitTouchCallout='none';" ];
    
    // we were waiting for the content to load, now that is has, show the dialog
    if (self.showAfterLoad) {
        [self showDialog];
    }
    
}

-(BOOL) webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    
    
    if ([[request.URL scheme] isEqualToString:UH_PROTOCOL]) {
        
        UH_LOG(@"user hook click: %@", [request.URL absoluteString]);
        
        if ([[request.URL host] isEqualToString:@"close"]) {
            [self hideDialog];
        }
        else {
            
            NSString * buttonName = [request.URL host];
            
            UHMessageMetaButton * button;
            if ([buttonName isEqualToString:@"button1"]) {
                button = self.meta.button1;
            }
            else if ([buttonName isEqualToString:@"button2"]) {
                button = self.meta.button2;
            }
            
            [self clickedButton:button];
        }
        
        return NO;
    }
    
    
    return YES;
}


-(void) clickedImage {
    
    [self clickedButton:self.meta.button1];
    
}

-(void) clickedButton:(UHMessageMetaButton *) button {
    
    if (button.clickHandler) {
        button.clickHandler();
    }
    else if ([button.click isEqualToString:UHMessageClickRate]) {
        [self handleRate];
    }
    else if ([button.click isEqualToString:UHMessageClickUri]) {
        [self handleUri:button];
    }
    else if ([button.click isEqualToString:UHMessageClickSurvey]) {
        [self handleSurvey:button];
    }
    else if ([button.click isEqualToString:UHMessageClickFeedback]) {
        [self handleFeedback:button];
    }
    else if ([button.click isEqualToString:UHMessageClickAction]) {
        [self handleAction:button];
    }
    
    if (self.hookpoint) {
        [UserHook trackHookPointInteraction:self.hookpoint];
    }
    
    [self hideDialog];
}


#pragma mark actions

-(void) handleRate {
    
    // lauch app rating
    [UserHook rateThisApp];
    
}

-(void) handleSurvey:(UHMessageMetaButton *) button {
    if (button.survey) {
        
        [UserHook displaySurvey:button.survey title:button.survey_title hookpointId:self.hookpoint.id];
        
    }
}

-(void) handleAction:(UHMessageMetaButton *) button {
    
    if (button.payload) {
        
        NSError * error;
        NSData * data = [button.payload dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary * payload = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
        if (error) {
            UH_LOG(@"error parsing message payload: %@", [error localizedDescription]);
        }
        
        [UserHook handlePayload:payload];
    }
}

-(void) handleUri:(UHMessageMetaButton *) button {
    
    if (button.uri) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:button.uri]];
    }
    
}

-(void) handleFeedback:(UHMessageMetaButton *) button {
    
    [UserHook displayFeedback];
}

@end
