//
//  TPFetchedResultsCollectionViewDataSource.m
//  instagram-photo-browser
//
//  Created by Tyler Powers on 11/5/13.
//  Copyright (c) 2013 Tyler Powers. All rights reserved.
//

#import "TPFetchedResultsCollectionViewDataSource.h"
#import "TPPhotoCollectionViewCell.h"
#import "Photo.h"

// Handling the change sets from NSFetchedResultsController in batches to use UICollectionView's performBatchUpdates with
// came from Ash Furrow's example here: https://github.com/AshFurrow/UICollectionView-NSFetchedResultsController which is based
// on the gist found here: https://gist.github.com/Lucien/4440c1cba83318e276bb
// The idea being that you wait until the NSFetchedResults controller finishes its updates before updating the UICollectionView

@interface TPFetchedResultsCollectionViewDataSource () <NSFetchedResultsControllerDelegate>

@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong) UICollectionView *collectionView;

@property (nonatomic, strong) NSMutableArray *objectChanges;
@property (nonatomic, strong) NSMutableArray *sectionChanges;

@property (nonatomic, assign) CGFloat totalHeightOfNewlyInsertedCells;
@property (atomic, assign) NSUInteger insertsCountSinceCVReload;

- (void)updateCollectionViewContentOffsetForNewlyInsertedCells;

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
        
        self.objectChanges = [NSMutableArray array];
        self.sectionChanges = [NSMutableArray array];
        
        [self.fetchedResultsController performFetch:NULL];
    }
    return self;
}


- (id)objectAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.fetchedResultsController objectAtIndexPath:indexPath];
}


- (void)updateCollectionViewContentOffsetForNewlyInsertedCells
{
    if (self.totalHeightOfNewlyInsertedCells > 0) {
        
        CGFloat paddingOfNewlyInsertedCells = self.insertsCountSinceCVReload * kSpacingBetweenPhotos;
        CGPoint newContentOffset = CGPointMake(self.collectionView.contentOffset.x, self.collectionView.contentOffset.y + self.totalHeightOfNewlyInsertedCells + paddingOfNewlyInsertedCells);
        
        [self.collectionView setContentOffset:newContentOffset animated:NO];
        
        self.totalHeightOfNewlyInsertedCells = 0;
        self.insertsCountSinceCVReload = 0;
    }
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

// The following was taken from Ash Furrow's example of how to queue up batch changes for NSFetchedResultsController + UICollectionViewController:
// https://raw.github.com/AshFurrow/UICollectionView-NSFetchedResultsController/master/AFMasterViewController.m

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    NSMutableDictionary *change = [NSMutableDictionary new];
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            change[@(type)] = @(sectionIndex);
            break;
        case NSFetchedResultsChangeDelete:
            change[@(type)] = @(sectionIndex);
            break;
    }
    
    [self.sectionChanges addObject:change];
}


- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    
    NSMutableDictionary *change = [NSMutableDictionary new];
    switch(type)
    {
        case NSFetchedResultsChangeInsert:
            change[@(type)] = newIndexPath;
            break;
        case NSFetchedResultsChangeDelete:
            change[@(type)] = indexPath;
            break;
        case NSFetchedResultsChangeUpdate:
            change[@(type)] = indexPath;
            break;
        case NSFetchedResultsChangeMove:
            change[@(type)] = @[indexPath, newIndexPath];
            break;
    }
    [self.objectChanges addObject:change];
}


- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    NSLog(@"didChangeContent");
    
    self.collectionView.userInteractionEnabled = NO;
    
    [CATransaction begin];
    [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
    
    if ([self.objectChanges count] > 0 && [self.sectionChanges count] == 0)
    {
        [self.collectionView performBatchUpdates:^{
            
            for (NSDictionary *change in self.objectChanges)
            {
                [change enumerateKeysAndObjectsUsingBlock:^(NSNumber *key, id obj, BOOL *stop) {
                    
                    NSFetchedResultsChangeType type = [key unsignedIntegerValue];
                    switch (type)
                    {
                        case NSFetchedResultsChangeInsert: {
                            
                            self.insertsCountSinceCVReload++;
                            [self.collectionView insertItemsAtIndexPaths:@[obj]];
                            
                            CGSize itemSize = [self collectionView:self.collectionView
                                                            layout:self.collectionView.collectionViewLayout
                                            sizeForItemAtIndexPath:obj];
                            
//                            NSLog(@"Cell size calculated: %@ || %@ ***newly inserted ***", obj, NSStringFromCGSize(itemSize));
                            
                            self.totalHeightOfNewlyInsertedCells += itemSize.height;
                        }
                            break;
                        case NSFetchedResultsChangeDelete:
                            [self.collectionView deleteItemsAtIndexPaths:@[obj]];
                            break;
                        case NSFetchedResultsChangeUpdate:
                            [self.collectionView reloadItemsAtIndexPaths:@[obj]];
                            break;
                        case NSFetchedResultsChangeMove:
                            [self.collectionView moveItemAtIndexPath:obj[0] toIndexPath:obj[1]];
                            break;
                    }
                }];
            }
            
            [self updateCollectionViewContentOffsetForNewlyInsertedCells];
            
        } completion:^(BOOL success) {
            
            self.collectionView.userInteractionEnabled = YES;
        }];
    }
    
    [self.sectionChanges removeAllObjects];
    [self.objectChanges removeAllObjects];
    
    [CATransaction commit];
}


- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    Photo *photo = [self objectAtIndexPath:indexPath];
    
    static TPPhotoCollectionViewCell *cellForComputingSize;
    if (!cellForComputingSize) {
        cellForComputingSize = [[TPPhotoCollectionViewCell alloc] initWithFrame:CGRectZero];
        cellForComputingSize.fetchImages = NO;
    }
    
    if (self.updateCellBlock) {
        self.updateCellBlock(cellForComputingSize, photo); // set data on the labels so autolayout makes the right determinations
    }
    
    CGSize captionLabelSize = [cellForComputingSize.captionLabel systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
    
    CGSize size = CGSizeMake(320, captionLabelSize.height + 460);
    
//    NSLog(@"Cell size calculated: %@ || %@", indexPath, NSStringFromCGSize(size));
    
    return size;
}


@end
