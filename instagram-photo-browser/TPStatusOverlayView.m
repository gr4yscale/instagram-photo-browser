//
//  TPStatusOverlayView.m
//  instagram-photo-browser
//
//  Created by Tyler Powers on 11/19/13.
//  Copyright (c) 2013 Tyler Powers. All rights reserved.
//

#import "TPStatusOverlayView.h"

@interface TPStatusOverlayView ()

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UILabel *statusTextLabel;
@property (nonatomic, strong) UILabel *statusSubtextLabel;
@property (nonatomic, strong) UIButton *reloadButton;

- (void)setupSubviews;
- (void)setupStaticConstraints;
- (void)addRotationToImageView;

@end


#define kFontStatusText                             [UIFont fontWithName:@"EuphemiaUCAS-Bold" size:18.0]


@implementation TPStatusOverlayView



- (id)initWithStatusType:(TPStatusType)type
{
    self = [super init];
    if (self) {
        self.backgroundColor = kPrimaryBackgroundColor;
        [self setupSubviews];
        [self setupStaticConstraints];
        [self switchStatusType:type];
    }
    return self;
}


- (void)switchStatusType:(TPStatusType)type
{
    switch (type) {
        case TPStatusTypeLoading: {
            self.imageView.hidden = NO;
            self.imageView.image = [UIImage imageNamed:kImageNameLoadingIndicator];
            [self addRotationToImageView];
            self.statusTextLabel.hidden = NO;
            self.statusSubtextLabel.hidden = YES;
            self.reloadButton.hidden = YES;
            self.statusTextLabel.text = NSLocalizedString(@"Loading", nil);
        }
            break;
        case TPStatusTypeNoData: {
            self.imageView.hidden = NO;
            self.imageView.image = [UIImage imageNamed:kImageNameLoadingIndicatorNoData];
            [self.imageView.layer removeAllAnimations];
            self.statusTextLabel.hidden = NO;
            self.statusSubtextLabel.hidden = NO;
            self.reloadButton.hidden = NO;
            self.statusTextLabel.text = NSLocalizedString(@"No Data", nil);
            self.statusSubtextLabel.text = NSLocalizedString(@"I couldn't find what you're looking for!", nil);
            
            [self.reloadButton setTitle:NSLocalizedString(@"Reload", nil)
                               forState:UIControlStateNormal];
        }
            break;
        case TPStatusTypeOffline: {
            [self.imageView.layer removeAllAnimations];
            self.imageView.hidden = NO;
            self.imageView.image = [UIImage imageNamed:kImageNameNoInternet];
            self.statusTextLabel.hidden = NO;
            self.statusSubtextLabel.hidden = NO;
            self.reloadButton.hidden = YES;
            self.statusTextLabel.text = NSLocalizedString(@"No Internet Connection.", nil);
            self.statusSubtextLabel.text = NSLocalizedString(@"You are offline.\r\nPlease connect to a network.", nil);
        }
            break;
        case TPStatusTypeError: {
            [self.imageView.layer removeAllAnimations];
            self.imageView.hidden = NO;
            self.imageView.image = [UIImage imageNamed:kImageNameLoadingIndicatorError];
            self.statusTextLabel.hidden = NO;
            self.statusSubtextLabel.hidden = NO;
            self.statusTextLabel.text = NSLocalizedString(@"Error Fetching Data", nil);
            self.statusSubtextLabel.text = nil;
            
            [self.reloadButton setTitle:NSLocalizedString(@"Try Again", nil)
                               forState:UIControlStateNormal];
        }
            break;
        default:
            break;
    }
}


- (void)setupSubviews
{
    UIImageView *imageView = [[UIImageView alloc] init];
    [self addSubview:imageView];
    
    UILabel *statusTextLabel = [[UILabel alloc] init];
    statusTextLabel.font = [UIFont preferredEuphemiaFontForTextStyle:UIFontTextStyleSubheadline];
    statusTextLabel.textColor = kPlaceHolderTintColor;
    statusTextLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:statusTextLabel];
    
    UILabel *statusSubtextLabel = [[UILabel alloc] init];
    statusSubtextLabel.font = [UIFont preferredEuphemiaFontForTextStyle:UIFontTextStyleCaption1];
    statusSubtextLabel.textColor = kPlaceHolderTintColor;
    statusSubtextLabel.textAlignment = NSTextAlignmentCenter;
    statusSubtextLabel.numberOfLines = 0;
    
    [self addSubview:statusSubtextLabel];
    
    UIButton *reloadButton = [[UIButton alloc] init];
    [reloadButton setTitleColor:kPlaceHolderTintColor forState:UIControlStateNormal];
    
    [self addSubview:reloadButton];
    
    self.imageView = imageView;
    self.statusTextLabel = statusTextLabel;
    self.statusSubtextLabel = statusSubtextLabel;
    self.reloadButton = reloadButton;
}



- (void)setupStaticConstraints
{
    
    NSDictionary *views = @{@"self" : self,
                            @"imageView" : self.imageView,
                            @"statusTextLabel" : self.statusTextLabel,
                            @"statusSubtextLabel" : self.statusSubtextLabel,
                            @"reloadButton" : self.reloadButton};
    
    NSDictionary *metrics = @{@"spacing": @(20)};
    
    for (UIView *view in [views allValues]) {
        [view setTranslatesAutoresizingMaskIntoConstraints:NO];
    }
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(160)-[imageView]-(spacing)-[statusTextLabel]-(60)-[statusSubtextLabel]-(60)-[reloadButton]-(spacing)-|"
                                                                 options:NSLayoutFormatAlignAllCenterX
                                                                 metrics:metrics
                                                                   views:views]];
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[statusTextLabel]-|"
                                                                 options:0
                                                                 metrics:metrics
                                                                   views:views]];
}



- (void)addRotationToImageView
{
    CABasicAnimation* rotationAnimation;
    rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.toValue = [NSNumber numberWithFloat: M_PI];
    rotationAnimation.duration = 0;
    rotationAnimation.cumulative = YES;
    rotationAnimation.repeatCount = HUGE_VALF;
    
    [self.imageView.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
}

@end
