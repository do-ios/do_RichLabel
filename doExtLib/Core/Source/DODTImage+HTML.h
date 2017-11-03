//
//  DTImage+HTML.h
//  DTCoreText
//
//  Created by Oliver Drobnik on 1/9/11.
//  Copyright 2011 Drobnik.com. All rights reserved.
//

/**
 Category used to have the same method available for unit testing on Mac on iOS.
 */
@interface UIImage (HTML)

/** 
 Retrieve the NSData representation of a UIImage. Used to encode UIImages in DTTextAttachments.
 
 @returns The NSData representation of the UIImage instance receiving this message. Convenience method for UIImagePNGRepresentation(). 
 */
- (NSData *)dataForPNGRepresentation;

@end
