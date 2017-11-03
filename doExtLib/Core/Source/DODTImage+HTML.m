//
//  DTImage+HTML.m
//  DTCoreText
//
//  Created by Oliver Drobnik on 31.01.12.
//  Copyright (c) 2012 Drobnik.com. All rights reserved.
//

#import "DODTImage+HTML.h"

@implementation UIImage (HTML)

- (NSData *)dataForPNGRepresentation
{
	return UIImagePNGRepresentation(self);
}

@end