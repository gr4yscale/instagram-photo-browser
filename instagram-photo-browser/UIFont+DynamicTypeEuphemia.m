//
//  UIFont+DynamicTypeEuphemia.m
//  instagram-photo-browser
//
//  Created by Tyler Powers on 11/19/13.
//  Copyright (c) 2013 Tyler Powers. All rights reserved.
//

#import "UIFont+DynamicTypeEuphemia.h"

// I recognize that this is a hack and that likely there are very specific tweaks to kearning, leading, weight, etc
// on the system font for the various UIFontTextStyle's at different contentSizeCategories. That being said, I wanted to use a different
// font than Helvetica Neue and still take advantage of Settings > General > Text Size, so I created this category which basically steals the
// font size attribute from the preferred system font for the various textStyles and applies it to a hardcoded font.


@implementation UIFont (DynamicTypeEuphemia)

+ (UIFont *)preferredEuphemiaFontForTextStyle:(NSString *)textStyle {
    
    UIFontDescriptor *preferredFontDescriptor = [UIFontDescriptor preferredFontDescriptorWithTextStyle:textStyle];

    NSNumber *preferredFontSize = [preferredFontDescriptor objectForKey:UIFontDescriptorSizeAttribute];
    
    if ([textStyle isEqualToString:UIFontTextStyleHeadline] ||
        [textStyle isEqualToString:UIFontTextStyleSubheadline]) {
        
        return [UIFont fontWithName:@"EuphemiaUCAS-Bold" size:[preferredFontSize floatValue]];

    } else {
        return [UIFont fontWithName:@"EuphemiaUCAS" size:[preferredFontSize floatValue]];
    }
}

@end
