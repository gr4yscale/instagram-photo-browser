//
//  TPPhotosViewController.h
//  instagram-photo-browser
//
//  Created by Tyler Powers on 11/4/13.
//  Copyright (c) 2013 Tyler Powers. All rights reserved.
//

#import "TPPersistence.h"
#import "TPPhotoCollectionViewCell.h"

@interface TPPhotosViewController : UIViewController <TPPhotoCollectionViewCellDelegate>

@property (nonatomic, weak) TPPersistence *persistence;

@end
