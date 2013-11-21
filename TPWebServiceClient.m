//
//  TPWebServiceClient.m
//  instagram-photo-browser
//
//  Created by Tyler Powers on 11/4/13.
//  Copyright (c) 2013 Tyler Powers. All rights reserved.
//

#import "TPWebServiceClient.h"

@interface TPWebServiceClient ()

@property (nonatomic, strong) NSURLSession *urlSession;

- (void)fetchJSONAtURL:(NSURL *)URL
            completion:(fetchJSONCompletionBlock)completion
             failBlock:(fetchJSONFailBlock)failBlock;
@end


@implementation TPWebServiceClient

static TPWebServiceClient *_sharedInstance = nil;
static dispatch_once_t onceToken = 0;

+ (instancetype)shared {
    
    dispatch_once(&onceToken, ^{
        if (!_sharedInstance) {
            _sharedInstance = [[TPWebServiceClient alloc] init];
        }
    });
    return _sharedInstance;
}

+ (void)setShared:(TPWebServiceClient *)instance {
    onceToken = 0;
    _sharedInstance = instance;
}

- (id)init
{
    self = [super init];
    if (self) {
        NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
        sessionConfiguration.timeoutIntervalForRequest = kNetworkTimeoutIntervalForJSONRequest;
        sessionConfiguration.timeoutIntervalForResource = kNetworkTimeoutIntervalForJSONResource;
        
        self.urlSession = [NSURLSession sessionWithConfiguration:sessionConfiguration];
    }
    return self;
}


- (void)fetchJSONAtURL:(NSURL *)URL
            completion:(fetchJSONCompletionBlock)completion
             failBlock:(fetchJSONFailBlock)failBlock;
{
    NSURLSessionDataTask *dataTask = [self.urlSession dataTaskWithRequest:[NSURLRequest requestWithURL:URL]
                                                        completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                            
                                                            if (error && failBlock) {
                                                                failBlock(error);
                                                                NSLog(@"There was an error with the request at url: %@", response.URL);
                                                            }
                                                            
                                                            NSError *errorParsingJSON = nil;
                                                            id object = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers
                                                                                                          error:&errorParsingJSON];
                                                            if (!errorParsingJSON) {
                                                                if (completion) {
                                                                    completion(object);
                                                                }
                                                            } else if (failBlock) {
                                                                failBlock(errorParsingJSON);
                                                            }
                                                            
                                                            NSLog(@"There was an error parsing the JSON from the url! %@\r\n%@, %@", URL, errorParsingJSON, [errorParsingJSON userInfo]);
                                                            NSLog(@"Here is the response string: \r\n%@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
                                                        }];
    [dataTask resume];
}


- (void)fetchPopularPhotosJSONWithCompletion:(fetchJSONCompletionBlock)completion
                                   failBlock:(fetchJSONFailBlock)failBlock;
{
    NSURL *popularPhotosURL = [NSURL URLWithString:kInstagramPopularPhotosURLKey];
    
    [self fetchJSONAtURL:popularPhotosURL
              completion:completion
               failBlock:failBlock];
}

@end
