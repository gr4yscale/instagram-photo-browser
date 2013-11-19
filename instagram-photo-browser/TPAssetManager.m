//
//  TPAssetManager.m
//  instagram-photo-browser
//
//  Created by Tyler Powers on 11/13/13.
//  Copyright (c) 2013 Tyler Powers. All rights reserved.
//

#import "TPAssetManager.h"


@interface TPAssetManager ()

@property (nonatomic, strong) NSURLSession *urlSession;

- (NSURL *)assetCacheURL;
- (BOOL)downloadFinishedForResponse:(NSURLResponse *)response;

- (NSURLSessionDownloadTask *)assetDownloadTaskWithURL:(NSURL *)URL
                                            completion:(fetchCompletionBlock)completion
                                             failBlock:(fetchFailBlock)failBlock;

@property (nonatomic, strong) NSMutableArray *queuedDownloadTasks;

@end



@implementation TPAssetManager

static TPAssetManager *_sharedInstance = nil;
static dispatch_once_t onceToken = 0;

+ (instancetype)shared {
    
    dispatch_once(&onceToken, ^{
        if (!_sharedInstance) {
            _sharedInstance = [[TPAssetManager alloc] init];
        }
    });
    
    return _sharedInstance;
}


+ (void)setShared:(TPAssetManager *)instance {
    onceToken = 0;
    _sharedInstance = instance;
}


- (id)init
{
    self = [super init];
    if (self) {
        self.queuedDownloadTasks = [NSMutableArray array];
        
        NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
        sessionConfiguration.timeoutIntervalForRequest = kNetworkTimeoutIntervalForAssetRequest;
        sessionConfiguration.timeoutIntervalForResource = kNetworkTimeoutIntervalForAssetResource;
        
        self.urlSession = [NSURLSession sessionWithConfiguration:sessionConfiguration];
    }
    return self;
}



- (NSURLSessionDownloadTask *)downloadAssetWithURL:(NSURL *)URL
                                        completion:(fetchCompletionBlock)completion
                                         failBlock:(fetchFailBlock)failBlock
{
    NSURLSessionDownloadTask *downloadTask = [self assetDownloadTaskWithURL:URL completion:completion failBlock:failBlock];
    
    [downloadTask resume];
    return downloadTask;
}



- (void)queueAssetDownloadWithURL:(NSURL *)URL
                       completion:(fetchCompletionBlock)completion
                        failBlock:(fetchFailBlock)failBlock
{
    NSURLSessionDownloadTask *downloadTask = [self assetDownloadTaskWithURL:URL completion:completion failBlock:failBlock];
    [self.queuedDownloadTasks addObject:downloadTask];
}



- (NSURLSessionDownloadTask *)assetDownloadTaskWithURL:(NSURL *)URL
                                            completion:(fetchCompletionBlock)completion
                                             failBlock:(fetchFailBlock)failBlock
{
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    
    NSURLSessionDownloadTask *downloadTask;
    downloadTask = [self.urlSession downloadTaskWithRequest:request
                                          completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error) {
                                              
                                              // originally broke this into smaller methods, but it was a lot of local variable duplication.
                                              // does the file already exist at destination path? if so, is it fully downloaded? if not, remove
                                              // half-downloaded file. if it's fully downloaded, go ahead and execute completion.
                                              // attempt to move the file from temp location to location derived from remote URL.
                                              // execute fail block in all error cases. this is the kind of thing that should be unit tested.
                                              
                                              if (!error) {
                                                  NSURL *localURL = [self localURLForRemoteAssetURL:response.URL];
                                                  NSFileManager *fm = [NSFileManager defaultManager];
                                                  NSError *error = nil;
                                                  
                                                  @synchronized([TPAssetManager shared]) {
                                                      
                                                      if ([fm fileExistsAtPath:[localURL path] isDirectory:NULL]) {
                                                          
                                                          if ([self downloadFinishedForResponse:response]) {
                                                              if (completion) completion(localURL);
                                                              return;
                                                          } else {
                                                              if (![fm removeItemAtURL:localURL error:&error]) {
                                                                  if (failBlock) failBlock(error);
                                                                  return;
                                                              }
                                                          }
                                                      }
                                                      
                                                      if ([fm moveItemAtURL:location toURL:localURL error:&error]) {
                                                          if (completion) completion(localURL);
                                                          return;
                                                      } else {
                                                          if (failBlock) failBlock(error);
                                                          return;
                                                      }
                                                  }
                                                  
                                              } else if (failBlock) {
                                                  failBlock(error);
                                              }
                                          }];
    return downloadTask;
}


- (void)resumeQueuedDownloadTasks
{
    for (NSURLSessionTask *task in self.queuedDownloadTasks) {
        [task resume];
    }
}

#pragma mark -
#pragma mark Helpers

- (NSURL *)assetCacheURL
{
    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSURL *assetCacheURL = [[NSURL fileURLWithPath:documentsPath] URLByAppendingPathComponent:@"assetCache" isDirectory:YES];
    
    NSFileManager *fm = [NSFileManager defaultManager];
    NSError *error = nil;
    
    if (![fm fileExistsAtPath:[assetCacheURL absoluteString] isDirectory:NULL]) {
        [fm createDirectoryAtURL:assetCacheURL withIntermediateDirectories:YES attributes:nil error:&error];
    }
    
    if (error) {
        NSLog(@"Error creating asset cache directory.");
    }
    
    return assetCacheURL;
}



- (NSURL *)localURLForRemoteAssetURL:(NSURL *)remoteURL
{
    return [[self assetCacheURL] URLByAppendingPathComponent:[remoteURL lastPathComponent]];
}


- (BOOL)downloadFinishedForResponse:(NSURLResponse *)response
{
    NSFileManager *fm = [NSFileManager defaultManager];
    NSURL *localURL = [self localURLForRemoteAssetURL:response.URL];
    
    if ([response respondsToSelector:@selector(allHeaderFields)]) { // make sure it's actually an NSHTTPURLResponse
        
        NSDictionary *headerFields = [((NSHTTPURLResponse *)response) allHeaderFields];
        NSDictionary *fileAttributes = [fm attributesOfItemAtPath:[localURL path] error:NULL];
        NSNumber *fileSize = [fileAttributes objectForKey:NSFileSize];
        NSNumber *responseHeaderContentLength = headerFields[@"Content-Length"];
        if ([fileSize longLongValue] == [responseHeaderContentLength longLongValue]) {
            return YES;
        }
    }
    return NO;
}


@end
