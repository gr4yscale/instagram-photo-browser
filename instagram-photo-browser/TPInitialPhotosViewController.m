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
    NSURL *popularPhotosURL = [NSURL URLWithString:@"https://api.instagram.com/v1/media/popular?client_id=50c0e12b64a84dd0b9bbf334ba7f6bf6"];

    __weak typeof(self)weakSelf = self;
    
    [NSURLConnection sendAsynchronousRequest:[NSURLRequest requestWithURL:popularPhotosURL]
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                               
                               if (connectionError) {
                                   NSLog(@"There was an error with the connection: %@, %@", connectionError, [connectionError userInfo]);
                                   return;
                               }
                               
                               NSError *errorParsingJSON = nil;
                               id photos = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers
                                                                             error:&errorParsingJSON];
                               if (!errorParsingJSON) {
                                   TPPhotosImportOperation *photosImportOp = [[TPPhotosImportOperation alloc] initWithPersistence:weakSelf.persistence
                                                                                                                           photos:photos];
                                   [weakSelf.operationQueue addOperation:photosImportOp];
                               } else {
                                   NSLog(@"There was an error parsing the JSON from the instagram popular images API response! %@, %@", errorParsingJSON, [errorParsingJSON userInfo]);
                                   return;
                               }
    }];
}


@end
