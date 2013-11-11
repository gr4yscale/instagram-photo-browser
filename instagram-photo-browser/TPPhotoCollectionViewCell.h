//
//  TPPhotoCollectionViewCell.h
//  instagram-photo-browser
//
//  Created by Tyler Powers on 11/5/13.
//  Copyright (c) 2013 Tyler Powers. All rights reserved.
//

@interface TPPhotoCollectionViewCell : UICollectionViewCell

@property (nonatomic, strong) UIView *cardView;
@property (nonatomic, strong) UIImageView *userProfilePicImageView;
@property (nonatomic, strong) UILabel *usernameLabel;
@property (nonatomic, strong) UILabel *userFullNameLabel;
@property (nonatomic, strong) UIImageView *photoImageView;
@property (nonatomic, strong) UILabel *captionLabel;
@property (nonatomic, strong) UILabel *likesCountLabel;
@property (nonatomic, strong) UILabel *commentsCountLabel;

@end
