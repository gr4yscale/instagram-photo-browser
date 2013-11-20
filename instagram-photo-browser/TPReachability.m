//
//  TPReachability.m
//  instagram-photo-browser
//
//  Created by Tyler Powers on 11/20/13.
//  Copyright (c) 2013 Tyler Powers. All rights reserved.
//

#import "TPReachability.h"

@implementation TPReachability


- (id)init
{
    self = [super init];
    if (self) {
        self.reachability = [Reachability reachabilityForInternetConnection];
        [self.reachability startNotifier];
    }
    return self;
}


- (BOOL)isOnline
{

    if ([self.reachability currentReachabilityStatus] == NotReachable) {
        return NO;
    } else {
        return YES;
    }
}

@end
