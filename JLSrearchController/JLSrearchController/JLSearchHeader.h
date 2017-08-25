//
//  JLSearchHeader.h
//  JLSrearchController
//
//  Created by perfect on 2017/5/22.
//  Copyright © 2017年 JackLin. All rights reserved.
//

#ifndef JLSearchHeader_h
#define JLSearchHeader_h

#define kScreenWidth [[UIScreen mainScreen] bounds].size.width
#define kScreenHeight [[UIScreen mainScreen] bounds].size.height

#define UIColorFromRGBA(rgbValue, alphaValue) [UIColor \
colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0x00FF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0x0000FF))/255.0 \
alpha:alphaValue]

#define UIColorFromRGB(rgbValue) UIColorFromRGBA(rgbValue, 1.0)

#define JLColor(r,g,b,a) [UIColor colorWithRed:r green:g blue:b alpha:a]

#import "UIView+Frame.h"
#import "UIView+JLTouch.h"
#import "UIView+JLViewController.h"
#import "UIViewController+JLStatusBarStyle.h"

#endif /* JLSearchHeader_h */
