//
//  DTObjectBlockExecutor.m
//  DTFoundation
//
//  Created by Oliver Drobnik on 12.02.13.
//  Copyright (c) 2013 Cocoanetics. All rights reserved.
//

#import "DODTObjectBlockExecutor.h"


@implementation DODTObjectBlockExecutor

+ (id)blockExecutorWithDeallocBlock:(void(^)())block
{
    DODTObjectBlockExecutor *executor = [[DODTObjectBlockExecutor alloc] init];
    executor.deallocBlock = block; // copy
    return executor;
}

- (void)dealloc
{
    if (_deallocBlock)
    {
        _deallocBlock();
        _deallocBlock = nil;
    }
}

@end
