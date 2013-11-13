//
//  TPInitialPhotosViewController.m
//  instagram-photo-browser
//
//  Created by Tyler Powers on 11/4/13.
//  Copyright (c) 2013 Tyler Powers. All rights reserved.
//

#import "TPInitialPhotosViewController.h"
#import "TPWebServiceClient.h"
#import "TPPhotosImportOperation.h"
#import "Photo.h"
#import "TPFetchedResultsCollectionViewDataSource.h"
#import "TPPhotoCollectionViewCell.h"

@interface TPInitialPhotosViewController ()

@property (nonatomic, strong) NSOperationQueue *operationQueue;
@property (nonatomic, strong) TPWebServiceClient *webserviceClient;
@property (nonatomic, strong) TPFetchedResultsCollectionViewDataSource *dataSource;
@property (nonatomic, strong) UICollectionView *collectionView;

- (NSFetchedResultsController *)setupFetchedResultsController;
- (UICollectionView *)setupCollectionView;
- (void)setupDataSource;
- (void)fetchAndImportPhotosJSON;

@end


@implementation TPInitialPhotosViewController


- (id)init
{
    self = [super init];
    if (self) {
        self.operationQueue = [[NSOperationQueue alloc] init];
        self.webserviceClient = [[TPWebServiceClient alloc] init];
    }
    return self;
}


- (void)loadView
{
    self.view = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.view.backgroundColor = [UIColor purpleColor];
    
    UICollectionView *cv = [self setupCollectionView];
    self.collectionView = cv;
    
    [self.view addSubview:cv];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupDataSource];
    [self fetchAndImportPhotosJSON];
}


- (NSFetchedResultsController *)setupFetchedResultsController
{
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([Photo class])];
    
    fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"likeCount"
                                                                   ascending:NO]];
    
    return [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                               managedObjectContext:self.persistence.mainMOC
                                                 sectionNameKeyPath:nil
                                                          cacheName:nil];
}



- (UICollectionView *)setupCollectionView
{
    CGRect collectionViewFrame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    
    flowLayout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);
    flowLayout.minimumInteritemSpacing = 0;
    flowLayout.minimumLineSpacing = 6.0f;
    flowLayout.itemSize = CGSizeMake(self.view.frame.size.width, 10); // this will vary based on the data
    
    flowLayout.headerReferenceSize = CGSizeMake(0, 0);
    flowLayout.footerReferenceSize = CGSizeMake(0, 0);
    
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:collectionViewFrame
                                                          collectionViewLayout:flowLayout];
    collectionView.delegate = self;
    collectionView.alwaysBounceVertical = YES;
    collectionView.delaysContentTouches = NO;
    
    [collectionView registerClass:[TPPhotoCollectionViewCell class] forCellWithReuseIdentifier:NSStringFromClass([Photo class])];
 
    return collectionView;
}


- (void)setupDataSource
{
    NSFetchedResultsController *frc = [self setupFetchedResultsController];
    
    self.dataSource = [[TPFetchedResultsCollectionViewDataSource alloc] initWithCollectionView:self.collectionView
                                                                      fetchedResultsController:frc];
    self.dataSource.cellIdentifier = NSStringFromClass([Photo class]);
    
    self.dataSource.updateCellBlock = ^(TPPhotoCollectionViewCell *cell, Photo *photo) {
        
        cell.usernameLabel.text = photo.username;
        cell.userFullNameLabel.text = photo.userFullName;
        cell.captionLabel.text = photo.caption;
        cell.commentsCountLabel.text = [NSString stringWithFormat:@"%d %@", [photo.commentCount intValue], NSLocalizedString(@"comments", @"comments")];
        cell.likesCountLabel.text = [NSString stringWithFormat:@"%d %@", [photo.likeCount intValue], NSLocalizedString(@"likes", @"likes")];
        
        if (cell.fetchImages) {
            NSLog(@"Configuring cell for photo id: %@", photo.identifier);
            [cell.photoImageView tp_setImageWithURL:[NSURL URLWithString:photo.fullResImageURL]];
        }
    };
}



- (void)fetchAndImportPhotosJSON
{
    __weak typeof(self)weakSelf = self;
    
    [TPWebServiceClient getPopularPhotosJSONWithCompletion:^(id data) {
    
        if (data[@"data"]) { // I know this looks weird, instagram JSON the relevant data we want under a "data" key
            
            TPPhotosImportOperation *photosImportOp = [[TPPhotosImportOperation alloc] initWithPersistence:weakSelf.persistence
                                                                                                    photos:data[@"data"]];
            [weakSelf.operationQueue addOperation:photosImportOp];
        }
    }];
}


#pragma mark - UICollectionViewFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"Asking for size of cell at indexPath: %@", indexPath);
    
    TPFetchedResultsCollectionViewDataSource *dataSource = (TPFetchedResultsCollectionViewDataSource *)collectionView.dataSource;
    Photo *photo = [dataSource objectAtIndexPath:indexPath];

    static TPPhotoCollectionViewCell *cellForComputingSize;
    if (!cellForComputingSize) {
        cellForComputingSize = [[TPPhotoCollectionViewCell alloc] initWithFrame:CGRectZero];
        cellForComputingSize.fetchImages = NO;
    }
   
    if (dataSource.updateCellBlock) {
        dataSource.updateCellBlock(cellForComputingSize, photo); // set data on the labels so autolayout makes the right determinations
    }
    
    return [cellForComputingSize.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
}



@end
