//
//  UIImageView+AsyncLoad.m
//  instagram-photo-browser
//
//  Created by Tyler Powers on 11/11/13.
//  Copyright (c) 2013 Tyler Powers. All rights reserved.
//

// This category was inpired in part by the popular UIImageView+AFNetworking category as well as this article:
// http://khanlou.com/2012/08/asynchronous-downloaded-images-with-caching/

// This implementation doesn't handle canceling any pending download operations if you try to set the imageWithURL again before the first operation completes.
// Instead, we go ahead and download the file (it's likely we'll need it anyways) and we check to see if the URL has been changed since the block initially begun execution
// Essentially we block a race condition with a simple check on the URL, but a cleaner/less naive implementation would be to identify the specific operation associated
// with the imageView and cancel the NSURLConnection request.

#import "UIImageView+AsyncLoad.h"
#import <objc/runtime.h>

static char TPImageURLKey;

@implementation UIImageView (AsyncLoad)

+ (NSOperationQueue *)tp_sharedOperationQueue {
    static NSOperationQueue *tp_sharedOperationQueue = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        tp_sharedOperationQueue = [[NSOperationQueue alloc] init];
        tp_sharedOperationQueue.maxConcurrentOperationCount = NSOperationQueueDefaultMaxConcurrentOperationCount;
        // Apparently there's a huge debate on what the max concurrent ops should be to best optimize for your current network conditions
        // See: https://github.com/AFNetworking/AFNetworking/issues/953
    });
    
    return tp_sharedOperationQueue;
}


- (void)tp_setImageWithURL:(NSURL *)URL
{
    [self tp_setImageWithURL:URL placeHolder:nil failBlock:nil];
}


- (void)tp_setImageWithURL:(NSURL *)URL
            placeHolder:(UIImage *)placeholder
              failBlock:(void (^)(NSError *))failBlock
{
    self.tp_imageURL = URL;
    self.image = placeholder;
    
    // if we don't have it on disk, go fetch from network:
    
    __block NSError *error = nil;
    
    NSBlockOperation *blockOp = [NSBlockOperation blockOperationWithBlock:^{
        
        NSURLRequest *request = [NSURLRequest requestWithURL:URL];
        NSURLResponse *response = nil;
        
        NSData *data = [NSURLConnection sendSynchronousRequest:request
                                             returningResponse:&response
                                                         error:&error];
        UIImage *image = [UIImage imageWithData:data];
        
        // ensure we have an image from the data and more importantly that the imageView reference we have now is actually
        // the one we want to set the image to by verifying the URL property (associated object) is the same as the one the block captured originally
        
        if (image && [self.tp_imageURL.absoluteString isEqualToString:URL.absoluteString]) {
            
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                self.image = image;
            }];
        }
    }];
    
    blockOp.completionBlock = ^{
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            if (error && failBlock) {
                failBlock(error);
            }
        }];
    };
    
    [[[self class] tp_sharedOperationQueue] addOperation:blockOp];
}


- (void)tp_setImageURL:(NSURL *)URL
{
    objc_setAssociatedObject(self, &TPImageURLKey, URL, OBJC_ASSOCIATION_COPY);
}


- (NSURL *)tp_imageURL
{
    return objc_getAssociatedObject(self, &TPImageURLKey);
}


@end
