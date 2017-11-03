//
//  DTScriptExpression.h
//  DTFoundation
//
//  Created by Oliver Drobnik on 10/17/12.
//  Copyright (c) 2012 Cocoanetics. All rights reserved.
//

#import "DODTScriptVariable.h"

typedef void (^DTScriptExpressionParameterEnumerationBlock) (NSString *paramName, DODTScriptVariable *variable, BOOL *stop);

/**
 Instances of this class represent a single Objective-C script expression
 */

@interface DODTScriptExpression : NSObject


/**
 Creates a script expression from an `NSString`
 @param string A string representing an Object-C command including square brackets.
 */
+ (DODTScriptExpression *)scriptExpressionWithString:(NSString *)string;

/**
 Creates a script expression from an `NSString`
 @param string A string representing an Object-C command including square brackets.
 */
- (id)initWithString:(NSString *)string;

/**
 The parameters of the script expression
 */
@property (nonatomic, readonly) NSArray *parameters;

/**
 Enumerates the script parameters and executes the block for each parameter.
 @param block The block to be executed for each parameter
 */
- (void)enumerateParametersWithBlock:(DTScriptExpressionParameterEnumerationBlock)block;

/**
 Accesses the receiver of the expression
 */
@property (nonatomic, readonly) DODTScriptVariable *receiver;

/**
 The method selector
 */
- (SEL)selector;

@end
