//
//  TPPhotosImportOperation.m
//  instagram-photo-browser
//
//  Created by Tyler Powers on 11/4/13.
//  Copyright (c) 2013 Tyler Powers. All rights reserved.
//

#import "TPPhotosImportOperation.h"

@interface TPPhotosImportOperation ()

@property (nonatomic, strong) TPPersistence *persistence;
@property (nonatomic, strong) NSDictionary *photosDictionary;
@property (nonatomic, strong) NSManagedObjectContext *backgroundMOC;

- (void)importPhotos;

@end



@implementation TPPhotosImportOperation

- (id)initWithPersistence:(TPPersistence *)persistence photos:(NSDictionary *)photos
{
    self = [super init];
    if (self) {
        self.persistence = persistence;
        self.photosDictionary = photos;
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

    NSLog(@"%@", self.photosDictionary);
}

@end
