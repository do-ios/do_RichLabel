//
//  test.h
//  Do_Test
//
//  Created by wl on 15/7/21.
//  Copyright (c) 2015年 DoExt. All rights reserved.
//

#import <Foundation/Foundation.h>


@class DODTHTMLElement;
/**
 This class represents a CSS style sheet used for specifying formatting for certain CSS selectors.
 
 It supports matching styles by class, by id or by tag name. Hierarchy matching is not supported yet.
 */
@interface DODTCSSStylesheet : NSObject <NSCopying>


/**
 @name Creating Stylesheets
 */

/**
 Creates the default stylesheet.
 
 This stylesheet is based on the standard styles that Webkit provides for these tags. This stylesheet is loaded from an embedded copy of default.css.
 */
+ (DODTCSSStylesheet *)defaultStyleSheet;


/**
 Creates a stylesheet with a given style block
 
 @param css The CSS string for the style block
 */
- (id)initWithStyleBlock:(NSString *)css;


/**
 @name Working with CSS Style Blocks
 */


/**
 Parses a style block string and adds the found style rules to the receiver.
 
 @param css The CSS string for the style block
 */
- (void)parseStyleBlock:(NSString *)css;


/**
 Merges styles from given stylesheet into the receiver
 
 @param stylesheet the stylesheet to merge
 */
- (void)mergeStylesheet:(DODTCSSStylesheet *)stylesheet;


/**
 @name Accessing Style Information
 */

/**
 Returns a dictionary that contains the merged style for a given element and the applicable style rules from the receiver.
 
 @param element The HTML element.
 @param matchedSelectors The CSS selectors that caused a match
 @param ignoreInlineStyle If `YES` then the inline styles of the element will be ignored and only the receiver's styles used
 @returns The merged style dictionary containing only styles which selector matches the element
 */
- (NSDictionary *)mergedStyleDictionaryForElement:(DODTHTMLElement *)element matchedSelectors:(NSSet * __autoreleasing*)matchedSelectors ignoreInlineStyle:(BOOL)ignoreInlineStyle;

/**
 Returns a dictionary of the styles of the receiver
 */
- (NSDictionary *)styles;

/**
 Returns an ordered (by declaration) set of the selectors for all of the styles.
 */
- (NSArray *)orderedSelectors;

@end
