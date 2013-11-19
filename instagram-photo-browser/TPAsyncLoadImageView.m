//
//  TPAsyncLoadImageView.m
//  instagram-photo-browser
//
//  Created by Tyler Powers on 11/17/13.
//  Copyright (c) 2013 Tyler Powers. All rights reserved.
//

#import "TPAsyncLoadImageView.h"
#import "TPAssetManager.h"


@interface TPAsyncLoadImageView ()

@property (nonatomic, strong) UIImageView *placeholderImageView;

@end


@implementation TPAsyncLoadImageView


- (id)init
{
    self = [super init];
    if (self) {
        self.backgroundColor = kPrimaryBackgroundColor;
        self.opaque = YES;
    }
    return self;
}

- (void)setImageWithURL:(NSURL *)URL {
    [self setImageWithURL:URL placeHolder:NO completion:nil failBlock:nil];
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
                    [self.placeholderImageView.layer removeAllAnimations];
                    self.placeholderImageView.hidden = YES;
                    self.image = image;
                });
            });
            return;
        }
    }
    
    if (placeholder) {
        [self setupPlaceholder];
    }
    
    NSURLSessionDownloadTask *downloadTask = [[TPAssetManager shared] downloadAssetWithURL:URL
                                                                                completion:^(NSURL *localURL) {
                                                                                    
                                                                                    UIImage *image = [UIImage imageWithContentsOfFile:[localURL path]];
                                                                                    
                                                                                    if (image && [self.imageURL.absoluteString isEqualToString:[URL absoluteString]]) {
                                                                                        
                                                                                        dispatch_async(dispatch_get_main_queue(), ^{
                                                                                            [self.placeholderImageView.layer removeAllAnimations];
                                                                                            self.placeholderImageView.hidden = YES;
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


- (void)setupPlaceholder
{
    if (!_placeholderImageView) {
        UIImage *loadingIndicatorImage = [UIImage imageNamed:@"loading-indicator"];
        _placeholderImageView = [[UIImageView alloc] initWithImage:loadingIndicatorImage];
        _placeholderImageView.contentMode = UIViewContentModeCenter;
        [_placeholderImageView setTranslatesAutoresizingMaskIntoConstraints:NO];
        
        [self addSubview:_placeholderImageView];
        
        NSDictionary *views = @{@"placeholderImageView" : _placeholderImageView};
        
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[placeholderImageView]-|"
                                                                     options:NSLayoutFormatAlignAllCenterY
                                                                     metrics:nil
                                                                       views:views]];
        
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[placeholderImageView]-|"
                                                                     options:NSLayoutFormatAlignAllCenterX
                                                                     metrics:nil
                                                                       views:views]];
    }
    
    _placeholderImageView.hidden = NO;
    
    CABasicAnimation* rotationAnimation;
    rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.toValue = [NSNumber numberWithFloat: M_PI];
    rotationAnimation.duration = 0;
    rotationAnimation.cumulative = YES;
    rotationAnimation.repeatCount = HUGE_VALF;
    
    [_placeholderImageView.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
}


@end
