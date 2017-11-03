//
//  DTASN1Serialization.m
//  DTFoundation
//
//  Created by Oliver Drobnik on 3/9/13.
//  Copyright (c) 2013 Cocoanetics. All rights reserved.
//

#import "DODTASN1Serialization.h"
#import "DODTASN1Parser.h"
#import "DODTBase64Coding.h"

@interface DODTASN1Serialization () <DTASN1ParserDelegate>

@property (nonatomic, readonly) id rootObject;

- (id)initWithData:(NSData *)data;

@end

@implementation DODTASN1Serialization
{
	id _rootObject;
	id _currentContainer;
	NSMutableArray *_stack;
}

+ (id)objectWithData:(NSData *)data
{
	DODTASN1Serialization *decoder = [[DODTASN1Serialization alloc] initWithData:data];
	
	return decoder.rootObject;
}


// private initializer
- (id)initWithData:(NSData *)data
{
	self = [super init];
	
	if (self)
	{
		DODTASN1Parser *parser = [[DODTASN1Parser alloc] initWithData:data];
		parser.delegate = self;
		
		if (![parser parse])
		{
			return nil;
		}
	}
	return self;
}

- (void)_pushContainer:(id)container
{
	if (!_stack)
	{
		_stack = [NSMutableArray array];
		_rootObject = container;
	}
	
	[_currentContainer addObject:container];
	
	[_stack addObject:container];
	_currentContainer = container;
}

- (void)_addObjectToCurrentContainer:(id)object
{
	if (!_stack)
	{
		_stack = [NSMutableArray array];
		_rootObject = object;
	}
	
	[_currentContainer addObject:object];
}

- (void)_popContainer
{
	[_stack removeLastObject];
	_currentContainer = [_stack lastObject];
}

#pragma mark - DTASN1 Parser Delegate

- (void)parser:(DODTASN1Parser *)parser didStartContainerWithType:(DTASN1Type)type
{
	NSMutableArray *newContainer = [NSMutableArray array];
	[self _pushContainer:newContainer];
}

- (void)parser:(DODTASN1Parser *)parser didEndContainerWithType:(DTASN1Type)type
{
	[self _popContainer];
}

- (void)parser:(DODTASN1Parser *)parser didStartContextWithTag:(NSUInteger)tag constructed:(BOOL)constructed
{
	NSNumber *tagNumber = [NSNumber numberWithUnsignedInteger:tag];
	
	NSMutableArray *newContainer = [NSMutableArray array];
	NSDictionary *dictionary = [NSDictionary dictionaryWithObject:newContainer forKey:tagNumber];
	
	[self _pushContainer:dictionary];
	_currentContainer = newContainer;
}

- (void)parser:(DODTASN1Parser *)parser didEndContextWithTag:(NSUInteger)tag constructed:(BOOL)constructed
{
	[self _popContainer];
}

- (void)parserFoundNull:(DODTASN1Parser *)parser
{
	[self _addObjectToCurrentContainer:[NSNull null]];
}

- (void)parser:(DODTASN1Parser *)parser foundDate:(NSDate *)date
{
	[self _addObjectToCurrentContainer:date];
}

- (void)parser:(DODTASN1Parser *)parser foundObjectIdentifier:(NSString *)objIdentifier
{
	[self _addObjectToCurrentContainer:objIdentifier];
}

- (void)parser:(DODTASN1Parser *)parser foundString:(NSString *)string
{
	[self _addObjectToCurrentContainer:string];
}

- (void)parser:(DODTASN1Parser *)parser foundData:(NSData *)data
{
	[self _addObjectToCurrentContainer:data];
}

- (void)parser:(DODTASN1Parser *)parser foundBitString:(DODTASN1BitString *)bitString
{
	[self _addObjectToCurrentContainer:bitString];
}

- (void)parser:(DODTASN1Parser *)parser foundNumber:(NSNumber *)number
{
	[self _addObjectToCurrentContainer:number];
}

@end
