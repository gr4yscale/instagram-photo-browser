//
//  TPPhotoCollectionViewCell.m
//  instagram-photo-browser
//
//  Created by Tyler Powers on 11/5/13.
//  Copyright (c) 2013 Tyler Powers. All rights reserved.
//

#import "TPPhotoCollectionViewCell.h"
#import "TPCardViewButton.h"
#import "TPConstants.h"

@interface TPPhotoCollectionViewCell ()

@property (nonatomic, strong) TPCardViewButton *commentButton;
@property (nonatomic, strong) TPCardViewButton *likeButton;
@property (nonatomic, strong) TPCardViewButton *shareButton;

- (void)setupSubviews;
- (void)setupButtons;
- (void)setupStaticConstraints;

@end


@implementation TPPhotoCollectionViewCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor blueColor];
        self.fetchImages = YES;
        
        [self setupSubviews];
        [self setupStaticConstraints];
    }
    return self;
}


- (void)setupSubviews
{
    self.userInteractionEnabled = YES;

    UIView *cardView = [[UIView alloc] init];
    cardView.backgroundColor = [UIColor whiteColor];
    cardView.layer.cornerRadius = 6.0;
    cardView.clipsToBounds = NO;
    cardView.layer.shadowColor = [[UIColor blackColor] CGColor];
    cardView.layer.shadowOffset = CGSizeMake(0,2);
    cardView.layer.shadowOpacity = 0.8;
    cardView.userInteractionEnabled = YES;
    [self.contentView addSubview:cardView];
    
    UILabel *captionLabel = [[UILabel alloc] init];
//    captionLabel.backgroundColor = [UIColor redColor];
    captionLabel.preferredMaxLayoutWidth = 284.0;
    captionLabel.numberOfLines = 3;
    captionLabel.font = kFontTitle;
    captionLabel.textColor = kTextColorPrimary;
    [cardView addSubview:captionLabel];
    
    UIImageView *userProfilePicImageView = [[UIImageView alloc] init];
    userProfilePicImageView.backgroundColor = [UIColor purpleColor];
    userProfilePicImageView.layer.cornerRadius = 2.0;
    [cardView addSubview:userProfilePicImageView];

    UILabel *usernameLabel = [[UILabel alloc] init];
//    usernameLabel.backgroundColor = [UIColor greenColor];
    usernameLabel.font = kFontHeading;
    [cardView addSubview:usernameLabel];
    
    UILabel *userFullNameLabel = [[UILabel alloc] init];
//    userFullNameLabel.backgroundColor = [UIColor purpleColor];
    userFullNameLabel.font = kFontTitle;
    userFullNameLabel.textColor = kTextColorSecondary;
    [cardView addSubview:userFullNameLabel];
    
    UIImageView *photoImageView = [[UIImageView alloc] init];
    photoImageView.backgroundColor = [UIColor greenColor];
    photoImageView.layer.cornerRadius = 2.0;
    photoImageView.clipsToBounds = NO;
    photoImageView.layer.shadowColor = [[UIColor blackColor] CGColor];
    photoImageView.layer.shadowOffset = CGSizeMake(0,2);
    photoImageView.layer.shadowOpacity = 0.6;
    photoImageView.layer.rasterizationScale = [[UIScreen mainScreen] scale]; // cache a bitmap of the layer so we're not redrawing shadows; improved performance according to Core Graphics instrument
    photoImageView.layer.shouldRasterize = YES;
    photoImageView.contentMode = UIViewContentModeScaleAspectFill;
    
    [self.contentView addSubview:photoImageView];
    
    UILabel *likesCountLabel = [[UILabel alloc] init];
//    likesCountLabel.backgroundColor = [UIColor redColor];
    likesCountLabel.font = kFontSubtitle;
    likesCountLabel.textColor = kTextColorSecondary;
    [cardView addSubview:likesCountLabel];
    
    UILabel *commentsCountLabel = [[UILabel alloc] init];
//    commentsCountLabel.backgroundColor = [UIColor redColor];
    commentsCountLabel.font = kFontSubtitle;
    commentsCountLabel.textColor = kTextColorSecondary;
    [cardView addSubview:commentsCountLabel];
    
    self.cardView = cardView;
    self.captionLabel = captionLabel;
    self.userProfilePicImageView = userProfilePicImageView;
    self.usernameLabel = usernameLabel;
    self.userFullNameLabel = userFullNameLabel;
    self.photoImageView = photoImageView;
    self.likesCountLabel = likesCountLabel;
    self.commentsCountLabel = commentsCountLabel;
    
    [self setupButtons];
}



- (void)setupButtons
{
    TPCardViewButton *commentButton = [[TPCardViewButton alloc] initWithSide:TPCardViewButtonSideLeft title:@"Comment"];
    
    UIImage *commentButtonUnselectedImage = [UIImage imageNamed:@"comment-unselected"];
    UIImage *commentButtonSelectedImage = [UIImage imageNamed:@"comment-selected"];
    
    [commentButton setImage:commentButtonUnselectedImage forState:UIControlStateNormal];
    [commentButton setImage:commentButtonSelectedImage forState:UIControlStateSelected];
    [commentButton setImage:commentButtonSelectedImage forState:UIControlStateHighlighted];
    
    [commentButton setImageEdgeInsets:UIEdgeInsetsMake(2.0, 0, 0, 0)];
    
    [self.cardView addSubview:commentButton];
    
    
    TPCardViewButton *likeButton = [[TPCardViewButton alloc] initWithSide:TPCardViewButtonSideMiddle title:@"Like"];
    
    UIImage *likeButtonUnselectedImage = [UIImage imageNamed:@"like-unselected"];
    UIImage *likeButtonSelectedImage = [UIImage imageNamed:@"like-selected"];
    
    [likeButton setImage:likeButtonUnselectedImage forState:UIControlStateNormal];
    [likeButton setImage:likeButtonSelectedImage forState:UIControlStateSelected];
    [likeButton setImage:likeButtonSelectedImage forState:UIControlStateHighlighted];
    
    [likeButton setImageEdgeInsets:UIEdgeInsetsMake(0.0, -4.0, 0, 0)];
    [likeButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 4.0, 0, 0)];
    
    [self.cardView addSubview:likeButton];
    
    TPCardViewButton *shareButton = [[TPCardViewButton alloc] initWithSide:TPCardViewButtonSideRight title:@"Share"];
    
    UIImage *shareButtonUnselectedImage = [UIImage imageNamed:@"share-unselected"];
    UIImage *shareButtonSelectedImage = [UIImage imageNamed:@"share-selected"];
    
    [shareButton setImage:shareButtonUnselectedImage forState:UIControlStateNormal];
    [shareButton setImage:shareButtonSelectedImage forState:UIControlStateSelected];
    [shareButton setImage:shareButtonSelectedImage forState:UIControlStateHighlighted];

    [shareButton setImageEdgeInsets:UIEdgeInsetsMake(-2.0, 0, 0, 2.0)];
    [shareButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 4.0, 0, 0)];
    
    [self.cardView addSubview:shareButton];
    
    self.commentButton = commentButton;
    self.likeButton = likeButton;
    self.shareButton = shareButton;
}


// Apple says to add constraints for any custom UIVIew in updateConstraints and call [super updateConstraints] at the end of the implementation,
// But for constraints that are static and don't need to be re-added or updated, that requires keeping extra state that seems like needless complexity
// Inspired by the blog post referenced below, I setup static constraints from init, and any constraints that are updated conditionally can go in updateConstraints.
// http://keighl.com/post/welcome-to-auto-layout/
// https://developer.apple.com/library/ios/documentation/UIKit/Reference/UIView_Class/UIView/UIView.html#//apple_ref/occ/instm/UIView/updateConstraints

- (void)setupStaticConstraints
{
    NSDictionary *views = @{@"cardView" : self.cardView,
                            @"captionLabel" : self.captionLabel,
                            @"userProfilePicImageView" : self.userProfilePicImageView,
                            @"usernameLabel" : self.usernameLabel,
                            @"userFullNameLabel" : self.userFullNameLabel,
                            @"photoImageView" : self.photoImageView,
                            @"commentButton" : self.commentButton,
                            @"likeButton" : self.likeButton,
                            @"shareButton" : self.shareButton,
                            @"commentsCountLabel" : self.commentsCountLabel,
                            @"likesCountLabel" : self.likesCountLabel
                            };
    
    NSDictionary *metrics = @{@"spacing": @6,
                              @"profilePictureWidthAndHeight": @50,
                              @"buttonRowHeight" : @42
                              };
    
    for (UIView *view in [views allValues]) {
        [view setTranslatesAutoresizingMaskIntoConstraints:NO];
    }
    
    // horizontals
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-12-[cardView]-12-|"
                                                                 options:0
                                                                 metrics:metrics
                                                                   views:views]];
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(spacing)-[userProfilePicImageView(profilePictureWidthAndHeight)]"
                                                                 options:0
                                                                 metrics:metrics
                                                                   views:views]];
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(spacing)-[userProfilePicImageView]-(spacing)-[usernameLabel]-(spacing)-|"
                                                                 options:0
                                                                 metrics:metrics
                                                                   views:views]];
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(spacing)-[userProfilePicImageView]-(spacing)-[userFullNameLabel]-(spacing)-|"
                                                                 options:0
                                                                 metrics:metrics
                                                                   views:views]];

    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(spacing)-[captionLabel]-(spacing)-|"
                                                                 options:0
                                                                 metrics:metrics
                                                                   views:views]];
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(spacing)-[photoImageView(308)]-(spacing)-|"
                                                                 options:0
                                                                 metrics:metrics
                                                                   views:views]];
        
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[commentButton(==115)]-0-[likeButton]-0-[shareButton(==95)]|"
                                                                 options:0
                                                                 metrics:metrics
                                                                   views:views]];
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(spacing)-[commentsCountLabel]-(spacing)-[likesCountLabel]"
                                                                 options:0
                                                                 metrics:metrics
                                                                   views:views]];
    // verticals
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(spacing)-[cardView]-(spacing)-|"
                                                                 options:0
                                                                 metrics:metrics
                                                                   views:views]];
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(spacing)-[userProfilePicImageView(profilePictureWidthAndHeight)]"
                                                                 options:0
                                                                 metrics:metrics
                                                                   views:views]];
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(spacing)-[usernameLabel(25)]-0-[userFullNameLabel(25)]-(spacing)-[captionLabel]-(spacing)-[photoImageView(==308)]-(spacing)-[commentsCountLabel]-(spacing)-[commentButton(buttonRowHeight)]|"
                                                                 options:0
                                                                 metrics:metrics
                                                                   views:views]];

    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[photoImageView]-(spacing)-[commentsCountLabel]-(spacing)-[likeButton(buttonRowHeight)]|"
                                                                 options:0
                                                                 metrics:metrics
                                                                   views:views]];

    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[photoImageView]-(spacing)-[commentsCountLabel]-(spacing)-[shareButton(buttonRowHeight)]|"
                                                                 options:0
                                                                 metrics:metrics
                                                                   views:views]];
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[likesCountLabel]-(spacing)-[likeButton]"
                                                                 options:0
                                                                 metrics:metrics
                                                                   views:views]];
}

- (void)prepareForReuse
{
    self.usernameLabel.text = nil;
    self.userFullNameLabel.text = nil;
    self.captionLabel.text = nil;
    self.photoImageView.image = nil;
    self.commentsCountLabel.text = nil;
    self.likesCountLabel.text = nil;
}
@end
