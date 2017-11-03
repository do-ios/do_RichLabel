//
//  do_RichLabel_View.m
//  DoExt_UI
//
//  Created by @userName on @time.
//  Copyright (c) 2015年 DoExt. All rights reserved.
//

#import "do_RichLabel_UIView.h"

#import "doInvokeResult.h"
#import "doUIModuleHelper.h"
#import "doScriptEngineHelper.h"
#import "doIScriptEngine.h"

#import <QuartzCore/QuartzCore.h>
#import <MediaPlayer/MediaPlayer.h>

#import "DODTTiledLayerWithoutFade.h"
#import "DODTAttributedTextView.h"
#import "DODTLazyImageView.h"
#import "DODTTextAttachment.h"
#import "DODTImageTextAttachment.h"

#define LINK_EVENT @"linkTouch"

@interface do_RichLabel_UIView()<DTAttributedTextContentViewDelegate, DODTLazyImageViewDelegate,DODTLazyImageViewDelegate>
- (void)linkPushed:(DODTLinkButton *)button;
@end

@implementation do_RichLabel_UIView
{
	DODTAttributedTextView *_textView;
    
    doInvokeResult * _invokeResults;
    
    NSString *_content;
    
    BOOL _isObserver;
}
#pragma mark - doIUIModuleView协议方法（必须）
//引用Model对象
- (void) LoadView: (doUIModule *) _doUIModule
{
    _model = (typeof(_model)) _doUIModule;
    _do_extern_RichLabelModel = _model;
    [self initialization];
}

- (void)initialization
{
    _content = @"";
    _textView = [[DODTAttributedTextView alloc] initWithFrame:self.bounds];
    _textView.scrollsToTop = NO;
    _textView.userInteractionEnabled = YES;
    _textView.scrollEnabled = NO;
    _textView.shouldDrawImages = NO;
    _textView.shouldDrawLinks = NO;
    _textView.textDelegate = self;
    _textView.backgroundColor = [UIColor clearColor];

    [self addSubview:_textView];
    _isObserver = NO;
    if ([self isAutoHeight]) {
        _isObserver = YES;
        [_textView addObserver:self forKeyPath:@"contentSize" options:NSKeyValueObservingOptionNew context:NULL];
    }
}
- (BOOL)isAutoHeight
{
    CGFloat h = [[_model GetPropertyValue:@"height"] floatValue];
    if (h<=0) {
        return YES;
    }
    return NO;
}
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    NSValue *size = [change objectForKey:@"new"];
    
    UIView *superView = self.superview;
    if (superView && [self isAutoHeight]) {
//        CGFloat inSuperViewHeight = CGRectGetHeight(superView.frame)-CGRectGetMinY(self.frame);
        
        CGRect r = self.frame;
        r.size.height = [size CGSizeValue].height;

        self.frame = r;
        _textView.frame = self.bounds;
        
        [doUIModuleHelper OnResize:_model];
    }
}
//销毁所有的全局对象
- (void) OnDispose
{
    //自定义的全局属性,view-model(UIModel)类销毁时会递归调用<子view-model(UIModel)>的该方法，将上层的引用切断。所以如果self类有非原生扩展，需主动调用view-model(UIModel)的该方法。(App || Page)-->强引用-->view-model(UIModel)-->强引用-->view
    _model = nil;
    _do_extern_RichLabelModel = nil;

    if (_isObserver) {
        [_textView removeObserver:self forKeyPath:@"contentSize"];
    }
    [self removeSubviews:self];
    _textView = nil;
}

-(void)removeSubviews:(UIView *)subViews
{
    if (subViews.subviews.count>0) {
        for (UIView *views in subViews.subviews) {
            [self removeSubviews:views];
        }
    }else
    {
        [subViews removeFromSuperview];
    }  
}
//实现布局
- (void) OnRedraw
{
    //实现布局相关的修改,如果添加了非原生的view需要主动调用该view的OnRedraw，递归完成布局。view(OnRedraw)<显示布局>-->调用-->view-model(UIModel)<OnRedraw>
    
    //重新调整视图的x,y,w,h
    [doUIModuleHelper OnRedraw:_model];
    _textView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    if ([self isAutoHeight]) {
        CGRect r = self.bounds;
        r.size.height = 1000;
        _textView.frame = r;
    }else{
        _textView.frame = self.bounds;
    }
    _textView.attributedString = [self _attributedStringForSnippetUsingiOS6Attributes:NO text:_content];
}
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    UIView *view = [super hitTest:point withEvent:event];
    
    if ([view isKindOfClass:[DODTLinkButton class]]) {
        return view;
    }
//    if (_textView.contentSize.height>CGRectGetHeight(_textView.bounds)) {
//        return view;
//    }
    if (view) {
        return view.superview.superview.superview;
    }else
        return nil;
}
#pragma mark - TYPEID_IView协议方法（必须）
#pragma mark - Changed_属性
/*
 如果在Model及父类中注册过 "属性"，可用这种方法获取
 NSString *属性名 = [(doUIModule *)_model GetPropertyValue:@"属性名"];
 
 获取属性最初的默认值
 NSString *属性名 = [(doUIModule *)_model GetProperty:@"属性名"].DefaultValue;
 */

- (void)change_text:(NSString *)newValue
{
    //自己的代码实现
    _content = newValue;
    if (CGRectGetWidth(self.frame)>0) {
        _textView.attributedString = [self _attributedStringForSnippetUsingiOS6Attributes:NO text:_content];
    }
}


#pragma mark Custom Views on Text

- (UIView *)attributedTextContentView:(DODTAttributedTextContentView *)attributedTextContentView viewForAttributedString:(NSAttributedString *)string frame:(CGRect)frame
{
    NSDictionary *attributes = [string attributesAtIndex:0 effectiveRange:NULL];
    
    NSURL *URL = [attributes objectForKey:DTLinkAttribute];
    NSString *identifier = [attributes objectForKey:DTGUIDAttribute];
    NSString *anchorId = [attributes objectForKey:DTAnchorAttributeId];

    DODTLinkButton *button = [[DODTLinkButton alloc] initWithFrame:frame];
    button.titleLabel.text = string.string;
    button.URL = URL;
    button.minimumHitSize = CGSizeMake(25, 25); // adjusts it's bounds so that button is always large enough
    button.GUID = identifier;
    button.anchorId = anchorId;
    
    // get image with normal link text
    UIImage *normalImage = [attributedTextContentView contentImageWithBounds:frame options:DTCoreTextLayoutFrameDrawingDefault];
    [button setImage:normalImage forState:UIControlStateNormal];
    
    // get image for highlighted link text
    UIImage *highlightImage = [attributedTextContentView contentImageWithBounds:frame options:DTCoreTextLayoutFrameDrawingDrawLinksHighlighted];
    [button setImage:highlightImage forState:UIControlStateHighlighted];
    
    // use normal push action for opening URL
    [button addTarget:self action:@selector(linkPushed:) forControlEvents:UIControlEventTouchUpInside];
    
    return button;
}

- (BOOL)attributedTextContentView:(DODTAttributedTextContentView *)attributedTextContentView shouldDrawBackgroundForTextBlock:(DODTTextBlock *)textBlock frame:(CGRect)frame context:(CGContextRef)context forLayoutFrame:(DODTCoreTextLayoutFrame *)layoutFrame
{
    UIBezierPath *roundedRect = [UIBezierPath bezierPathWithRoundedRect:CGRectInset(frame,1,1) cornerRadius:10];
    
    CGColorRef color = [textBlock.backgroundColor CGColor];
    if (color)
    {
        CGContextSetFillColorWithColor(context, color);
        CGContextAddPath(context, [roundedRect CGPath]);
        CGContextFillPath(context);
        
        CGContextAddPath(context, [roundedRect CGPath]);
        CGContextSetRGBStrokeColor(context, 0, 0, 0, 1);
        CGContextStrokePath(context);
        return NO;
    }
    
    return YES; // draw standard background
}


- (NSAttributedString *)_attributedStringForSnippetUsingiOS6Attributes:(BOOL)useiOS6Attributes text:(NSString *)content
{
    // Load HTML data
//    NSString *readmePath = [[NSBundle mainBundle] pathForResource:@"CurrentTest.html" ofType:nil];
//    NSString *html = [NSString stringWithContentsOfFile:content encoding:NSUTF8StringEncoding error:NULL];
    NSData *data = [content dataUsingEncoding:NSUTF8StringEncoding];
    
    // Create attributed string from HTML
    CGFloat w = CGRectGetWidth(self.bounds);
    CGFloat h = -1;
    CGSize maxImageSize = CGSizeMake(w, h);
    
    // example for setting a willFlushCallback, that gets called before elements are written to the generated attributed string
    void (^callBackBlock)(DODTHTMLElement *element) = ^(DODTHTMLElement *element) {
        
        // the block is being called for an entire paragraph, so we check the individual elements
        
        for (DODTHTMLElement *oneChildElement in element.childNodes)
        {
            // if an element is larger than twice the font size put it in it's own block
            if (oneChildElement.displayStyle == DTHTMLElementDisplayStyleInline && oneChildElement.textAttachment.displaySize.height > 2.0 * oneChildElement.fontDescriptor.pointSize)
            {
                oneChildElement.displayStyle = DTHTMLElementDisplayStyleBlock;
                oneChildElement.paragraphStyle.minimumLineHeight = element.textAttachment.displaySize.height;
                oneChildElement.paragraphStyle.maximumLineHeight = element.textAttachment.displaySize.height;
            }
        }
    };
    
    NSMutableDictionary *options = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithFloat:1.0], NSTextSizeMultiplierDocumentOption, [NSValue valueWithCGSize:maxImageSize], DTMaxImageSize,@"Times New Roman", DTDefaultFontFamily,  @"blue", DTDefaultLinkColor, @"red", DTDefaultLinkHighlightColor, callBackBlock, DTWillFlushBlockCallBack, nil];

    NSAttributedString *string = [[NSAttributedString alloc] initWithHTMLData:data options:options documentAttributes:NULL];
    
    return string;
}


#pragma mark Actions
- (void)linkPushed:(DODTLinkButton *)button
{
    NSURL *URL = button.URL;
    NSString *href = URL.absoluteString;
    if (!href) {
        href = @"";
    }
    NSString *anchorId = button.anchorId;
    if (!anchorId) {
        anchorId = @"";
    }
    NSString *value = button.titleLabel.text;
    if (!value) {
        value = @"";
    }

    if (!_invokeResults) {
        _invokeResults = [[doInvokeResult alloc]init:_model.UniqueKey];
    }
    
    if (![href isEqualToString:@""]) {
        if ([[UIApplication sharedApplication] canOpenURL:[URL absoluteURL]])
        {
            [[UIApplication sharedApplication] openURL:[URL absoluteURL]];
        }else{
            NSDictionary *dic = @{@"href":href,@"id":anchorId,@"value":value};
            [_invokeResults SetResultNode:dic];
            [_model.EventCenter FireEvent:LINK_EVENT :_invokeResults];
        }
    }
}

- (UIView *)attributedTextContentView:(DODTAttributedTextContentView *)attributedTextContentView viewForAttachment:(DODTTextAttachment *)attachment frame:(CGRect)frame
{
    
    if ([attachment isKindOfClass:[DODTImageTextAttachment class]])
    {
        DODTLazyImageView *imageView = [[DODTLazyImageView alloc] initWithFrame:frame];
        imageView.delegate = self;

        imageView.image = [(DODTImageTextAttachment *)attachment image];

        imageView.url = attachment.contentURL;
        imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth;

        return imageView;
    }
    
    return nil;
}

- (void)lazyImageView:(DODTLazyImageView *)lazyImageView didChangeImageSize:(CGSize)size {
    NSURL *url = lazyImageView.url;
    CGSize imageSize = size;
    
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"contentURL == %@", url];
    
    BOOL didUpdate = NO;

    for (DODTTextAttachment *oneAttachment in [_textView.attributedTextContentView.layoutFrame textAttachmentsWithPredicate:pred])
    {
        if (CGSizeEqualToSize(oneAttachment.originalSize, CGSizeZero))
        {
            oneAttachment.originalSize = imageSize;
            
            didUpdate = YES;
        }
    }
    
    if (didUpdate)
    {
        [_textView relayoutText];
    }
}
#pragma mark - doIUIModuleView协议方法（必须）<大部分情况不需修改>
- (BOOL) OnPropertiesChanging: (NSMutableDictionary *) _changedValues
{
    //属性改变时,返回NO，将不会执行Changed方法
    return YES;
}
- (void) OnPropertiesChanged: (NSMutableDictionary*) _changedValues
{
    //_model的属性进行修改，同时调用self的对应的属性方法，修改视图
    [doUIModuleHelper HandleViewProperChanged: self :_model : _changedValues ];
}
- (BOOL) InvokeSyncMethod: (NSString *) _methodName : (NSDictionary *)_dicParas :(id<doIScriptEngine>)_scriptEngine : (doInvokeResult *) _invokeResult
{
    //同步消息
    return [doScriptEngineHelper InvokeSyncSelector:self : _methodName :_dicParas :_scriptEngine :_invokeResult];
}
- (BOOL) InvokeAsyncMethod: (NSString *) _methodName : (NSDictionary *) _dicParas :(id<doIScriptEngine>) _scriptEngine : (NSString *) _callbackFuncName
{
    //异步消息
    return [doScriptEngineHelper InvokeASyncSelector:self : _methodName :_dicParas :_scriptEngine: _callbackFuncName];
}
- (doUIModule *) GetModel
{
    //获取model对象
    return _model;
}

@end
