//
//  DTDictationPlaceholderView.h
//  DTRichTextEditor
//
//  Created by Oliver Drobnik on 05.02.13.
//  Copyright (c) 2013 Cocoanetics. All rights reserved.
//

/**
 A dictation placeholder to display in editors between the time the recording is complete until a recognized response is received.
 */

@interface DODTDictationPlaceholderView : UIView

/**
 Creates an appropriately sized DTDictationPlaceholderView with 3 animated purple dots
 */
+ (DODTDictationPlaceholderView *)placeholderView;

/**
 The context of the receiver. This can be any object, for example the selection range to replace with the dictation result text
 */
@property (nonatomic, strong) id context;

@end
