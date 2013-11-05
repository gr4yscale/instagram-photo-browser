//
//  TPPhotosImportOperation.h
//  instagram-photo-browser
//
//  Created by Tyler Powers on 11/4/13.
//  Copyright (c) 2013 Tyler Powers. All rights reserved.
//

#import "TPPersistence.h"

@interface TPPhotosImportOperation : NSOperation

- (id)initWithPersistence:(TPPersistence *)persistence photos:(NSDictionary *)photos;

@end
