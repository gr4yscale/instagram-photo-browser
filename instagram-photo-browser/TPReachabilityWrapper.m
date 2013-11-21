//
//  TPReachabilityWrapper.m
//  instagram-photo-browser
//
//  Created by Tyler Powers on 11/20/13.
//  Copyright (c) 2013 Tyler Powers. All rights reserved.
//

#import "TPReachabilityWrapper.h"

// let's make this a little more coherent. Are we online? If not, do something when we come online. If we go offline, do something else.

@implementation TPReachabilityWrapper

static TPReachabilityWrapper *_sharedInstance = nil;
static dispatch_once_t onceToken = 0;

+ (instancetype)shared {
    
    dispatch_once(&onceToken, ^{
        if (!_sharedInstance) {
            _sharedInstance = [[TPReachabilityWrapper alloc] init];
        }
    });
    
    return _sharedInstance;
}


+ (void)setShared:(TPReachabilityWrapper *)instance {
    onceToken = 0;
    _sharedInstance = instance;
}


- (id)init
{
    self = [super init];
    if (self) {
        self.reachability = [Reachability reachabilityForInternetConnection];
        [self.reachability startNotifier];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(reachabilityChanged:)
                                                     name:kReachabilityChangedNotification
                                                   object:nil];
    }
    return self;
}


- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kReachabilityChangedNotification object:nil];
}


- (BOOL)isOnline
{
    if ([self.reachability currentReachabilityStatus] == NotReachable) {
        return NO;
    } else {
        return YES;
    }
}


#pragma mark -
#pragma mark NSNotifications

- (void)reachabilityChanged:(NSNotification*) notification
{
	if(self.reachability.currentReachabilityStatus == NotReachable) {
		NSLog(@"Went offline");
        if (self.wentOfflineBlock) {
            self.wentOfflineBlock();
        }
    }
	else {
		NSLog(@"Went online");
        if (self.wentOnlineBlock) {
            self.wentOnlineBlock();
        }
    }
}


@end
