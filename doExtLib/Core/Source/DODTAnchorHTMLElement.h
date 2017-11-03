//
//  DTHTMLElementA.h
//  DTCoreText
//
//  Created by Oliver Drobnik on 21.03.13.
//  Copyright (c) 2013 Drobnik.com. All rights reserved.
//

#import "DODTHTMLElement.h"

/**
 Specialized subclass of <DTHTMLElement> that represents a hyperlink.
 */
@interface DODTAnchorHTMLElement : DODTHTMLElement

/**
 Foreground text color of the receiver when highlighted
 */
@property (nonatomic, strong) DODTColor *highlightedTextColor;

@end
