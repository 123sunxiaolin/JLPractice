//
//  UIView+JLTouch.h
//  JLSrearchController
//
//  Created by perfect on 2017/5/22.
//  Copyright © 2017年 JackLin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (JLTouch)

// 是否能够响应touch事件
@property (nonatomic, assign) BOOL unTouch;
// 不响应touch事件的区域
@property (nonatomic, assign) CGRect unTouchRect;

@end
