//
//  do_RichLabel_View.h
//  DoExt_UI
//
//  Created by @userName on @time.
//  Copyright (c) 2015年 DoExt. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "do_RichLabel_IView.h"
#import "do_RichLabel_UIModel.h"
#import "doIUIModuleView.h"

do_RichLabel_UIModel *_do_extern_RichLabelModel;

@interface do_RichLabel_UIView : UIView<do_RichLabel_IView, doIUIModuleView>
//可根据具体实现替换UIView
{
	@private
		__weak do_RichLabel_UIModel *_model;
}

@end
