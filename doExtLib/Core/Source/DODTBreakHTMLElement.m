//
//  DTHTMLElementBR.m
//  DTCoreText
//
//  Created by Oliver Drobnik on 26.12.12.
//  Copyright (c) 2012 Drobnik.com. All rights reserved.
//

#import "DODTBreakHTMLElement.h"

@implementation DODTBreakHTMLElement

- (NSAttributedString *)attributedString
{
	@synchronized(self)
	{
		NSDictionary *attributes = [self attributesForAttributedStringRepresentation];
		return [[NSAttributedString alloc] initWithString:UNICODE_LINE_FEED attributes:attributes];
	}
}

@end
