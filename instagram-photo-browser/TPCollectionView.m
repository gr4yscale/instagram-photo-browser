//
//  TPCollectionView.m
//  instagram-photo-browser
//
//  Created by Tyler Powers on 11/13/13.
//  Copyright (c) 2013 Tyler Powers. All rights reserved.
//

// Created this UICollectionView subclass to get the "best of both worlds" with UIButton touch detection and immediate scrolling on UIScrollView
// You can set delaysContentTouches on UIScrollView to prevent the UIButton from stealing touches but then it becomes unresponsive, taking too
// long to respond to presses. This way if you scroll and the touch ends out of the bounds of the UIButton the button touchUpInside event isn't fired,
// and scrolling happens on the areas where UIButtons exist in the UIScrollView's contentView
// For reference: http://stackoverflow.com/questions/17701323/uiscrollview-delayscontenttouches-issue

#import "TPCollectionView.h"

@implementation TPCollectionView

- (BOOL)touchesShouldCancelInContentView:(UIView *)view
{
    return YES;
}

@end
