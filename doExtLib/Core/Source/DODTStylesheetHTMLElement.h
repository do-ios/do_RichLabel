//
//  DTHTMLElementStylesheet.h
//  DTCoreText
//
//  Created by Oliver Drobnik on 29.12.12.
//  Copyright (c) 2012 Drobnik.com. All rights reserved.
//

#import "DODTHTMLElement.h"

@class DODTCSSStylesheet;

/**
 This is a specialized subclass of <DTHTMLElement> representing a style block.
 */
@interface DODTStylesheetHTMLElement : DODTHTMLElement

/**
 Parses the text children and assembles the resulting stylesheet.
 */
- (DODTCSSStylesheet *)stylesheet;

@end
