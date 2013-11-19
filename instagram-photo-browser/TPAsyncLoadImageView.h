//
//  TPAsyncLoadImageView.h
//  instagram-photo-browser
//
//  Created by Tyler Powers on 11/17/13.
//  Copyright (c) 2013 Tyler Powers. All rights reserved.
//

@interface TPAsyncLoadImageView : UIImageView

@property (nonatomic, strong) UIImageView *placeholderImageView;
@property (nonatomic, copy) NSURL *imageURL;
@property (nonatomic, weak) NSURLSessionDownloadTask *downloadTask;

- (void)setImageWithURL:(NSURL *)URL;

- (void)setImageWithURL:(NSURL *)URL
            placeHolder:(BOOL)placeholder
             completion:(void (^)(void))completion
              failBlock:(void (^)(NSError *error))failBlock;

@end
