//
//  DTHTMLElementLI.m
//  DTCoreText
//
//  Created by Oliver Drobnik on 27.12.12.
//  Copyright (c) 2012 Drobnik.com. All rights reserved.
//

#import "DODTListItemHTMLElement.h"

@implementation DODTListItemHTMLElement

- (NSUInteger)_indexOfListItemInListRoot:(DODTHTMLElement *)listRoot
{
	@synchronized(self)
	{
		NSInteger index = -1;
		
		NSArray *childNodes = [listRoot.childNodes copy];
 		for (DODTHTMLElement *oneElement in childNodes)
		{
			if ([oneElement isKindOfClass:[DODTListItemHTMLElement class]])
			{
				index++;
			}
			
			if (oneElement == self)
			{
				break;
			}
		}
		
		return index;
	}
}

// calculates the accumulated list indent
- (CGFloat)_sumOfListIndents
{
	CGFloat indent = 0;
	
	DODTHTMLElement *element = self.parentElement;
	
	while (element)
	{
		if ([element.name isEqualToString:@"ul"] || [element.name isEqualToString:@"ol"])
		{
			indent += element->_listIndent;
		}
		else if (element.displayStyle == DTHTMLElementDisplayStyleListItem)
		{
			// we accept these
			indent += element.padding.left;
		}
		else
		{
			break;
		}
		
		element = element.parentElement;
	}
	
	return indent;
}

- (void)applyStyleDictionary:(NSDictionary *)styles
{
	[super applyStyleDictionary:styles];
	
	CGFloat parentPadding = self.parentElement->_listIndent;
	CGFloat listIndents = [self _sumOfListIndents];
	
	self.paragraphStyle.headIndent = listIndents + _padding.left + _margins.left;
	self.paragraphStyle.firstLineHeadIndent = self.paragraphStyle.headIndent;
	
	_margins.left += parentPadding;
}

// creates an attributed list prefix
- (NSAttributedString *)_listPrefix
{
	DODTCoreTextParagraphStyle *paragraphStyle = [[self attributesForAttributedStringRepresentation] paragraphStyle];
	NSParameterAssert(paragraphStyle);
	
	DODTCoreTextFontDescriptor *fontDescriptor = [[self attributesForAttributedStringRepresentation] fontDescriptor];
	NSParameterAssert(fontDescriptor);
	
	DODTCSSListStyle *effectiveList = [self.paragraphStyle.textLists lastObject];
	DODTHTMLElement *listRoot = self.parentElement;
	NSUInteger listCounter = [self _indexOfListItemInListRoot:listRoot]+effectiveList.startingItemNumber;
	
	// make a temporary version of self that has same font attributes as list root
	DODTListItemHTMLElement *tmpCopy = [[DODTListItemHTMLElement alloc] init];
	[tmpCopy inheritAttributesFromElement:self];
	
	// take the parents text color
	tmpCopy.textColor = listRoot.textColor;
	
	// check for list-style:none modifier
	NSDictionary *styles = [[self attributeForKey:@"style"] dictionaryOfCSSStyles];
	
	if (styles)
	{
		// make a temp copy
		effectiveList = [effectiveList copy];
		
		// update from styles
		[effectiveList updateFromStyleDictionary:styles];
	}
	
	NSDictionary *attributes = [tmpCopy attributesForAttributedStringRepresentation];
	
	// modify paragraph style
	paragraphStyle.firstLineHeadIndent = self.paragraphStyle.headIndent - _margins.left - _padding.left;;  // first line has prefix and starts at list indent;
	paragraphStyle.defaultTabInterval = 100;
	
	// resets tabs
	paragraphStyle.tabStops = nil;
	
	// set tab stops
	if (effectiveList.type != DTCSSListStyleTypeNone)
	{
		if (_margins.left<=0)
		{
			return nil;
		}
		
		// first tab is to right-align bullet, numbering against
		CGFloat tabOffset = paragraphStyle.headIndent - (CGFloat)5.0; // TODO: change with font size
		[paragraphStyle addTabStopAtPosition:tabOffset alignment:kCTRightTextAlignment];
	}
	
	// second tab is for the beginning of first line after bullet
	[paragraphStyle addTabStopAtPosition:paragraphStyle.headIndent alignment:kCTLeftTextAlignment];
	
	NSMutableDictionary *newAttributes = [NSMutableDictionary dictionary];
	
	// make a font without italic or bold
	fontDescriptor.boldTrait = NO;
	fontDescriptor.italicTrait = NO;
	
	CTFontRef font = [fontDescriptor newMatchingFont];
	
	if (font)
	{
#if DTCORETEXT_SUPPORT_NS_ATTRIBUTES && __IPHONE_OS_VERSION_MAX_ALLOWED > __IPHONE_5_1
		if (___useiOS6Attributes)
		{
			UIFont *uiFont = [UIFont fontWithCTFont:font];
			[newAttributes setObject:uiFont forKey:NSFontAttributeName];
			
			CFRelease(font);
		}
		else
#endif
		{
			[newAttributes setObject:CFBridgingRelease(font) forKey:(id)kCTFontAttributeName];
		}
	}
	
	CGColorRef textColor = (__bridge CGColorRef)[attributes objectForKey:(id)kCTForegroundColorAttributeName];
	
	if (textColor)
	{
		[newAttributes setObject:(__bridge id)textColor forKey:(id)kCTForegroundColorAttributeName];
	}
#if DTCORETEXT_SUPPORT_NS_ATTRIBUTES
	else if (___useiOS6Attributes)
	{
		DODTColor *uiColor = [attributes foregroundColor];
		
		if (uiColor)
		{
			[newAttributes setObject:uiColor forKey:NSForegroundColorAttributeName];
		}
	}
#endif
	
	// add paragraph style (this has the tabs)
	if (paragraphStyle)
	{
#if DTCORETEXT_SUPPORT_NS_ATTRIBUTES
		if (___useiOS6Attributes)
		{
			NSParagraphStyle *style = [paragraphStyle NSParagraphStyle];
			[newAttributes setObject:style forKey:NSParagraphStyleAttributeName];
		}
		else
#endif
		{
			CTParagraphStyleRef newParagraphStyle = [paragraphStyle createCTParagraphStyle];
			[newAttributes setObject:CFBridgingRelease(newParagraphStyle) forKey:(id)kCTParagraphStyleAttributeName];
		}
	}
	
	// add textBlock if there's one (this has padding and background color)
	NSArray *textBlocks = [attributes objectForKey:DTTextBlocksAttribute];
	if (textBlocks)
	{
		[newAttributes setObject:textBlocks forKey:DTTextBlocksAttribute];
	}
	
	// transfer all lists so that
	NSArray *lists = [attributes objectForKey:DTTextListsAttribute];
	if (lists)
	{
		[newAttributes setObject:lists forKey:DTTextListsAttribute];
	}
	
	// add a marker so that we know that this is a field/prefix
	[newAttributes setObject:DTListPrefixField forKey:DTFieldAttribute];
	
	NSString *prefix = [effectiveList prefixWithCounter:listCounter];
	
	if (!prefix)
	{
		return nil;
	}
	
	DODTImage *image = nil;
	
	if (effectiveList.imageName)
	{
		image = [DODTImage imageNamed:effectiveList.imageName];
		
		if (!image)
		{
			// image invalid
			effectiveList.imageName = nil;
			
			prefix = [effectiveList prefixWithCounter:listCounter];
		}
	}
	
	NSMutableAttributedString *tmpStr = [[NSMutableAttributedString alloc] initWithString:prefix attributes:newAttributes];
	
	if (image)
	{
		// make an attachment for the image
		DODTImageTextAttachment *attachment = [[DODTImageTextAttachment alloc] init];
		attachment.image = image;
		attachment.displaySize = image.size;
		
#if DTCORETEXT_SUPPORT_NS_ATTRIBUTES && TARGET_OS_IPHONE
		// need run delegate for sizing
		CTRunDelegateRef embeddedObjectRunDelegate = createEmbeddedObjectRunDelegate(attachment);
		[newAttributes setObject:CFBridgingRelease(embeddedObjectRunDelegate) forKey:(id)kCTRunDelegateAttributeName];
#endif
		
		// add attachment
		[newAttributes setObject:attachment forKey:NSAttachmentAttributeName];
		
		if (effectiveList.position == DTCSSListStylePositionInside)
		{
			[tmpStr setAttributes:newAttributes range:NSMakeRange(2, 1)];
		}
		else
		{
			[tmpStr setAttributes:newAttributes range:NSMakeRange(1, 1)];
		}
	}
	
	// estimate width of the prefix
	NSString *trimmedPrefix = [prefix stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
	NSAttributedString *tmpAttributedString = [[NSAttributedString alloc] initWithString:trimmedPrefix attributes:newAttributes];

	CTLineRef tmpLine = CTLineCreateWithAttributedString((__bridge CFAttributedStringRef)(tmpAttributedString));
	double width = CTLineGetTypographicBounds(tmpLine, NULL, NULL, NULL);
	CFRelease(tmpLine);
	
	// if the non-whitespace characters are too wide then we omit the prefix
	if ((width+5.0)>_margins.left)
	{
		return nil;
	}
	
	return tmpStr;
}

- (NSAttributedString *)attributedString
{
	NSMutableAttributedString *tmpString = [[NSMutableAttributedString alloc] init];

	// append child elements
	NSAttributedString *childrenString = [super attributedString];

	// apend list prefix
	NSAttributedString *listPrefix = [self _listPrefix];
	
	if (listPrefix)
	{
		[tmpString appendAttributedString:listPrefix];
		
		// add NL if there is immediately another list prefix following
		NSString *field = [childrenString attribute:DTFieldAttribute atIndex:0 effectiveRange:NULL];
		
		if ([field isEqualToString:DTListPrefixField])
		{
			[tmpString appendEndOfParagraph];
		}
	}
	
	if (childrenString)
	{
		[tmpString appendAttributedString:childrenString];
	}
	
	return tmpString;
}

@end
