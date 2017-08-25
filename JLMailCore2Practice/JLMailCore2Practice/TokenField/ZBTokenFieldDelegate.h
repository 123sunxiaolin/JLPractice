//
//  ZBTokenFieldDelegate.h
//  JLMailCore2Practice
//
//  Created by perfect on 2017/6/26.
//  Copyright © 2017年 JackLin. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ZBToken, ZBTokenField;

@protocol ZBTokenFieldDelegate <UITextFieldDelegate>

@optional
- (BOOL)tokenField:(ZBTokenField *)tokenField willAddToken:(ZBToken *)token;
- (void)tokenField:(ZBTokenField *)tokenField didAddToken:(ZBToken *)token;
- (BOOL)tokenField:(ZBTokenField *)tokenField willRemoveToken:(ZBToken *)token;
- (void)tokenField:(ZBTokenField *)tokenField didRemoveToken:(ZBToken *)token;

- (void)tokenField:(ZBTokenField *)tokenField didTapToken:(ZBToken *)token;

- (BOOL)tokenField:(ZBTokenField *)field shouldUseCustomSearchForSearchString:(NSString *)searchString;
- (void)tokenField:(ZBTokenField *)field performCustomSearchForSearchString:(NSString *)searchString withCompletionHandler:(void (^)(NSArray *results))completionHandler;

- (void)tokenField:(ZBTokenField *)tokenField didFinishSearch:(NSArray *)matches;
- (NSString *)tokenField:(ZBTokenField *)tokenField displayStringForRepresentedObject:(id)object;
- (NSString *)tokenField:(ZBTokenField *)tokenField searchResultStringForRepresentedObject:(id)object;
- (NSString *)tokenField:(ZBTokenField *)tokenField searchResultSubtitleForRepresentedObject:(id)object;
- (UIImage *)tokenField:(ZBTokenField *)tokenField searchResultImageForRepresentedObject:(id)object;
- (UITableViewCell *)tokenField:(ZBTokenField *)tokenField resultsTableView:(UITableView *)tableView cellForRepresentedObject:(id)object;
- (CGFloat)tokenField:(ZBTokenField *)tokenField resultsTableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;

@end
