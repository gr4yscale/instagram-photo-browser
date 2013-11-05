//
//  NSDictionary+KeyValueMapping.h
//  instagram-photo-browser
//
//  Created by Tyler Powers on 11/5/13.
//  Copyright (c) 2013 Tyler Powers. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (KeyValueMapping)

+ (NSDictionary *)applyMapping:(NSDictionary *)mapping
                fromDictionary:(NSDictionary *)sourceDict
                  toDictionary:(NSMutableDictionary *)toDict
                      forClass:(Class)aClass;

@end
