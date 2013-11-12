//
//  Photo+Additions.h
//  instagram-photo-browser
//
//  Created by Tyler Powers on 11/4/13.
//  Copyright (c) 2013 Tyler Powers. All rights reserved.
//

#import "Photo.h"

@interface Photo (Import)

+ (void)importFromDictionary:(NSDictionary *)dict intoMOC:(NSManagedObjectContext *)moc;

@end
