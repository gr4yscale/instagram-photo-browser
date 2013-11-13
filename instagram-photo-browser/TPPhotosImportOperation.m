//
//  TPPhotosImportOperation.m
//  instagram-photo-browser
//
//  Created by Tyler Powers on 11/4/13.
//  Copyright (c) 2013 Tyler Powers. All rights reserved.
//

#import "TPPhotosImportOperation.h"
#import "Photo+Import.h"

@interface TPPhotosImportOperation ()

@property (nonatomic, strong) TPPersistence *persistence;
@property (nonatomic, strong) NSArray *photos;
@property (nonatomic, strong) NSManagedObjectContext *backgroundMOC;

- (void)importPhotos;
- (void)deleteOldestPhotos;

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
}


- (void)importPhotos
{
    if (![self.photos isKindOfClass:[NSArray class]]) return;
    
    for (NSDictionary *photoDict in self.photos) {
        
        if (!photoDict[@"id"]) return; // safety first!
        
        [Photo importFromDictionary:photoDict intoMOC:self.backgroundMOC];
    }

    NSError *importError = nil;
    
    [self deleteOldestPhotos];
    
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
    
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"NOT (self IN %@)", mostRecentlyCreatedPhotosObjectIDs];
    fetchRequest.resultType = NSManagedObjectResultType;
    
    NSArray *objectsToDelete = [self.backgroundMOC executeFetchRequest:fetchRequest error:&error];
    
    if (error) {
        NSLog(@"Error deleting photos no longger in the list of NSMangedObjectIDs: \r\n%@", mostRecentlyCreatedPhotosObjectIDs);
    }
    
    for (NSManagedObject *object in objectsToDelete) {
        [self.backgroundMOC deleteObject:object];
    }
}


@end
