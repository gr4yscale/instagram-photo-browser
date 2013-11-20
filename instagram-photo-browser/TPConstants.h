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
#define kPlaceHolderTintColor                               [UIColor colorWithRed:178/255.0 green:178/255.0 blue:178/255.0 alpha:1.0]


#define kSpacingBetweenPhotos                               4

// auto layout metrics

#define kSpacing                                            6
#define kProfilePicWidthAndHeight                           46
#define kButtonRowHeight                                    42

// asset keys for UIImage imageNamed: calls
#define kImageNameLoadingIndicator                          @"loading-indicator"
#define kImageNameLoadingIndicatorError                     @"loading-indicator-error"
#define kImageNameLoadingIndicatorNoData                    @"loading-indicator-no-data"
#define kImageNameNoInternet                                @"no-internet"
#define kImageNameCommentSelected                           @"comment-selected"
#define kImageNameCommentUnselected                         @"comment-unselected"
#define kImageNameLikeSelected                              @"like-selected"
#define kImageNameLikeUnselected                            @"like-unselected"
#define kImageNameShareSelected                             @"share-selected"
#define kImageNameShareUnselected                           @"share-unselected"
