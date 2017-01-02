/*
 * Copyright (c) 2015 - present, Cullaboration Media, LLC.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import "UHWebView.h"
#import "UserHook.h"
#import "UHRequest.h"
#import <Photos/Photos.h>

@interface UHWebView()

@property (nonatomic, strong) UIImagePickerController * imagePicker;
@property (nonatomic, strong) NSData * attachment;
@property (nonatomic, strong) NSString * attachmentMimeType;
@property (nonatomic, strong) NSString * attachmentFieldName;
@property (nonatomic, strong) UIWebView * webView;

@end

@implementation UHWebView

-(id) init {
    self = [super init];
    
    self.webView = [[UIWebView alloc] init];
    
    self.webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

    
    [self addSubview:self.webView];
    
    self.webView.delegate = self;
    self.webView.dataDetectorTypes = UIDataDetectorTypeNone;
    
    return self;
}

-(void) setWebViewDelegate:(id <UIWebViewDelegate>) delegate {
    self.webView.delegate = delegate;
}

- (void)loadRequest:(NSURLRequest *)request {
    [self.webView loadRequest:request];
}


- (void)loadHTMLString:(NSString *)string baseURL:(NSURL *)baseURL {
    [self.webView loadHTMLString:string baseURL:baseURL];
}

-(void) setScrollable:(BOOL) scrollable {
    self.webView.scrollView.scrollEnabled = scrollable;
}

-(void) setBackgroundTransparent {
    self.webView.backgroundColor = [UIColor clearColor];
    self.webView.opaque = NO;
}

-(BOOL) webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    
    if ([[request.URL absoluteString] hasPrefix:UH_HOST_URL]) {
        
        if (navigationType == UIWebViewNavigationTypeFormSubmitted && self.attachment) {
            
            // create multi-part form upload
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                dispatch_async(dispatch_get_main_queue(), ^{
                    UHRequest* urequest = [UHRequest requestFromRequest:request];
                    
                    NSString * boundary = @"---------------------------UserHookMultiPart234234252353";
                    // set content type
                    NSString * contentType = [NSString stringWithFormat:@"multipart/form-data;boundary=%@", boundary];
                    [urequest setValue:contentType forHTTPHeaderField:@"Content-Type"];
                    
                    NSMutableData * body = [NSMutableData data];
                    
                    // add form fields
                    if (request.HTTPBody) {
                        NSDictionary * params = [UHRequest dataParamsToDictionary:request.HTTPBody];
                        
                        for (NSString * key in params) {
                            [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
                            [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", key] dataUsingEncoding:NSUTF8StringEncoding]];
                            [body appendData:[[NSString stringWithFormat:@"%@\r\n", [params objectForKey:key]] dataUsingEncoding:NSUTF8StringEncoding]];

                        }
                    }
                    
                    // add attachment
                    if (self.attachment && self.attachmentFieldName) {
                        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
                        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"image.jpg\"\r\n", self.attachmentFieldName] dataUsingEncoding:NSUTF8StringEncoding]];
                        [body appendData:[[NSString stringWithFormat:@"Content-Type: %@\r\n\r\n",self.attachmentMimeType] dataUsingEncoding:NSUTF8StringEncoding]];
                        [body appendData:self.attachment];
                        [body appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
                        
                    }
                    
                    // end content
                    [body appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];

                    urequest.HTTPBody = body;
                    NSString * contentLength = [NSString stringWithFormat:@"%lu", (unsigned long)[body length]];
                    [urequest setValue:contentLength forHTTPHeaderField:@"Content-Length"];
                    
                    // reload the new request
                    [self.webView loadRequest:urequest];
                });
            });
            
            return NO;
        }
        
        // see if request has the user hook headers
        else if (![UHRequest hasUserHookHeaders:request]) {
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                dispatch_async(dispatch_get_main_queue(), ^{
                    UHRequest* urequest = [UHRequest requestFromRequest:request];
                    
                    // reload the new request with the user hook headers
                    [self.webView loadRequest:urequest];
                });
            });
            
            return NO;
        }
    }
    else if ([[request.URL scheme] isEqualToString:UH_PROTOCOL]) {
        
        if ([[request.URL host] isEqualToString:@"imagepicker"]) {
            // open image picker
            
            self.imagePicker = [[UIImagePickerController alloc] init];
            self.imagePicker.delegate = self;
            self.imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            
            UIViewController * topController = [UserHook topViewController];
            [topController presentViewController:self.imagePicker animated:YES completion:nil];
            
            // add field name for the attachment
            NSString * fieldName = [request.URL path];
            if ([fieldName hasPrefix:@"/"]) {
                fieldName = [fieldName substringFromIndex:1];
            }
            self.attachmentFieldName = fieldName;
            
            return NO;
        }
        else if ([[request.URL host] isEqualToString:@"imagepicker_reset"]) {
            
            self.attachmentFieldName = nil;
            self.attachment = nil;
            
            // reset file picker on webpage
            [self.webView stringByEvaluatingJavaScriptFromString:@"javascript:resetUpload();"];
            
        }
        
    }
    
    
    return YES;

    
}



#pragma mark - image picker
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    
    PHFetchResult * result = [PHAsset fetchAssetsWithALAssetURLs:@[[info valueForKey:UIImagePickerControllerReferenceURL]] options:nil];
   
    PHAsset * asset = [result lastObject];
    
    PHImageRequestOptions * options = [[PHImageRequestOptions alloc] init];
    options.resizeMode = PHImageRequestOptionsResizeModeExact;
    options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
    
    
    // get image and downsize a bit
    [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:CGSizeMake(600, 800) contentMode:PHImageContentModeAspectFit options:options resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
    
        self.attachment = UIImageJPEGRepresentation(result, .6);
        self.attachmentMimeType = @"image/jpeg";
        
        
        // send message to webview
        [self.webView stringByEvaluatingJavaScriptFromString:@"javascript:markUploadAttached();"];
    }];
    
    [picker dismissViewControllerAnimated:YES completion:nil];
    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    // close picker
    [picker dismissViewControllerAnimated:YES completion:nil];
    
}

@end
