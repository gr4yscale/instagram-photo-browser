//
//  TPStatusOverlayView.h
//  instagram-photo-browser
//
//  Created by Tyler Powers on 11/19/13.
//  Copyright (c) 2013 Tyler Powers. All rights reserved.
//

@interface TPStatusOverlayView : UIView

@property (nonatomic, strong) UIButton *reloadButton;

- (id)initWithStatusType:(TPStatusType)type;
- (void)switchStatusType:(TPStatusType)type;
- (void)setupStaticConstraints;

@end
