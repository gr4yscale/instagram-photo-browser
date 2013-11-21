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
#import "TPAsyncLoadImageView.h"
#import "TPCollectionView.h"
#import "TPAssetManager.h"
#import "TPStatusOverlayView.h"

@interface TPInitialPhotosViewController ()

@property (nonatomic, strong) NSOperationQueue *operationQueue;
@property (nonatomic, strong) TPWebServiceClient *webserviceClient;
@property (nonatomic, strong) TPFetchedResultsCollectionViewDataSource *dataSource;
@property (nonatomic, strong) TPCollectionView *collectionView;
@property (nonatomic, strong) UIRefreshControl *refresh;
@property (nonatomic, strong) TPStatusOverlayView *statusOverlayView;

@property (nonatomic, assign) NSUInteger photoDownloadCount;

- (NSFetchedResultsController *)setupFetchedResultsController;
- (TPCollectionView *)setupCollectionView;
- (void)setupDataSource;
- (void)startQueuedDownloadTasksIfReady;
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


- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)loadView
{
    self.view = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.view.backgroundColor = kPrimaryBackgroundColor;

    TPCollectionView *cv = [self setupCollectionView];
    [self.view addSubview:cv];
    
    TPStatusOverlayView *statusOverlayView = [[TPStatusOverlayView alloc] initWithStatusType:TPStatusTypeOffline];
    statusOverlayView.frame = CGRectMake(0, 20, self.view.frame.size.width, self.view.frame.size.height-20);
    [self.view addSubview:statusOverlayView];
    [statusOverlayView setupStaticConstraints];
    [statusOverlayView.reloadButton addTarget:self action:@selector(statusViewButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
   
    self.collectionView = cv;
    self.statusOverlayView = statusOverlayView;
    
    [self setupDataSource]; // setting data source up here so we can check if there is data.
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self fetchAndImportPhotosJSON];
}


- (NSFetchedResultsController *)setupFetchedResultsController
{
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([Photo class])];
    
    fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"createdTime"
                                                                   ascending:NO]];
    fetchRequest.fetchLimit = kNumberOfPhotosToDisplay;
        
    return [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                               managedObjectContext:self.persistence.mainMOC
                                                 sectionNameKeyPath:nil
                                                          cacheName:nil];
}



- (TPCollectionView *)setupCollectionView
{
    CGRect collectionViewFrame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    
    flowLayout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);
    flowLayout.minimumInteritemSpacing = 0;
    flowLayout.minimumLineSpacing = kSpacingBetweenPhotos;
    flowLayout.itemSize = CGSizeMake(self.view.frame.size.width, 10); // this will vary based on the data
    
    flowLayout.headerReferenceSize = CGSizeMake(0, 0);
    flowLayout.footerReferenceSize = CGSizeMake(0, 0);
    
    TPCollectionView *collectionView = [[TPCollectionView alloc] initWithFrame:collectionViewFrame
                                                          collectionViewLayout:flowLayout];
    collectionView.alwaysBounceVertical = YES;
    collectionView.delaysContentTouches = NO;
    collectionView.backgroundColor = [UIColor clearColor];
    collectionView.hidden = YES;
    
    [collectionView registerClass:[TPPhotoCollectionViewCell class] forCellWithReuseIdentifier:NSStringFromClass([Photo class])];
    
    // reload the collectionView when slider is changed at Settings > General > Text Size
    
    [[NSNotificationCenter defaultCenter] addObserverForName:UIContentSizeCategoryDidChangeNotification
                                                      object:nil
                                                       queue:nil
                                                  usingBlock:^(NSNotification *notification) {
                                                      [collectionView reloadData];
                                                  }];
    // setup pull-to-refresh
    UIRefreshControl *refresh = [[UIRefreshControl alloc] init];
    [refresh addTarget:self action:@selector(fetchAndImportPhotosJSON) forControlEvents:UIControlEventValueChanged];
    [collectionView addSubview:refresh];
    self.refresh = refresh;
    
    return collectionView;
}


- (void)setupDataSource
{
    NSFetchedResultsController *frc = [self setupFetchedResultsController];
    
    self.dataSource = [[TPFetchedResultsCollectionViewDataSource alloc] initWithCollectionView:self.collectionView
                                                                      fetchedResultsController:frc];
    self.dataSource.cellIdentifier = NSStringFromClass([Photo class]);
    
    // this block gets called on the data source to update the cell with data on cellForItemAtIndexPath:
    
    __weak typeof(self) weakSelf = self;
    
    self.dataSource.updateCellBlock = ^(TPPhotoCollectionViewCell *cell, Photo *photo) {
       
        cell.delegate = weakSelf;
        cell.fullResImageURL = photo.fullResImageURL;
        cell.usernameLabel.text = photo.username;
        cell.userFullNameLabel.text = photo.userFullName;
        cell.captionLabel.text = photo.caption;
        cell.commentsCountLabel.text = [NSString stringWithFormat:@"%d %@", [photo.commentCount intValue], NSLocalizedString(@"comments", @"comments")];
        cell.likesCountLabel.text = [NSString stringWithFormat:@"%d %@", [photo.likeCount intValue], NSLocalizedString(@"likes", @"likes")];
        cell.link = photo.link;
        cell.shareButton.userInteractionEnabled = NO;
        
        cell.captionLabel.font = [UIFont preferredEuphemiaFontForTextStyle:UIFontTextStyleCaption1];
        cell.usernameLabel.font = [UIFont preferredEuphemiaFontForTextStyle:UIFontTextStyleSubheadline];
        cell.userFullNameLabel.font = [UIFont preferredEuphemiaFontForTextStyle:UIFontTextStyleCaption1];
        cell.likesCountLabel.font = [UIFont preferredEuphemiaFontForTextStyle:UIFontTextStyleCaption2];
        cell.commentsCountLabel.font = [UIFont preferredEuphemiaFontForTextStyle:UIFontTextStyleCaption2];
        
        cell.commentButton.titleLabel.font = [UIFont preferredEuphemiaFontForTextStyle:UIFontTextStyleCaption1];
        cell.likeButton.titleLabel.font = [UIFont preferredEuphemiaFontForTextStyle:UIFontTextStyleCaption1];
        cell.shareButton.titleLabel.font = [UIFont preferredEuphemiaFontForTextStyle:UIFontTextStyleCaption1];
        
        if (cell.fetchImages) {
        
            __weak typeof(cell) weakCell = cell;
            NSURL *photoURL = [NSURL URLWithString:photo.fullResImageURL];
            
            [cell.photoImageView setImageWithURL:photoURL
                                     placeHolder:YES
                                      completion:^{
                                          [weakSelf startQueuedDownloadTasksIfReady];
                                          weakCell.shareButton.userInteractionEnabled = YES;
                                      }
                                       failBlock:nil];
            
            NSURL *userProfilePicURL = [NSURL URLWithString:photo.userProfilePicURL];
            
            [cell.profilePicImageView setImageWithURL:userProfilePicURL placeHolder:NO completion:nil failBlock:nil];
        }
    };
    
    self.collectionView.delegate = self.dataSource;
}


- (void)startQueuedDownloadTasksIfReady
{
    if (self.photoDownloadCount == 1) {
        [[TPAssetManager shared] resumeQueuedDownloadTasks];
    } else {
        self.photoDownloadCount++;
    }
}


- (void)fetchAndImportPhotosJSON
{
    self.photoDownloadCount = 0;
    
    [TPWebServiceClient fetchPopularPhotosJSONWithCompletion:^(id data) {
        
        id photos = data[@"data"];
        if ([photos isKindOfClass:[NSArray class]]) {
            
            TPPhotosImportOperation *photosImportOp = [[TPPhotosImportOperation alloc] initWithPersistence:self.persistence
                                                                                                    photos:photos];
            photosImportOp.completionBlock = ^{
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{ // make sure to update UI on main thread!
                    [self.refresh endRefreshing];
                }];
            };
            
            [self.operationQueue addOperation:photosImportOp];
        }
    }
     failBlock:^(NSError *error) {
         [self.refresh endRefreshing];
     }];
}


#pragma mark -
#pragma mark TPPhotoCollectionViewCellDelegate

- (void)photoCellDidShare:(TPPhotoCollectionViewCell *)cell
{
    if (!cell.photoImageView.image || !isStringWithAnyText(cell.link)) return;
    
    NSArray *activityItems = @[cell.photoImageView.image, cell.link];

    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:nil];
    [self presentViewController:activityVC animated:YES completion:nil];
}


@end
