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

@interface TPInitialPhotosViewController ()

@property (nonatomic, strong) NSOperationQueue *operationQueue;
@property (nonatomic, strong) TPWebServiceClient *webserviceClient;

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

    UIView *view = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    view.backgroundColor = [UIColor purpleColor];
    
    self.view = view;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    [self fetchAndImportPhotosJSON];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];

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


@end
