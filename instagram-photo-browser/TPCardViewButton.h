//
//  TPCardViewButton.h
//  instagram-photo-browser
//
//  Created by Tyler Powers on 11/7/13.
//  Copyright (c) 2013 Tyler Powers. All rights reserved.
//

typedef NS_ENUM(NSInteger, TPCardViewButtonSide) {
    TPCardViewButtonSideLeft,
    TPCardViewButtonSideMiddle,
    TPCardViewButtonSideRight,
    TPCardViewButtonSideAll
};

@interface TPCardViewButton : UIButton

- (id)initWithSide:(TPCardViewButtonSide)side title:(NSString *)title;

@end
