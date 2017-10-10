//
//  MainViewController.m
//  JLTableHeaderViewPractice
//
//  Created by perfect on 2017/9/21.
//  Copyright © 2017年 JackLin. All rights reserved.
//

#import "MainViewController.h"
#import <MJRefresh.h>

static const CGFloat kTitleViewHeight = 200.f;
static const CGFloat kSectionViewHeight = 50.f;

#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height

@interface MainViewController ()<UIScrollViewDelegate, UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UIScrollView *mainScrollView;

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) UIView *headerView;

@property (nonatomic, strong) UIView *hasReadView;

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"收件箱";
    
    [self.view addSubview:self.mainScrollView];
    [self.mainScrollView addSubview:self.headerView];
    [self.mainScrollView addSubview:self.hasReadView];
    [self.mainScrollView addSubview:self.tableView];
    
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self p_updateContentSize:self.tableView.contentSize];
}

- (void)p_updateContentSize:(CGSize)size{
    
    CGSize contentSize = size;
    contentSize.height = contentSize.height + kTitleViewHeight + kSectionViewHeight;
    self.mainScrollView.contentSize = contentSize;
    CGRect frame = self.tableView.frame;
    frame.size.height = size.height;
    self.tableView.frame = frame;
    
}

#pragma mark - Getters

- (UIScrollView *)mainScrollView{
    if (!_mainScrollView) {
        _mainScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
        _mainScrollView.delegate = self;
        _mainScrollView.scrollIndicatorInsets = UIEdgeInsetsMake(250, 0, 0, 0);\
        [_mainScrollView setContentSize:CGSizeMake(SCREEN_WIDTH, 100)];
        
    }
    return _mainScrollView;
}

- (UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, kTitleViewHeight + kSectionViewHeight, CGRectGetWidth(self.view.frame), SCREEN_HEIGHT - kTitleViewHeight - kSectionViewHeight)];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.tableFooterView = [UIView new];
        _tableView.scrollEnabled = NO;
        
        UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 50)];
        headerView.backgroundColor = [UIColor cyanColor];
        _tableView.tableHeaderView = headerView;
        _tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
            sleep(2);
            [_tableView.mj_header endRefreshing];
        }];
        
    }
    return _tableView;
}

- (UIView *)headerView{
    if (!_headerView) {
        _headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 200)];
        _headerView.backgroundColor = [UIColor redColor];
    }
    return _headerView;
}

- (UIView *)hasReadView{
    if (!_hasReadView) {
        _hasReadView = [[UIView alloc] initWithFrame:CGRectMake(0, 200, CGRectGetWidth(self.view.frame), 50)];
        _hasReadView.backgroundColor = [UIColor yellowColor];
    }
    return _hasReadView;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset{
    
    CGFloat contentOffsetY = scrollView.contentOffset.y;
    
    NSLog(@"scrollView dragging, offset = %f \n --> object = %@", contentOffsetY, scrollView);
    
    if (contentOffsetY < - 65) {
        [self.tableView.mj_header beginRefreshing];
    }else if(contentOffsetY > 0 && contentOffsetY <= kTitleViewHeight + kSectionViewHeight){
        
        CGFloat total = kTitleViewHeight + kSectionViewHeight;
        if (contentOffsetY > total/2.0) {
            [self.mainScrollView setContentOffset:CGPointMake(0, total)];
        }else{
            [self.mainScrollView setContentOffset:CGPointMake(0, 0)];
        }
        
    }
    
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    CGFloat contentOffsetY = scrollView.contentOffset.y;
    
    NSLog(@"scrollViewDidScroll, offset = %f \n --> object = %@", contentOffsetY, scrollView);
    
    if (contentOffsetY <= 0) {//向下滑
        
        CGRect frame = self.headerView.frame;
        frame.origin.y = contentOffsetY;
        self.headerView.frame = frame;
        
        frame = self.hasReadView.frame;
        frame.origin.y = contentOffsetY + kTitleViewHeight;
        self.hasReadView.frame = frame;
        
        frame = self.tableView.frame;
        frame.origin.y = contentOffsetY + kTitleViewHeight + kSectionViewHeight;
        self.tableView.frame = frame;
        
        [self.tableView setContentOffset:CGPointMake(0, contentOffsetY)];
        
    }else{
        
    }
    
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 100;
}

//- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
//
//}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellId = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    cell.textLabel.text = @"111";
    return cell;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50;
}

//- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
//
//    return 200;
//}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
