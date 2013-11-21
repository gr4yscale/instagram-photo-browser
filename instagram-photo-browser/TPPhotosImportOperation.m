//
//  TPPhotosImportOperation.m
//  instagram-photo-browser
//
//  Created by Tyler Powers on 11/4/13.
//  Copyright (c) 2013 Tyler Powers. All rights reserved.
//

#import "TPPhotosImportOperation.h"
#import "Photo+Import.h"
#import "TPAssetManager.h"

@interface TPPhotosImportOperation ()

@property (nonatomic, weak) TPPersistence *persistence;
@property (nonatomic, strong) NSArray *photos;
@property (nonatomic, strong) NSManagedObjectContext *backgroundMOC;

- (void)importPhotos;
- (void)deleteOldestPhotos;
- (void)queuePhotoDownloadWithURL:(NSURL *)photoURL;

@end



@implementation TPPhotosImportOperation

- (id)initWithPersistence:(TPPersistence *)persistence photos:(NSArray *)photos
{
    self = [super init];
    if (self) {
        self.persistence = persistence;
        self.photos = photos;
    }
    return self;
}


- (void)main
{
    NSManagedObjectContext *backgroundMOC = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    backgroundMOC.persistentStoreCoordinator = self.persistence.mainMOC.persistentStoreCoordinator;
    backgroundMOC.undoManager = nil; // this shouldn't be necessary on iOS, but just in case!
    
    self.backgroundMOC = backgroundMOC;
    
    [backgroundMOC performBlockAndWait:^{
        
        [self importPhotos];
    }];
    
    for (NSDictionary *photoDict in self.photos) {
        
        NSString *photoURLString = [photoDict valueForKeyPath:@"images.standard_resolution.url"];
        NSString *profilePicURLString = [photoDict valueForKey:@"user.profile_picture"];
        
        if (isStringWithAnyText(photoURLString)) {
            [self queuePhotoDownloadWithURL:[NSURL URLWithString:photoURLString]];
        }
        if (isStringWithAnyText(profilePicURLString)) {
            [self queuePhotoDownloadWithURL:[NSURL URLWithString:profilePicURLString]];
        }
    }
}


- (void)importPhotos
{
    if (![self.photos isKindOfClass:[NSArray class]]) return;
   
    [self deleteOldestPhotos];
    
    for (NSDictionary *photoDict in self.photos) {
        
        [Photo importFromDictionary:photoDict intoMOC:self.backgroundMOC];
    }

    NSError *importError = nil;
    
    [self.backgroundMOC save:&importError];
    
    if (importError) {
        NSLog(@"Error saving managed object context during import! %@ %@", importError, [importError userInfo]);
    }
}


- (void)deleteOldestPhotos
{
    NSError *error = nil;
    
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([Photo class])];
    
    fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"createdTime" ascending:NO]];
    fetchRequest.fetchLimit = kNumberOfPhotosToDisplay;
    fetchRequest.resultType = NSManagedObjectIDResultType;
    
    id mostRecentlyCreatedPhotosObjectIDs = [self.backgroundMOC executeFetchRequest:fetchRequest error:&error];
    
    // get objects that aren't in the "top x" most recently created
    
    fetchRequest = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([Photo class])];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"NOT (self IN %@)", mostRecentlyCreatedPhotosObjectIDs];
    fetchRequest.resultType = NSManagedObjectResultType;
    
    NSArray *objectsToDelete = [self.backgroundMOC executeFetchRequest:fetchRequest error:&error];
    
    if (error) {
        NSLog(@"Error deleting oldest photos (not in): \r\n%@", mostRecentlyCreatedPhotosObjectIDs);
    }
    
    for (Photo *photo in objectsToDelete) {
        
        NSString *photoRemoteURL = [photo.fullResImageURL copy];
        NSString *userProfPicRemoteURL = [photo.userProfilePicURL copy];
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
            
            if (isStringWithAnyText(photoRemoteURL)) {
                NSURL *remotePhotoURL = [NSURL URLWithString:photoRemoteURL];
                NSURL *localPhotoURL = [[TPAssetManager shared] localURLForRemoteAssetURL:remotePhotoURL];
                [[NSFileManager defaultManager] removeItemAtURL:localPhotoURL error:NULL];
            }
            
            if (isStringWithAnyText(userProfPicRemoteURL)) {
                NSURL *remoteProfPicURL = [NSURL URLWithString:userProfPicRemoteURL];
                NSURL *localProfPicURL = [[TPAssetManager shared] localURLForRemoteAssetURL:remoteProfPicURL];
                [[NSFileManager defaultManager] removeItemAtURL:localProfPicURL error:NULL];
            }
        });
        
        [self.backgroundMOC deleteObject:photo];
    }
}


- (void)queuePhotoDownloadWithURL:(NSURL *)photoURL
{
    NSURL *localURL = [[TPAssetManager shared] localURLForRemoteAssetURL:photoURL];
    
    if (photoURL && localURL) {
        
        @synchronized([TPAssetManager shared]) {
            if ([[NSFileManager defaultManager] fileExistsAtPath:[localURL path] isDirectory:NULL]) {
                return;
            }
        }
        
        [[TPAssetManager shared] queueAssetDownloadWithURL:photoURL
                                                completion:nil
                                                 failBlock:^(NSError *error) {
                                                     NSLog(@"Error batch fetching photo images during import! \r\n%@\r\n%@", error, [error localizedDescription]);
        }];
    }
}

@end
