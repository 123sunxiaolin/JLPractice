//
//  JLSearchBar.h
//  JLSrearchController
//
//  Created by perfect on 2017/5/22.
//  Copyright © 2017年 JackLin. All rights reserved.
//

#import <UIKit/UIKit.h>
@class JLSearchBar;

@protocol JLSearchBarDelegete <NSObject>

@optional
- (void)searchBarTextDidBeginEditing:(JLSearchBar *)searchBar;
- (void)searchBarTextDidEndEditing:(JLSearchBar *)searchBar;
- (void)searchBar:(JLSearchBar *)searchBar textDidChange:(NSString *)searchText;

@end

@interface JLSearchBar : UIView

@property (nonatomic, strong) NSString *placeholder;
@property (nonatomic, weak) id<JLSearchBarDelegete> delegate;
@property (nonatomic, strong) NSString *text;

@end
