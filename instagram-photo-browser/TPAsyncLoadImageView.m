//
//  TPAsyncLoadImageView.m
//  instagram-photo-browser
//
//  Created by Tyler Powers on 11/17/13.
//  Copyright (c) 2013 Tyler Powers. All rights reserved.
//

#import "TPAsyncLoadImageView.h"
#import "TPAssetManager.h"



@implementation TPAsyncLoadImageView


- (id)init
{
    self = [super init];
    if (self) {
        self.backgroundColor = kPhotoImageViewBGColor;
        self.opaque = YES;
    }
    return self;
}

- (void)setImageWithURL:(NSURL *)URL {
    [self setImageWithURL:URL placeHolder:nil completion:nil failBlock:nil];
}


- (void)setImageWithURL:(NSURL *)URL
            placeHolder:(BOOL)placeholder
             completion:(void (^)(void))completion
              failBlock:(void (^)(NSError *error))failBlock
{
    self.imageURL = URL;
    
    if (self.downloadTask) {
        [self.downloadTask cancel];
        self.downloadTask = nil;
    }
    
    NSURL *localURL = [[TPAssetManager shared] localURLForRemoteAssetURL:URL];
    
    @synchronized([TPAssetManager shared]) {
        if ([[NSFileManager defaultManager] fileExistsAtPath:[localURL path] isDirectory:NULL]) {
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                UIImage *image = [UIImage imageWithContentsOfFile:[localURL path]];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.image = image;
                });
            });
            return;
        }
    }
    
    NSURLSessionDownloadTask *downloadTask = [[TPAssetManager shared] downloadAssetWithURL:URL
                                                                                completion:^(NSURL *localURL) {
                                                                                    
                                                                                    UIImage *image = [UIImage imageWithContentsOfFile:[localURL path]];
                                                                                    
                                                                                    if (image && [self.imageURL.absoluteString isEqualToString:[URL absoluteString]]) {
                                                                                        
                                                                                        dispatch_async(dispatch_get_main_queue(), ^{
                                                                                            self.image = image;
                                                                                        });
                                                                                        if (completion) completion();
                                                                                    }
                                                                                    
                                                                                } failBlock:^(NSError *error) {
                                                                                    if (failBlock) {
                                                                                        failBlock(error);
                                                                                    }
                                                                                }];
    [downloadTask resume];
    self.downloadTask = downloadTask;
}




@end
