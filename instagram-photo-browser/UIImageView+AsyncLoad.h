//
//  UIImageView+AsyncLoad.h
//  instagram-photo-browser
//
//  Created by Tyler Powers on 11/11/13.
//  Copyright (c) 2013 Tyler Powers. All rights reserved.
//

@interface UIImageView (AsyncLoad)

@property (nonatomic, copy, setter = tp_setImageURL:) NSURL *tp_imageURL;

+ (NSOperationQueue *)tp_sharedOperationQueue;

- (void)tp_setImageWithURL:(NSURL *)URL;

- (void)tp_setImageWithURL:(NSURL *)URL
            placeHolder:(UIImage *)placeholder
              failBlock:(void (^)(NSError *))failBlock;

@end
