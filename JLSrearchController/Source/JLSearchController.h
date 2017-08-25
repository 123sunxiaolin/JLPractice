//
//  JLSearchController.h
//  JLSrearchController
//
//  Created by perfect on 2017/5/22.
//  Copyright © 2017年 JackLin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JLSearchBar.h"
@class JLSearchController;

@protocol JLSearchControllerDelegate <NSObject>

@optional
- (void)willPresentSearchController:(JLSearchController *)searchController;
- (void)didPresentSearchController:(JLSearchController *)searchController;
- (void)willDismissSearchController:(JLSearchController *)searchController;
- (void)didDismissSearchController:(JLSearchController *)searchController;

@end

@protocol JLSearchControllerhResultsUpdating <NSObject>

@required
- (void)updateSearchResultsForSearchController:(JLSearchController *)searchController;

@end

@interface JLSearchController : UIViewController

@property (nonatomic, strong) JLSearchBar *searchBar;
@property (nonatomic, assign) BOOL hidesNavigationBarDuringPresentation;
@property (nonatomic, weak) id<JLSearchControllerDelegate> delegate;
@property (nonatomic, weak) id<JLSearchControllerhResultsUpdating> searchResultsUpdater;
@property (nonatomic, strong) UIViewController *searchResultsController;

- (instancetype)initWithSearchResultsController:(UIViewController *)searchResultsController;

@end
