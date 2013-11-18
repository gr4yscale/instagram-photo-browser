//
//  Photo+Additions.m
//  instagram-photo-browser
//
//  Created by Tyler Powers on 11/4/13.
//  Copyright (c) 2013 Tyler Powers. All rights reserved.
//

#import "Photo+Import.h"
#import "NSDictionary+KeyValueMapping.h"

#define kPhotoImportKeyIdentifier           @"identifier"
#define kPhotoImportKeyCaption              @"caption"
#define kPhotoImportKeyCommentCount         @"commentCount"
#define kPhotoImportKeyFullResImageURL      @"fullResImageURL"
#define kPhotoImportKeyLikeCount            @"likeCount"
#define kPhotoImportKeyUserFullName         @"userFullName"
#define kPhotoImportKeyUsername             @"username"
#define kPhotoImportKeyUserProfilePicURL    @"userProfilePicURL"
#define kPhotoImportKeyCreatedTime          @"createdTime"



@implementation Photo (Import)

+ (void)importFromDictionary:(NSDictionary *)dict intoMOC:(NSManagedObjectContext *)moc
{
    if (!dict[@"id"] || [dict[@"type"] isEqualToString:@"video"]) {
        return;
    }
    
    NSFetchRequest* fetchRequest = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass(self)];
    fetchRequest.fetchLimit = 1;
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"identifier = %@", dict[@"id"]];
    fetchRequest.resultType = NSManagedObjectIDResultType;
    
    if ([[moc executeFetchRequest:fetchRequest error:NULL] lastObject]) {
        return;
    } else {
        Photo *photo = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass(self)
                                                  inManagedObjectContext:moc];
        
        NSDictionary *sanitizedDict = [self sanitizedDictionaryFromDictionary:dict];
        
        [photo setValuesForKeysWithDictionary:sanitizedDict];
        photo.createdTime = [NSDate date];
    }
}



+ (NSDictionary *)sanitizedDictionaryFromDictionary:(NSDictionary *)dict {

    NSMutableDictionary *sanitizedDict = [NSMutableDictionary dictionary];
    
    NSDictionary *stringsMapping = @{kPhotoImportKeyIdentifier: @"id",
                                     kPhotoImportKeyCaption: @"caption.text",
                                     kPhotoImportKeyFullResImageURL: @"images.standard_resolution.url",
                                     kPhotoImportKeyUserFullName: @"user.full_name",
                                     kPhotoImportKeyUsername: @"user.username",
                                     kPhotoImportKeyUserProfilePicURL: @"user.profile_picture"};
    
    NSDictionary *numbersMapping = @{kPhotoImportKeyLikeCount: @"likes.count",
                                     kPhotoImportKeyCommentCount: @"comments.count"};
    
    [NSDictionary applyMapping:stringsMapping fromDictionary:dict toDictionary:sanitizedDict forClass:[NSString class]];
    [NSDictionary applyMapping:numbersMapping fromDictionary:dict toDictionary:sanitizedDict forClass:[NSNumber class]];
    
    return sanitizedDict;
}

@end
