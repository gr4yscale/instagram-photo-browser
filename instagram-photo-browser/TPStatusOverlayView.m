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

- (id)init
{
    self = [super init];
    if (self) {
        [self setupSubviews];
        [self setupStaticConstraints];
    }
    return self;
}


- (id)initWithStatusType:(TPStatusType)type
{
    self = [super init];
    if (self) {
        [self switchStatusType:type];
    }
    return self;
}


- (void)switchStatusType:(TPStatusType)type
{
    switch (type) {
        case TPStatusTypeLoading: {
            self.imageView.hidden = NO;
            self.imageView.image = [UIImage imageNamed:@"loading-indicator"];
            [self addRotationToImageView];
            self.statusTextLabel.hidden = NO;
            self.statusSubtextLabel.hidden = YES;
            self.reloadButton.hidden = YES;
            self.statusTextLabel.text = NSLocalizedString(@"Loading", nil);
        }
            break;
        case TPStatusTypeNoData: {
            self.imageView.hidden = NO;
            self.imageView.image = [UIImage imageNamed:@"loading-indicator-no-data"];
            [self.imageView.layer removeAllAnimations];
            self.statusTextLabel.hidden = NO;
            self.statusSubtextLabel.hidden = NO;
            self.reloadButton.hidden = NO;
            self.statusTextLabel.text = NSLocalizedString(@"No Data", nil);
            self.statusSubtextLabel.text = NSLocalizedString(@"Unable to fetch new photos.", nil);
        }
            break;
        case TPStatusTypeOffline: {
            [self.imageView.layer removeAllAnimations];
            self.imageView.hidden = NO;
            self.imageView.image = [UIImage imageNamed:@"no-internet"];
            self.statusTextLabel.hidden = NO;
            self.statusSubtextLabel.hidden = NO;
            self.reloadButton.hidden = YES;
            self.statusTextLabel.text = NSLocalizedString(@"No Internet Connection.", nil);
            self.statusSubtextLabel.text = NSLocalizedString(@"You are offline. Please connect to a network and try again.", nil);
        }
            break;
        case TPStatusTypeError: {
            [self.imageView.layer removeAllAnimations];
            self.imageView.hidden = NO;
            self.imageView.image = [UIImage imageNamed:@"loading-indicator-error"];
            self.statusTextLabel.hidden = NO;
            self.statusSubtextLabel.hidden = NO;
            self.statusTextLabel.text = NSLocalizedString(@"Error Fetching Data", nil);
            self.statusSubtextLabel.text = NSLocalizedString(@"Something bad happened. Try reloading.", nil);
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
    statusTextLabel.font = kFontStatusText;
    statusTextLabel.textColor = kTextColorPrimary;
    
    [self addSubview:statusTextLabel];
    
    UILabel *statusSubtextLabel = [[UILabel alloc] init];
    statusSubtextLabel.font = kFontTitle;
    statusSubtextLabel.textColor = kTextColorSecondary;
    
    [self addSubview:statusSubtextLabel];
    
    //    UIButton *reloadButton = [[UIButton alloc] init];
    
    self.imageView = imageView;
    self.statusTextLabel = statusTextLabel;
    self.statusSubtextLabel = statusSubtextLabel;
    
}



- (void)setupStaticConstraints
{
    
    
    
    
    
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
