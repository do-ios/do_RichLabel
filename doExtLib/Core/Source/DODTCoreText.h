#if TARGET_OS_IPHONE
#import <CoreText/CoreText.h>
#elif TARGET_OS_MAC
#import <ApplicationServices/ApplicationServices.h>
#endif

// global constants
#import "DODTCoreTextMacros.h"
#import "DODTCoreTextConstants.h"
#import "DODTCompatibility.h"

#import "DODTColor+Compatibility.h"
#import "DODTImage+HTML.h"

// common utilities
#if TARGET_OS_IPHONE
#import "DODTCoreTextFunctions.h"
#endif

#import "DODTColorFunctions.h"

// common classes
#import "DODTCSSListStyle.h"
#import "DODTTextBlock.h"
#import "DODTCSSStylesheet.h"
#import "DODTCoreTextFontDescriptor.h"
#import "DODTCoreTextParagraphStyle.h"
#import "DODTHTMLAttributedStringBuilder.h"
#import "DODTHTMLElement.h"
#import "DODTHTMLWriter.h"
#import "NSCharacterSet+HTML.h"
#import "NSDictionary+DTCoreText.h"
#import "NSAttributedString+HTML.h"
#import "NSAttributedString+SmallCaps.h"
#import "NSAttributedString+DTCoreText.h"
#import "NSMutableAttributedString+HTML.h"
#import "NSMutableString+HTML.h"
#import "NSScanner+HTML.h"
#import "NSString+CSS.h"
#import "NSString+HTML.h"
#import "NSString+Paragraphs.h"

// parsing classes
#import "DODTHTMLParserNode.h"
#import "DODTHTMLParserTextNode.h"

// text attachment cluster
#import "DODTTextAttachment.h"
#import "DODTDictationPlaceholderTextAttachment.h"
#import "DODTIframeTextAttachment.h"
#import "DODTImageTextAttachment.h"
#import "DODTObjectTextAttachment.h"
#import "DODTVideoTextAttachment.h"

// These classes only work with UIKit on iOS
#if TARGET_OS_IPHONE

#import "DODTLazyImageView.h"
#import "DODTLinkButton.h"
#import "DODTWebVideoView.h"
#import "NSAttributedStringRunDelegates.h"

#import "DODTAttributedLabel.h"
#import "DODTAttributedTextCell.h"
#import "DODTAttributedTextContentView.h"
#import "DODTAttributedTextView.h"
#import "DODTCoreTextFontCollection.h"
#import "DODTCoreTextGlyphRun.h"
#import "DODTCoreTextLayoutFrame.h"
#import "DODTCoreTextLayoutFrame+Cursor.h"
#import "DODTCoreTextLayoutLine.h"
#import "DODTCoreTextLayouter.h"

#import "DODTDictationPlaceholderView.h"

#import "UIFont+DTCoreText.h"

#endif

