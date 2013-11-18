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

@property (nonatomic, strong) TPPersistence *persistence;
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
        
        if (!photoDict[@"id"] || [photoDict[@"type"] isEqualToString:@"video"]) return;
        
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
    
    for (NSManagedObject *object in objectsToDelete) {
        // delete files at local paths
        [self.backgroundMOC deleteObject:object];
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
