//
//  TPWebServiceClient.h
//  instagram-photo-browser
//
//  Created by Tyler Powers on 11/4/13.
//  Copyright (c) 2013 Tyler Powers. All rights reserved.
//


@interface TPWebServiceClient : NSObject

+ (void)getPopularPhotosJSONWithCompletion:(void (^)(id data))completion;

@end
