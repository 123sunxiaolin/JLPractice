//
//  JLSearchController.m
//  JLSrearchController
//
//  Created by perfect on 2017/5/22.
//  Copyright © 2017年 JackLin. All rights reserved.
//

#import "JLSearchController.h"

NSString *SEARCH_CANCEL_NOTIFICATION_KEY = @"SEARCH_CANCEL_NOTIFICATION_KEY";

@interface JLSearchController ()

@property (nonatomic, strong) UIView *bgView;

@end

@implementation JLSearchController

- (instancetype)initWithSearchResultsController:(UIViewController *)searchResultsController {
    self = [super init];
    self.searchResultsController = searchResultsController;
    return self;
}

#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    [super viewDidLoad];
    [self.view addSubview:self.bgView];
    self.view.unTouchRect = CGRectMake(0, 0, self.view.width, 64);
    self.searchResultsController.view.frame = self.bgView.bounds;
    [self.bgView addSubview:self.searchResultsController.view];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(endSearch) name:SEARCH_CANCEL_NOTIFICATION_KEY object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Getters
- (JLSearchBar *)searchBar{
    if (!_searchBar) {
        _searchBar = [[JLSearchBar alloc] init];
        [_searchBar addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapSearchBarAction)]];
        [_searchBar addObserver:self forKeyPath:@"text" options:NSKeyValueObservingOptionNew context:nil];
    }
    return _searchBar;
}

- (UIView *)bgView {
    if (!_bgView) {
        _bgView = [[UIView alloc] init];
        _bgView.frame = CGRectMake(0, CGRectGetMaxY(self.searchBar.frame) + 64, kScreenWidth, kScreenHeight - self.searchBar.frame.size.height);
        _bgView.backgroundColor = [UIColor lightGrayColor];
        [_bgView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(endSearchTextFieldEditing)]];
    }
    return _bgView;
}
#pragma mark - Action Method
- (void)tapSearchBarAction {
    if ([self.delegate respondsToSelector:@selector(willPresentSearchController:)]) [self.delegate willPresentSearchController:self];
    self.searchBar.jl_viewController.jl_lightStatusBar = NO;
    [self.searchBar addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handGesture)]];
    [self.searchBar addGestureRecognizer:[[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handGesture)]];
    [[UIApplication sharedApplication].keyWindow.rootViewController.view addSubview:self.view];
    if ([self.delegate respondsToSelector:@selector(didPresentSearchController:)]) [self.delegate didPresentSearchController:self];
    [self.searchBar setValue:@1 forKey:@"isEditing"];
    if (self.searchBar.jl_viewController.parentViewController && [self.searchBar.jl_viewController.parentViewController isKindOfClass:[UINavigationController class]] && self.hidesNavigationBarDuringPresentation) {
        [(UINavigationController *)self.searchBar.jl_viewController.parentViewController setNavigationBarHidden:YES animated:YES];
        [UIView animateWithDuration:0.2 animations:^{
            self.bgView.y = 64;
        }];
    } else {
        
    }
}

- (void)handGesture {
    
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"text"] && [self.searchResultsUpdater respondsToSelector:@selector(updateSearchResultsForSearchController:)]) {
        [self.searchResultsUpdater updateSearchResultsForSearchController:self];
    }
}

- (void)endSearch {
    if ([self.delegate respondsToSelector:@selector(willDismissSearchController:)]) [self.delegate willDismissSearchController:self];
    self.searchBar.jl_viewController.jl_lightStatusBar = YES;
    NSArray *searchBarGestures = self.searchBar.gestureRecognizers;
    if (searchBarGestures.count == 3) {
        [self.searchBar removeGestureRecognizer:searchBarGestures.lastObject];
        [self.searchBar removeGestureRecognizer:searchBarGestures.lastObject];
    }
    if (searchBarGestures.count == 2) {
        [self.searchBar removeGestureRecognizer:searchBarGestures.lastObject];
    }
    
    [self.view removeFromSuperview];
    if ([self.delegate respondsToSelector:@selector(didDismissSearchController:)]) [self.delegate didDismissSearchController:self];
    [self.searchBar setValue:@0 forKey:@"isEditing"];
    if (self.searchBar.jl_viewController.parentViewController && [self.searchBar.jl_viewController.parentViewController isKindOfClass:[UINavigationController class]] && self.hidesNavigationBarDuringPresentation) {
        [(UINavigationController *)self.searchBar.jl_viewController.parentViewController setNavigationBarHidden:NO animated:YES];
        self.bgView.y = CGRectGetMaxY(self.searchBar.frame) + 64;
    }
}

- (void)endSearchTextFieldEditing {
    UITextField *searchTextField = [self.searchBar valueForKey:@"searchTextField"];
    [searchTextField resignFirstResponder];
}

@end
