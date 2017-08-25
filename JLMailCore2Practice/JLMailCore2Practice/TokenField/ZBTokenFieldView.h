//
//  ZBTokenFieldView.h
//  JLMailCore2Practice
//
//  Created by perfect on 2017/6/26.
//  Copyright © 2017年 JackLin. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ZBTokenField;
@interface ZBTokenFieldView : UIScrollView

@property (nonatomic, assign) BOOL showAlreadyTokenized;
@property (nonatomic, assign) BOOL searchSubtitles;
@property (nonatomic, assign) BOOL subtitleIsPhoneNumber;
@property (nonatomic, assign) BOOL forcePickSearchResult;
@property (nonatomic, assign) BOOL alwaysShowSearchResult;
@property (nonatomic, assign) BOOL shouldSortResults;
@property (nonatomic, assign) BOOL shouldSearchInBackground;
@property (nonatomic, assign) BOOL shouldAlwaysShowSeparator;
@property (nonatomic, assign) UIPopoverArrowDirection permittedArrowDirections;
@property (nonatomic, readonly) ZBTokenField * tokenField;
@property (nonatomic, readonly) UIView * separator;
@property (nonatomic, readonly) UIView * tableHeader;
@property (nonatomic, readonly) UITableView * resultsTable;
@property (nonatomic, readonly) UIView * contentView;
@property (nonatomic, copy) NSArray * sourceArray;
@property (weak, nonatomic, readonly) NSArray * tokenTitles;

- (void)updateContentSize;

@end
