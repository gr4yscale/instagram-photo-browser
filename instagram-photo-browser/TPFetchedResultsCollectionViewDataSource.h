//
//  TPFetchedResultsCollectionViewDataSource.h
//  instagram-photo-browser
//
//  Created by Tyler Powers on 11/5/13.
//  Copyright (c) 2013 Tyler Powers. All rights reserved.
//

typedef void (^updateCellBlock)(id cell, id item);

@interface TPFetchedResultsCollectionViewDataSource : NSObject <UICollectionViewDataSource>

@property (nonatomic, strong) NSString *cellIdentifier;
@property (nonatomic, copy) updateCellBlock updateCellBlock;

- (id)initWithCollectionView:(UICollectionView *)collectionView fetchedResultsController:(NSFetchedResultsController *)fetchedResultsController;

- (id)objectAtIndexPath:(NSIndexPath *)indexPath;

@end
