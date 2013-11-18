//
//  TPAssetManager.h
//  instagram-photo-browser
//
//  Created by Tyler Powers on 11/13/13.
//  Copyright (c) 2013 Tyler Powers. All rights reserved.
//


@interface TPAssetManager : NSObject

typedef void (^fetchCompletionBlock)(NSURL *localURL);
typedef void (^fetchFailBlock)(NSError *error);

+ (instancetype)shared;

- (NSURLSessionDownloadTask *)downloadAssetWithURL:(NSURL *)URL
                                        completion:(fetchCompletionBlock)completion
                                         failBlock:(fetchFailBlock)failBlock;

- (void)queueAssetDownloadWithURL:(NSURL *)URL
                       completion:(fetchCompletionBlock)completion
                        failBlock:(fetchFailBlock)failBlock;

- (void)resumeQueuedDownloadTasks;

- (NSURL *)localURLForRemoteAssetURL:(NSURL *)remoteURL;

@end
