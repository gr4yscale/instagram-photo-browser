//
//  TPFetchedResultsCollectionViewDataSource.m
//  instagram-photo-browser
//
//  Created by Tyler Powers on 11/5/13.
//  Copyright (c) 2013 Tyler Powers. All rights reserved.
//

#import "TPFetchedResultsCollectionViewDataSource.h"

@interface TPFetchedResultsCollectionViewDataSource () <NSFetchedResultsControllerDelegate>

@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSBlockOperation *blockOperationForCVBatchUpdates;
@property (nonatomic, assign) BOOL shouldReloadCollectionView;

@end


@implementation TPFetchedResultsCollectionViewDataSource

- (id)initWithCollectionView:(UICollectionView *)collectionView fetchedResultsController:(NSFetchedResultsController *)fetchedResultsController
{
    self = [super init];
    if (self) {
        collectionView.dataSource = self;
        fetchedResultsController.delegate = self;
        
        self.collectionView = collectionView;
        self.fetchedResultsController = fetchedResultsController;
 
        [self.fetchedResultsController performFetch:NULL];
    }
    return self;
}



#pragma mark - UICollectionViewDataSource
#pragma mark -

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return self.fetchedResultsController.sections.count;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.fetchedResultsController.sections[section] numberOfObjects];
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (!self.cellIdentifier) {
        self.cellIdentifier = @"Cell";
    }
    
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:self.cellIdentifier
                                                                           forIndexPath:indexPath];
    
    id item = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    if(self.updateCellBlock) {
        self.updateCellBlock(cell, item);
    }
    
    return cell;
}


#pragma mark - NSFetchedResultsControllerDelegate
#pragma mark -

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    self.shouldReloadCollectionView = NO;
    self.blockOperationForCVBatchUpdates = [NSBlockOperation new];
}


- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id<NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    __weak UICollectionView *collectionView = self.collectionView;
    
    switch (type) {
        case NSFetchedResultsChangeInsert: {
            [self.blockOperationForCVBatchUpdates addExecutionBlock:^{
                [collectionView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex]];
            }];
            break;
        }

        case NSFetchedResultsChangeDelete: {
            [self.blockOperationForCVBatchUpdates addExecutionBlock:^{
                [collectionView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex]];
            }];
            break;
        }
            
        case NSFetchedResultsChangeUpdate: {
            [self.blockOperationForCVBatchUpdates addExecutionBlock:^{
                [collectionView reloadSections:[NSIndexSet indexSetWithIndex:sectionIndex]];
            }];
            break;
        }
            
        default:
            break;
    }
}


- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath
{
    __weak UICollectionView *weakCollectionView = self.collectionView;
    
    switch (type) {
        case NSFetchedResultsChangeInsert: {
            if ([self.collectionView numberOfSections] > 0) {
                if ([self.collectionView numberOfItemsInSection:indexPath.section] == 0) {
                    self.shouldReloadCollectionView = YES;
                } else {
                    [self.blockOperationForCVBatchUpdates addExecutionBlock:^{
                        [weakCollectionView insertItemsAtIndexPaths:@[newIndexPath]];
                    }];
                }
            } else {
                self.shouldReloadCollectionView = YES;
            }
            break;
        }
            
        case NSFetchedResultsChangeDelete: {
            if ([self.collectionView numberOfItemsInSection:indexPath.section] == 1) {
                self.shouldReloadCollectionView = YES;
            } else {
                [self.blockOperationForCVBatchUpdates addExecutionBlock:^{
                    [weakCollectionView deleteItemsAtIndexPaths:@[indexPath]];
                }];
            }
            break;
        }
            
        case NSFetchedResultsChangeUpdate: {
            [self.blockOperationForCVBatchUpdates addExecutionBlock:^{
                [weakCollectionView reloadItemsAtIndexPaths:@[indexPath]];
            }];
            break;
        }
            
        case NSFetchedResultsChangeMove: {
            [self.blockOperationForCVBatchUpdates addExecutionBlock:^{
                [weakCollectionView moveItemAtIndexPath:indexPath toIndexPath:newIndexPath];
            }];
            break;
        }
            
        default:
            break;
    }
}


- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    // Checks if we should reload the collection view to fix a bug @ http://openradar.appspot.com/12954582
    if (self.shouldReloadCollectionView) {
        [self.collectionView reloadData];
    } else {
        [self.collectionView performBatchUpdates:^{
            [self.blockOperationForCVBatchUpdates start];
        } completion:nil];
    }
}

@end
