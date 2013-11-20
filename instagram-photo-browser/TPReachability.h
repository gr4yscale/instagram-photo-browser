//
//  TPReachability.h
//  instagram-photo-browser
//
//  Created by Tyler Powers on 11/20/13.
//  Copyright (c) 2013 Tyler Powers. All rights reserved.
//

#import "Reachability.h"

@interface TPReachability : NSObject

@property (nonatomic, strong) Reachability *reachability;

- (BOOL)isOnline;

@end
