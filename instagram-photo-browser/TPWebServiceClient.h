//
//  TPWebServiceClient.h
//  instagram-photo-browser
//
//  Created by Tyler Powers on 11/4/13.
//  Copyright (c) 2013 Tyler Powers. All rights reserved.
//

typedef void (^fetchJSONCompletionBlock)(id data);
typedef void (^fetchJSONFailBlock)(NSError *error);

@interface TPWebServiceClient : NSObject

+ (instancetype)shared;

- (void)fetchPopularPhotosJSONWithCompletion:(fetchJSONCompletionBlock)completion
                                   failBlock:(fetchJSONFailBlock)failBlock;

@end
