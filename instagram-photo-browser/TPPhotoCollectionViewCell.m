//
//  TPPhotoCollectionViewCell.m
//  instagram-photo-browser
//
//  Created by Tyler Powers on 11/5/13.
//  Copyright (c) 2013 Tyler Powers. All rights reserved.
//

#import "TPPhotoCollectionViewCell.h"
#import "TPConstants.h"
#import "UIFont+DynamicTypeEuphemia.h"

@interface TPPhotoCollectionViewCell ()

- (void)setupSubviews;
- (void)setupButtons;
- (void)setupStaticConstraints;
- (void)sharePressed:(id)sender;

@end


@implementation TPPhotoCollectionViewCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.opaque = NO;
        
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
    cardView.clipsToBounds = NO;
    cardView.userInteractionEnabled = YES;
    
    CALayer *cardViewLayer = cardView.layer;
    cardViewLayer.shadowColor = [[UIColor blackColor] CGColor];
    cardViewLayer.shadowOffset = CGSizeMake(0,2);
    cardViewLayer.shadowOpacity = 0.6;
    cardViewLayer.shadowRadius = 2.0;
    cardViewLayer.cornerRadius = 6.0;
    cardViewLayer.rasterizationScale = [[UIScreen mainScreen] scale]; // cache a bitmap of the layer so we're not redrawing shadows; improved performance according to Core Graphics instrument
    cardViewLayer.shouldRasterize = YES;
    
    [self.contentView addSubview:cardView];
    
    UILabel *captionLabel = [[UILabel alloc] init];
    captionLabel.preferredMaxLayoutWidth = 284.0; // un-hardcode this!
    captionLabel.numberOfLines = 3;
    captionLabel.textColor = kTextColorPrimary;
    [cardView addSubview:captionLabel];
    
    TPAsyncLoadImageView *profilePicImageView = [[TPAsyncLoadImageView alloc] init];
    profilePicImageView.backgroundColor = [UIColor clearColor];
    profilePicImageView.layer.cornerRadius = 2.0;
    [cardView addSubview:profilePicImageView];

    UILabel *usernameLabel = [[UILabel alloc] init];
    [cardView addSubview:usernameLabel];
    
    UILabel *userFullNameLabel = [[UILabel alloc] init];
    [cardView addSubview:userFullNameLabel];
    
    TPAsyncLoadImageView *photoImageView = [[TPAsyncLoadImageView alloc] init];
    photoImageView.contentMode = UIViewContentModeScaleAspectFill;
    photoImageView.clipsToBounds = NO;
    
    CALayer *photoImageViewLayer = photoImageView.layer;
    
    photoImageViewLayer.shadowColor = [[UIColor blackColor] CGColor];
    photoImageViewLayer.shadowOffset = CGSizeMake(0,1);
    photoImageViewLayer.shadowOpacity = 0.8;
    photoImageViewLayer.shadowRadius = 4.0;
    photoImageViewLayer.masksToBounds = NO;
    
    [self.contentView addSubview:photoImageView];
    
    UILabel *likesCountLabel = [[UILabel alloc] init];
    likesCountLabel.textColor = kTextColorSecondary;
    [cardView addSubview:likesCountLabel];
    
    UILabel *commentsCountLabel = [[UILabel alloc] init];
    commentsCountLabel.textColor = kTextColorSecondary;
    [cardView addSubview:commentsCountLabel];
    
    self.cardView = cardView;
    self.captionLabel = captionLabel;
    self.profilePicImageView = profilePicImageView;
    self.usernameLabel = usernameLabel;
    self.userFullNameLabel = userFullNameLabel;
    self.photoImageView = photoImageView;
    self.likesCountLabel = likesCountLabel;
    self.commentsCountLabel = commentsCountLabel;
    
    [self setupButtons];
}



- (void)setupButtons
{
    NSString *commentButtonTitle = NSLocalizedString(@"Comment", nil);
    TPCardViewButton *commentButton = [[TPCardViewButton alloc] initWithSide:TPCardViewButtonSideLeft title:commentButtonTitle];
    
    UIImage *commentButtonUnselectedImage = [UIImage imageNamed:kImageNameCommentUnselected];
    UIImage *commentButtonSelectedImage = [UIImage imageNamed:kImageNameCommentSelected];
    
    [commentButton setImage:commentButtonUnselectedImage forState:UIControlStateNormal];
    [commentButton setImage:commentButtonSelectedImage forState:UIControlStateSelected];
    [commentButton setImage:commentButtonSelectedImage forState:UIControlStateHighlighted];
    
    commentButton.imageEdgeInsets = UIEdgeInsetsMake(2.0, 0, 0, 0);
    commentButton.userInteractionEnabled = NO;
    
    [self.cardView addSubview:commentButton];
    
    NSString *likeButtonTitle = NSLocalizedString(@"Like", nil);
    TPCardViewButton *likeButton = [[TPCardViewButton alloc] initWithSide:TPCardViewButtonSideMiddle title:likeButtonTitle];
    
    UIImage *likeButtonUnselectedImage = [UIImage imageNamed:kImageNameLikeUnselected];
    UIImage *likeButtonSelectedImage = [UIImage imageNamed:kImageNameLikeSelected];
    
    [likeButton setImage:likeButtonUnselectedImage forState:UIControlStateNormal];
    [likeButton setImage:likeButtonSelectedImage forState:UIControlStateSelected];
    [likeButton setImage:likeButtonSelectedImage forState:UIControlStateHighlighted];
    
    likeButton.imageEdgeInsets = UIEdgeInsetsMake(0.0, -4.0, 0, 0);
    likeButton.titleEdgeInsets = UIEdgeInsetsMake(0, 4.0, 0, 0);
    likeButton.userInteractionEnabled = NO;
    
    [self.cardView addSubview:likeButton];
    
    NSString *shareButtonString = NSLocalizedString(@"Share", nil);
    TPCardViewButton *shareButton = [[TPCardViewButton alloc] initWithSide:TPCardViewButtonSideRight title:shareButtonString];
    
    UIImage *shareButtonUnselectedImage = [UIImage imageNamed:kImageNameShareUnselected];
    UIImage *shareButtonSelectedImage = [UIImage imageNamed:kImageNameShareSelected];
    
    [shareButton setImage:shareButtonUnselectedImage forState:UIControlStateNormal];
    [shareButton setImage:shareButtonSelectedImage forState:UIControlStateSelected];
    [shareButton setImage:shareButtonSelectedImage forState:UIControlStateHighlighted];

    shareButton.imageEdgeInsets = UIEdgeInsetsMake(-2.0, 0, 0, 2.0);
    shareButton.titleEdgeInsets = UIEdgeInsetsMake(0, 4.0, 0, 0);
    shareButton.userInteractionEnabled = NO;
    
    [shareButton addTarget:self action:@selector(sharePressed:) forControlEvents:UIControlEventTouchUpInside];
    
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
                            @"profilePicImageView" : self.profilePicImageView,
                            @"usernameLabel" : self.usernameLabel,
                            @"userFullNameLabel" : self.userFullNameLabel,
                            @"photoImageView" : self.photoImageView,
                            @"commentButton" : self.commentButton,
                            @"likeButton" : self.likeButton,
                            @"shareButton" : self.shareButton,
                            @"commentsCountLabel" : self.commentsCountLabel,
                            @"likesCountLabel" : self.likesCountLabel
                            };
    
    NSDictionary *metrics = @{@"spacing": @(kSpacing),
                              @"profilePictureWidthAndHeight": @(kProfilePicWidthAndHeight),
                              @"buttonRowHeight" : @(kButtonRowHeight)
                              };
    
    for (UIView *view in [views allValues]) {
        [view setTranslatesAutoresizingMaskIntoConstraints:NO];
    }
    
    // horizontals
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-12-[cardView]-12-|"
                                                                 options:0
                                                                 metrics:metrics
                                                                   views:views]];
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(spacing)-[profilePicImageView(profilePictureWidthAndHeight)]"
                                                                 options:0
                                                                 metrics:metrics
                                                                   views:views]];
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(spacing)-[profilePicImageView]-(spacing)-[usernameLabel]-(spacing)-|"
                                                                 options:0
                                                                 metrics:metrics
                                                                   views:views]];
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(spacing)-[profilePicImageView]-(spacing)-[userFullNameLabel]-(spacing)-|"
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
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(spacing)-[profilePicImageView(profilePictureWidthAndHeight)]-(spacing)-[captionLabel]"
                                                                 options:0
                                                                 metrics:metrics
                                                                   views:views]];
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(spacing)-[usernameLabel][userFullNameLabel]-(spacing)-[captionLabel]-(spacing)-[photoImageView(==308)]-[commentsCountLabel]-(spacing)-[commentButton(buttonRowHeight)]|"
                                                                 options:0
                                                                 metrics:metrics
                                                                   views:views]];

    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[photoImageView]-[commentsCountLabel]-(spacing)-[likeButton(buttonRowHeight)]|"
                                                                 options:0
                                                                 metrics:metrics
                                                                   views:views]];

    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[photoImageView]-[commentsCountLabel]-(spacing)-[shareButton(buttonRowHeight)]|"
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
    self.photoImageView.placeholderImageView.image = nil;
    self.profilePicImageView.image = nil;
    self.commentsCountLabel.text = nil;
    self.likesCountLabel.text = nil;
}


#pragma mark -
#pragma mark Target-Action

- (void)sharePressed:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(photoCellDidShare:)]) {
        [self.delegate photoCellDidShare:self];
    }
}

@end
