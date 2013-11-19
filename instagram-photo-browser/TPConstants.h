//
//  TPConstants.h
//  instagram-photo-browser
//
//  Created by Tyler Powers on 11/9/13.
//  Copyright (c) 2013 Tyler Powers. All rights reserved.
//


// network

#define kInstagramPopularPhotosURLKey                       @"https://api.instagram.com/v1/media/popular?client_id=50c0e12b64a84dd0b9bbf334ba7f6bf6"
#define kNetworkTimeoutIntervalForAssetRequest              10
#define kNetworkTimeoutIntervalForAssetResource             30


// ui/colors

#define kNumberOfPhotosToDisplay                            50

#define kTextColorPrimary                                   [UIColor colorWithRed:0 green:0 blue:0 alpha:0.85]
#define kTextColorSecondary                                 [UIColor colorWithRed:0 green:0 blue:0 alpha:0.4]
#define kPrimaryBackgroundColor                             [UIColor colorWithRed:230/255.0 green:230/255.0 blue:230/255.0 alpha:1.0]

#define kFontHeading                                        [UIFont fontWithName:@"EuphemiaUCAS-Bold" size:14.0]
#define kFontTitle                                          [UIFont fontWithName:@"EuphemiaUCAS" size:14.0]
#define kFontSubtitle                                       [UIFont fontWithName:@"EuphemiaUCAS" size:12.0]
#define kFontButtonTitle                                    [UIFont fontWithName:@"EuphemiaUCAS-Bold" size:12.0]


#define kSpacingBetweenPhotos                               4

// auto layout metrics

#define kSpacing                                            6
#define kProfilePicWidthAndHeight                           50
#define kButtonRowHeight                                    42