//
//  TPPhotoCollectionViewCell.h
//  instagram-photo-browser
//
//  Created by Tyler Powers on 11/5/13.
//  Copyright (c) 2013 Tyler Powers. All rights reserved.
//

#import "TPAsyncLoadImageView.h"

@interface TPPhotoCollectionViewCell : UICollectionViewCell

@property (nonatomic, strong) UIView *cardView;
@property (nonatomic, strong) TPAsyncLoadImageView *profilePicImageView;
@property (nonatomic, strong) UILabel *usernameLabel;
@property (nonatomic, strong) UILabel *userFullNameLabel;
@property (nonatomic, strong) TPAsyncLoadImageView *photoImageView;
@property (nonatomic, strong) UILabel *captionLabel;
@property (nonatomic, strong) UILabel *likesCountLabel;
@property (nonatomic, strong) UILabel *commentsCountLabel;

@property (nonatomic, strong) NSString *link;
@property (nonatomic, assign) BOOL fetchImages;

@end
