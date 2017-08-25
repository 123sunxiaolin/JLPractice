//
//  ZBTokenFieldInternalDelegate.h
//  JLMailCore2Practice
//
//  Created by perfect on 2017/6/26.
//  Copyright © 2017年 JackLin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

extern NSString * const kTextEmpty; // Zero-Width Space
extern NSString * const kTextHidden; // Zero-Width Joiner

@class ZBTokenField;
@interface ZBTokenFieldInternalDelegate : NSObject<UITextFieldDelegate>

@property (nonatomic, weak) ZBTokenField * tokenField;
@property (nonatomic, weak) id <UITextFieldDelegate> delegate;

@end
