//
//  TPWebServiceClient.m
//  instagram-photo-browser
//
//  Created by Tyler Powers on 11/4/13.
//  Copyright (c) 2013 Tyler Powers. All rights reserved.
//

#import "TPWebServiceClient.h"

@interface TPWebServiceClient ()

+ (void)fetchJSONAtURL:(NSURL *)URL
            completion:(fetchJSONCompletionBlock)completion
             failBlock:(fetchJSONFailBlock)failBlock;
@end


@implementation TPWebServiceClient


+ (void)fetchJSONAtURL:(NSURL *)URL
            completion:(fetchJSONCompletionBlock)completion
             failBlock:(fetchJSONFailBlock)failBlock;
{
    [NSURLConnection sendAsynchronousRequest:[NSURLRequest requestWithURL:URL]
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                               
                               if (connectionError && failBlock) {
                                   failBlock(connectionError);
                                   NSLog(@"There was an error with the connection: %@, %@", connectionError, [connectionError userInfo]);
                                   return;
                               }
                               
                               NSError *errorParsingJSON = nil;
                               id object = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers
                                                                             error:&errorParsingJSON];
                               if (!errorParsingJSON) {
                                   if (completion) {
                                       completion(object);
                                   }
                               } else {
                                   if (failBlock) {
                                       failBlock(errorParsingJSON);
                                   }
                                   NSLog(@"There was an error parsing the JSON from the url! %@\r\n%@, %@", URL, errorParsingJSON, [errorParsingJSON userInfo]);
                                   NSLog(@"Here is the response string: \r\n%@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
                               }
                           }];
    
}


+ (void)fetchPopularPhotosJSONWithCompletion:(fetchJSONCompletionBlock)completion
                                   failBlock:(fetchJSONFailBlock)failBlock;
{
    NSURL *popularPhotosURL = [NSURL URLWithString:kInstagramPopularPhotosURLKey];
    
    [self fetchJSONAtURL:popularPhotosURL
              completion:completion
               failBlock:failBlock];
}

@end
