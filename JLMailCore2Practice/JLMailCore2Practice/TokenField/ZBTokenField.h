//
//  ZBTokenField.h
//  JLMailCore2Practice
//
//  Created by perfect on 2017/6/26.
//  Copyright © 2017年 JackLin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZBTokenFieldDelegate.h"

typedef enum {
    ZBTokenFieldControlEventFrameWillChange = 1 << 24,
    ZBTokenFieldControlEventFrameDidChange = 1 << 25,
} ZBTokenFieldControlEvents;

@class ZBToken;
@interface ZBTokenField : UITextField

@property (nonatomic, assign) BOOL forcePickSearchResult;
@property (nonatomic, assign) BOOL alwaysShowSearchResult;

@property (nonatomic, weak) id <ZBTokenFieldDelegate> delegate;
@property (weak, nonatomic, readonly) NSArray * tokens;
@property (weak, nonatomic, readonly) ZBToken * selectedToken;
@property (weak, nonatomic, readonly) NSArray * tokenTitles;
@property (weak, nonatomic, readonly) NSArray * tokenObjects;
@property (nonatomic, assign) BOOL showShadow;
@property (nonatomic, assign) BOOL editable;
@property (nonatomic, assign) BOOL resultsModeEnabled;
@property (nonatomic, assign) BOOL removesTokensOnEndEditing;
@property (nonatomic, readonly) int numberOfLines;
@property (nonatomic) int tokenLimit;
@property (nonatomic, strong) NSCharacterSet * tokenizingCharacters;
@property (strong, nonatomic) UIColor *promptColor;
// Pass nil to hide label
@property (strong, nonatomic) NSString *promptText;

- (void)addToken:(ZBToken *)title;
- (ZBToken *)addTokenWithTitle:(NSString *)title;
- (ZBToken *)addTokenWithTitle:(NSString *)title representedObject:(id)object;
- (void)addTokensWithTitleList:(NSString *)titleList;
- (void)addTokensWithTitleArray:(NSArray *)titleArray;
- (void)removeToken:(ZBToken *)token;
- (void)removeAllTokens;

- (void)selectToken:(ZBToken *)token;
- (void)deselectSelectedToken;

- (void)tokenizeText;

- (void)layoutTokensAnimated:(BOOL)animated;
- (void)setResultsModeEnabled:(BOOL)enabled animated:(BOOL)animated;

@end
