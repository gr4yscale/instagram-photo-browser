//
//  TPPersistence.m
//  instagram-photo-browser
//
//  Created by Tyler Powers on 11/4/13.
//  Copyright (c) 2013 Tyler Powers. All rights reserved.
//

#import "TPPersistence.h"
#import "TPUtils.h"

@interface TPPersistence ()

@property (nonatomic,strong) NSManagedObjectModel *managedObjectModel;
@property (nonatomic,strong,readwrite) NSManagedObjectContext *mainMOC;
@property (nonatomic,strong) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@end


@implementation TPPersistence

- (id)init
{
    self = [super init];
    if (self) {

    }
    return self;
}


- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel) return _managedObjectModel;
    
    NSURL *URL = [[NSBundle mainBundle] URLForResource:@"DataModel" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:URL];
    return _managedObjectModel;
}


- (NSManagedObjectContext *)mainMOC
{
    if (_mainMOC) return _mainMOC;
    
    _mainMOC = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    _mainMOC.persistentStoreCoordinator = [self persistentStoreCoordinator];
    return _mainMOC;
}


- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator) return _persistentStoreCoordinator;
    
    NSURL *URL = [[TPUtils documentsDirectory] URLByAppendingPathComponent:@"Instagram-Photo-Browser.sqlite"];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:URL options:nil error:&error]) {
        NSLog(@"error adding persistent store coordinator: %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}


- (void)saveMainMOC
{
    NSError *error = nil;
    NSManagedObjectContext *moc = self.mainMOC;
    if (moc) {
        if ([moc hasChanges] && ![moc save:&error]) {
            NSLog(@"error encountered saving main MOC %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

@end
