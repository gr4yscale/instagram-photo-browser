//
//  Photo.h
//  instagram-photo-browser
//
//  Created by Tyler Powers on 11/18/13.
//  Copyright (c) 2013 Tyler Powers. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Photo : NSManagedObject

@property (nonatomic, retain) NSString * caption;
@property (nonatomic, retain) NSNumber * commentCount;
@property (nonatomic, retain) NSDate * createdTime;
@property (nonatomic, retain) NSString * fullResImageURL;
@property (nonatomic, retain) NSString * identifier;
@property (nonatomic, retain) NSNumber * likeCount;
@property (nonatomic, retain) NSString * userFullName;
@property (nonatomic, retain) NSString * username;
@property (nonatomic, retain) NSString * userProfilePicURL;
@property (nonatomic, retain) NSString * link;

@end
