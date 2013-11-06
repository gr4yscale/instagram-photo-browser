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

#pragma UICollectionViewDataSource

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



@end
