//
//  TPUtils.m
//  instagram-photo-browser
//
//  Created by Tyler Powers on 11/4/13.
//  Copyright (c) 2013 Tyler Powers. All rights reserved.
//

#import "TPUtils.h"


BOOL isStringWithAnyText(id object)
{
    if (![object isKindOfClass:[NSString class]]) {
        return NO;
    } else if (((NSString *)object).length > 0)
        return YES;
    else {
        return NO;
    }
}


@implementation TPUtils

+ (NSURL *)documentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}


@end
