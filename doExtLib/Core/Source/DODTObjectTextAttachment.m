//
//  DTTextAttachmentObject.m
//  DTCoreText
//
//  Created by Oliver Drobnik on 22.04.13.
//  Copyright (c) 2013 Drobnik.com. All rights reserved.
//

#import "DODTCoreText.h"

@implementation DODTObjectTextAttachment

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
	self = [super initWithCoder:aDecoder];
	if (self) {
		_childNodes = [aDecoder decodeObjectForKey:@"childNodes"];
	}
	return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
	[super encodeWithCoder:aCoder];
	[aCoder encodeObject:_childNodes forKey:@"childNodes"];
}

- (id)initWithElement:(DODTHTMLElement *)element options:(NSDictionary *)options
{
	self = [super initWithElement:element options:options];
	
	if (self)
	{
		// get base URL
		NSURL *baseURL = [options objectForKey:NSBaseURLDocumentOption];
		NSString *src = [element.attributes objectForKey:@"src"];
		
		// content URL
		_contentURL = [NSURL URLWithString:src relativeToURL:baseURL];
	}
	
	return self;
}

#pragma mark - DTTextAttachmentHTMLEncoding

- (NSString *)stringByEncodingAsHTML
{
	NSMutableString *retString = [NSMutableString string];
	
	[retString appendString:@"<object"];
	
	if (_contentURL)
	{
		[retString appendFormat:@" src=\"%@\"", [_contentURL absoluteString]];
	}
	
	// build style for img/video
	NSMutableString *styleString = [NSMutableString string];
	
	switch (_verticalAlignment)
	{
		case DTTextAttachmentVerticalAlignmentBaseline:
		{
			//				[classStyleString appendString:@"vertical-align:baseline;"];
			break;
		}
		case DTTextAttachmentVerticalAlignmentTop:
		{
			[styleString appendString:@"vertical-align:text-top;"];
			break;
		}
		case DTTextAttachmentVerticalAlignmentCenter:
		{
			[styleString appendString:@"vertical-align:middle;"];
			break;
		}
		case DTTextAttachmentVerticalAlignmentBottom:
		{
			[styleString appendString:@"vertical-align:text-bottom;"];
			break;
		}
	}
	
	if (_originalSize.width>0)
	{
		[styleString appendFormat:@"width:%.0fpx;", _originalSize.width];
	}
	
	if (_originalSize.height>0)
	{
		[styleString appendFormat:@"height:%.0fpx;", _originalSize.height];
	}
	
	// add local style for size, since sizes might vary quite a bit
	if ([styleString length])
	{
		[retString appendFormat:@" style=\"%@\"", styleString];
	}
	
	// attach the attributes dictionary
	NSMutableDictionary *tmpAttributes = [_attributes mutableCopy];
	
	// remove src,style, width and height we already have these
	[tmpAttributes removeObjectForKey:@"src"];
	[tmpAttributes removeObjectForKey:@"style"];
	[tmpAttributes removeObjectForKey:@"width"];
	[tmpAttributes removeObjectForKey:@"height"];
	
	for (__strong NSString *oneKey in [tmpAttributes allKeys])
	{
		oneKey = [oneKey stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
		NSString *value = [[tmpAttributes objectForKey:oneKey] stringByAddingHTMLEntities];
		[retString appendFormat:@" %@=\"%@\"", oneKey, value];
	}
	
	if (_childNodes)
	{
		[retString appendString:@">"];
		
		for (DODTHTMLElement *oneChild in _childNodes)
		{
			[retString appendString:[oneChild debugDescription]];
		}
		
		[retString appendString:@"</object>"];
	}
	else
	{
		[retString appendString:@" />"];
	}
	
	
	return retString;
}

#pragma mark - Properties

@synthesize childNodes = _childNodes;

@end
