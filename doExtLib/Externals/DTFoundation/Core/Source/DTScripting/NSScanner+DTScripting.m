//
//  NSScanner+DTScripting.m
//  DTFoundation
//
//  Created by Oliver Drobnik on 10/18/12.
//  Copyright (c) 2012 Cocoanetics. All rights reserved.
//

#import "NSScanner+DTScripting.h"
#import "DODTScriptVariable.h"
#import "DODTLog.h"

@implementation NSScanner (DTScripting)

- (BOOL)scanScriptVariable:(DODTScriptVariable **)variable
{
	DODTScriptVariable *returnVariable = nil;
	
	NSUInteger previousScanLocation = self.scanLocation;
	
	// determine what we are looking at
	NSDecimal decimalNumber;
	
	if ([self scanString:@"@\"" intoString:nil])
	{
		// string parameter
		// scan until the first whitespace or ]
		
		NSMutableString *string = [NSMutableString stringWithString:@""];
		
		BOOL stringIsTerminated = NO;
		
		while (!stringIsTerminated)
		{
			NSString *part = nil;
			if ([self scanUpToString:@"\"" intoString:&part])
			{
				[string appendString:part];
			}
			
			if ([self scanString:@"\"" intoString:NULL])
			{
				stringIsTerminated = YES;
			}
			
			if (!part && !stringIsTerminated)
			{
				self.scanLocation = previousScanLocation;
				DTLogError(@"Unterminated string at position %d in string '%@'", (int)[self scanLocation], self.string);
				return NO;
			}
		}
		
		returnVariable = [DODTScriptVariable scriptVariableWithName:nil value:string];
	}
	else if ([self scanDecimal:&decimalNumber])
	{
		returnVariable = [DODTScriptVariable scriptVariableWithName:nil value:[NSDecimalNumber decimalNumberWithDecimal:decimalNumber]];
	}
	else
	{
		NSString *parameter = nil;
		if ([self scanCharactersFromSet:[NSCharacterSet alphanumericCharacterSet] intoString:&parameter])
		{
			if ([parameter isEqualToString:@"YES"])
			{
				returnVariable = [DODTScriptVariable scriptVariableWithName:nil value:[NSNumber numberWithBool:YES]];
			}
			else if ([parameter isEqualToString:@"NO"])
			{
				returnVariable = [DODTScriptVariable scriptVariableWithName:nil value:[NSNumber numberWithBool:NO]];
			}
			else if ([parameter isEqualToString:@"nil"])
			{
				returnVariable = [DODTScriptVariable scriptVariableWithName:nil value:[NSNull null]];
			}
			else
			{
				// store variable
				returnVariable = [DODTScriptVariable scriptVariableWithName:parameter value:nil];
			}
		}
		else
		{
			self.scanLocation = previousScanLocation;
			DTLogError(@"Illegal character in parameter at position %d in string '%@'", (int)[self scanLocation], self.string);
			return NO;
		}
	}
	
	if (variable)
	{
		*variable = returnVariable;
	}
	
	return YES;
}

@end
