//
//  do_RichLabel_UI.h
//  DoExt_UI
//
//  Created by @userName on @time.
//  Copyright (c) 2015年 DoExt. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol do_RichLabel_IView <NSObject>

@required
//属性方法
- (void)change_text:(NSString *)newValue;

//同步或异步方法


@end