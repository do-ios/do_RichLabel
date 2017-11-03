//
//  DTHTMLElementStylesheet.m
//  DTCoreText
//
//  Created by Oliver Drobnik on 29.12.12.
//  Copyright (c) 2012 Drobnik.com. All rights reserved.
//

#import "DODTStylesheetHTMLElement.h"
#import "DODTCSSStylesheet.h"

@implementation DODTStylesheetHTMLElement

- (NSAttributedString *)attributedString
{
    return nil;
}

- (DODTCSSStylesheet *)stylesheet
{
    NSString *text = [self text];
    
    return [[DODTCSSStylesheet alloc] initWithStyleBlock:text];
}

@end
