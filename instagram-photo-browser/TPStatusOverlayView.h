//
//  TPStatusOverlayView.h
//  instagram-photo-browser
//
//  Created by Tyler Powers on 11/19/13.
//  Copyright (c) 2013 Tyler Powers. All rights reserved.
//

typedef NS_ENUM(NSInteger, TPStatusType) {
    TPStatusTypeLoading,
    TPStatusTypeNoData,
    TPStatusTypeOffline,
    TPStatusTypeError
};

@interface TPStatusOverlayView : UIView

- (id)initWithStatusType:(TPStatusType)type;

@end
