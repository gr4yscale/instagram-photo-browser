//
//  TPWebServiceClient.m
//  instagram-photo-browser
//
//  Created by Tyler Powers on 11/4/13.
//  Copyright (c) 2013 Tyler Powers. All rights reserved.
//

#import "TPWebServiceClient.h"

#define kInstagramPopularPhotosURLKey           @"https://api.instagram.com/v1/media/popular?client_id=50c0e12b64a84dd0b9bbf334ba7f6bf6"


@interface TPWebServiceClient ()

+ (void)getJSONAtURL:(NSURL *)URL completion:(void (^)(id data))completion;

@end


@implementation TPWebServiceClient


+ (void)getJSONAtURL:(NSURL *)URL completion:(void (^)(id data))completion
{
    
    [NSURLConnection sendAsynchronousRequest:[NSURLRequest requestWithURL:URL]
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                               
                               if (connectionError) {
                                   NSLog(@"There was an error with the connection: %@, %@", connectionError, [connectionError userInfo]);
                                   return;
                               }
                               
                               NSError *errorParsingJSON = nil;
                               id object = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers
                                                                             error:&errorParsingJSON];
                               if (!errorParsingJSON && completion) {
                                   completion(object);
                               } else {
                                   NSLog(@"There was an error parsing the JSON from the url! %@\r\n%@, %@", URL, errorParsingJSON, [errorParsingJSON userInfo]);
                                   NSLog(@"Here is the response string: \r\n%@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
                                   return;
                               }
                           }];
    
}


+ (void)getPopularPhotosJSONWithCompletion:(void (^)(id data))completion
{
    NSURL *popularPhotosURL = [NSURL URLWithString:kInstagramPopularPhotosURLKey];
    [self getJSONAtURL:popularPhotosURL completion:completion];
}

@end
