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
#define kPhotoImportKeyPhotoWidth           @"photoWidth"
#define kPhotoImportKeyPhotoHeight          @"photoHeight"


@implementation Photo (Import)


// this is slow and NOT the way to go for large imports, but for this example it should be fine.
// will replace with Apple's recommended implementation if this becomes a performance bottleneck:
// http://developer.apple.com/library/ios/#documentation/Cocoa/Conceptual/CoreData/Articles/cdImporting.html

+ (instancetype)findOrCreatePhoto:(NSString *)identifier
                          context:(NSManagedObjectContext*)moc
{
    
    NSFetchRequest* fetchRequest = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass(self)];
    fetchRequest.fetchLimit = 1;
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"identifier = %@", identifier];
    
    id object = [[moc executeFetchRequest:fetchRequest error:NULL] lastObject];
    
    if (!object) {
        object = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass(self)
                                               inManagedObjectContext:moc];
    }
    return object;
}



+ (void)importFromDictionary:(NSDictionary *)dict intoMOC:(NSManagedObjectContext *)moc
{
    NSDictionary *sanitizedDict = [self sanitizedDictionaryFromDictionary:dict];
    
    Photo *aPhoto = [self findOrCreatePhoto:sanitizedDict[kPhotoImportKeyIdentifier]
                                    context:moc];
    
    [aPhoto setValuesForKeysWithDictionary:sanitizedDict];
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
                                     kPhotoImportKeyCommentCount: @"comments.count",
                                     kPhotoImportKeyPhotoWidth: @"images.standard_resolution.width",
                                     kPhotoImportKeyPhotoHeight: @"images.standard_resolution.height"};
    
    [NSDictionary applyMapping:stringsMapping fromDictionary:dict toDictionary:sanitizedDict forClass:[NSString class]];
    [NSDictionary applyMapping:numbersMapping fromDictionary:dict toDictionary:sanitizedDict forClass:[NSNumber class]];
    
    return sanitizedDict;
}

@end
