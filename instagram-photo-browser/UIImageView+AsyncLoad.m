//
//  UIImageView+AsyncLoad.m
//  instagram-photo-browser
//
//  Created by Tyler Powers on 11/11/13.
//  Copyright (c) 2013 Tyler Powers. All rights reserved.
//

#import "UIImageView+AsyncLoad.h"

#import <objc/runtime.h>


static char TPImageURLKey;

@implementation UIImageView (AsyncLoad)


- (void)setImageURL:(NSURL *)URL
{
    objc_setAssociatedObject(self, &TPImageURLKey, URL, OBJC_ASSOCIATION_COPY);
}


- (NSURL *)imageURL
{
    return objc_getAssociatedObject(self, &TPImageURLKey);
}


@end
