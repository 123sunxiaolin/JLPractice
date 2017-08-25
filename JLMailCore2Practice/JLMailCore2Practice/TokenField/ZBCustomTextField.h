//
//  ZBCustomTextField.h
//  JLMailCore2Practice
//
//  Created by perfect on 2017/6/27.
//  Copyright © 2017年 JackLin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZBCustomTextField : UITextField

/**
 左侧标题，设置为nil时隐藏该Label
 */
@property (nonatomic, strong) NSString *promptText;

/**
 左侧标题颜色
 */
@property (nonatomic, strong) UIColor *promptColor;

@end
