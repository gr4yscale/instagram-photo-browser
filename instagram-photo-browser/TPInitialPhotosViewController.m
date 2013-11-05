//
//  TPInitialPhotosViewController.m
//  instagram-photo-browser
//
//  Created by Tyler Powers on 11/4/13.
//  Copyright (c) 2013 Tyler Powers. All rights reserved.
//

#import "TPInitialPhotosViewController.h"
#import "TPWebServiceClient.h"

@interface TPInitialPhotosViewController ()

@property (nonatomic, strong) NSOperationQueue *operationQueue;
@property (nonatomic, strong) TPWebServiceClient *webserviceClient;

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

    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];

}

@end
