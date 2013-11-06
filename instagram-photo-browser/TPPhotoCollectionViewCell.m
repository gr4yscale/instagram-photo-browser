//
//  TPPhotoCollectionViewCell.m
//  instagram-photo-browser
//
//  Created by Tyler Powers on 11/5/13.
//  Copyright (c) 2013 Tyler Powers. All rights reserved.
//

#import "TPPhotoCollectionViewCell.h"

@interface TPPhotoCollectionViewCell ()

@end


@implementation TPPhotoCollectionViewCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor blueColor];
        [self setup];
    }
    return self;
}


- (void)setup
{
    UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 10)];
    [self addSubview:nameLabel];
    self.nameLabel = nameLabel;
}

@end
