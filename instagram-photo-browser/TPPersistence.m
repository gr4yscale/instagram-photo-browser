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
@property (nonatomic,strong) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@end


@implementation TPPersistence

- (id)init
{
    self = [super init];
    if (self) {
        
        // handle merging changes when a save notification happens from a background MOC
        [[NSNotificationCenter defaultCenter] addObserverForName:NSManagedObjectContextDidSaveNotification
                                                          object:nil
                                                           queue:nil
                                                      usingBlock:^(NSNotification *notification) {
                                                          
                                                          if (notification.object != self.mainMOC) {
                                                              
                                                              NSLog(@"Merging changes into the main context from a background context");
                                                              [self.mainMOC performBlock:^(){
                                                                  [self.mainMOC mergeChangesFromContextDidSaveNotification:notification];
                                                              }];
                                                          }
                                                      }];
    }
    return self;
}


- (void)dealloc // this should never be dealloc'd, but safety third...
{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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
    
    NSDictionary *options = @{NSInferMappingModelAutomaticallyOption : @(YES),
                              NSMigratePersistentStoresAutomaticallyOption: @(YES)};
    
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:URL options:options error:&error]) {
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
