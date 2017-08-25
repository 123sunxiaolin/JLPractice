//
//  ZBToken.h
//  JLMailCore2Practice
//
//  Created by perfect on 2017/6/26.
//  Copyright © 2017年 JackLin. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, ZBTokenAccessoryType){
    ZBTokenAccessoryTypeNone = 0,
    ZBTokenAccessoryTypeDisclosureIndicator = 1,
};

@interface ZBToken : UIControl

@property (nonatomic, copy) NSString * title;
@property (nonatomic, strong) id representedObject;
@property (nonatomic, strong) UIFont * font;
@property (nonatomic, strong) UIColor * textColor UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIColor * highlightedTextColor UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIColor * tintColor UI_APPEARANCE_SELECTOR;
@property (nonatomic, assign) ZBTokenAccessoryType accessoryType;
@property (nonatomic, assign) CGFloat maxWidth;

- (instancetype)initWithTitle:(NSString *)aTitle;
- (instancetype)initWithTitle:(NSString *)aTitle representedObject:(id)object;
- (instancetype)initWithTitle:(NSString *)aTitle representedObject:(id)object font:(UIFont *)aFont;

+ (UIColor *)blueTintColor;
+ (UIColor *)redTintColor;
+ (UIColor *)greenTintColor;

@end
