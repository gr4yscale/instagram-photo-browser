//
//  NSDictionary+KeyValueMapping.m
//  instagram-photo-browser
//
//  Created by Tyler Powers on 11/5/13.
//  Copyright (c) 2013 Tyler Powers. All rights reserved.
//

#import "NSDictionary+KeyValueMapping.h"

@implementation NSDictionary (KeyValueMapping)

+ (void)tp_applyMapping:(NSDictionary *)mapping
         fromDictionary:(NSDictionary *)sourceDict
           toDictionary:(NSMutableDictionary *)toDict
               forClass:(Class)aClass {
    
    [mapping enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        
        id objectFromSourceDict = [sourceDict valueForKeyPath:obj];
        
        if (objectFromSourceDict && [objectFromSourceDict isKindOfClass:aClass]) {
            toDict[key] = objectFromSourceDict;
        }
    }];
    
    return;
}

@end
