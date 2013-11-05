//
//  TPPhotosImportOperation.m
//  instagram-photo-browser
//
//  Created by Tyler Powers on 11/4/13.
//  Copyright (c) 2013 Tyler Powers. All rights reserved.
//

#import "TPPhotosImportOperation.h"
#import "Photo+ImportAdditions.h"

@interface TPPhotosImportOperation ()

@property (nonatomic, strong) TPPersistence *persistence;
@property (nonatomic, strong) NSArray *photos;
@property (nonatomic, strong) NSManagedObjectContext *backgroundMOC;

- (void)importPhotos;

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
        
        [Photo importFromDictionary:photoDict intoMOC:self.backgroundMOC];
        NSLog(@"imported id: %@", photoDict[@"id"]);
    }
 
    NSError *importError = nil;
    [self.backgroundMOC save:&importError];
    
    if (importError) {
        NSLog(@"error during import! %@ %@", importError, [importError userInfo]);
    }
}


@end
