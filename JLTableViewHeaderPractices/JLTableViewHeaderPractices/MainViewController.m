//
//  MainViewController.m
//  JLTableViewHeaderPractices
//
//  Created by jacklin on 2017/10/8.
//  Copyright © 2017年 jacklin. All rights reserved.
//

#import "MainViewController.h"
#import "Masonry.h"
#import "MJRefresh.h"

#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height
#define TITLE_VIEW_HEIGHT 60.f

static const CGFloat kTitleViewHeight = 120.f;
static const CGFloat kHeaderViewHeight = 40.f;

@interface MainViewController ()<UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate>{
    BOOL _isHeaderViewOpened;
}

@property (nonatomic, strong) UIButton *testButton;

@property (nonatomic, strong) UIView *titleView;

@property (nonatomic, strong) UITableView *mainTableView;

@property (nonatomic, strong) UIView *headerView;

@end

@implementation MainViewController

#pragma mark - Life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"";
    self.view.backgroundColor = [UIColor whiteColor];
    _isHeaderViewOpened = NO;
    
    [self.view addSubview:self.titleView];
    CGFloat maxY = CGRectGetMaxY(self.titleView.frame);
    self.mainTableView.mj_y = maxY;
    self.mainTableView.mj_h = SCREEN_HEIGHT - maxY;
    [self.view addSubview:self.mainTableView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Getters
- (UIView *)titleView{
    if (!_titleView) {
        _titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 64, SCREEN_WIDTH, kTitleViewHeight)];
        _titleView.backgroundColor = [UIColor cyanColor];
    }
    return _titleView;
}

- (UIView *)headerView{
    if (!_headerView) {
        _headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, kHeaderViewHeight)];
        _headerView.backgroundColor = [UIColor orangeColor];
    }
    return _headerView;
}

- (UITableView *)mainTableView{
    if (!_mainTableView) {
        _mainTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 124, SCREEN_WIDTH, SCREEN_HEIGHT - kTitleViewHeight - 124)];
        _mainTableView.dataSource = self;
        _mainTableView.delegate = self;
        _mainTableView.tableFooterView = [UIView new];
        _mainTableView.tableHeaderView = self.headerView;
        _mainTableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self
                                                          refreshingAction:@selector(onPullDownRefresh:)];
    }
    return _mainTableView;
}

#pragma mark - Action
- (void)onPullDownRefresh:(id *)sender{
    
    sleep(2);
    [self.mainTableView.mj_header endRefreshingWithCompletionBlock:^{
        [self.mainTableView setContentOffset:CGPointMake(0, kHeaderViewHeight) animated:YES];
    }];
}

#pragma mark - UITableViewDataSource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 40;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 80;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * ID = @"cell";
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:0 reuseIdentifier:ID];
    }
    cell.textLabel.text = [NSString stringWithFormat:@"test Cell index:%ld, section:%ld", indexPath.row, indexPath.section];
    return cell;
}

#pragma mark - UITableViewDelegate

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    
    CGFloat y = scrollView.mj_offsetY;
    if (y > 0 && y <= kHeaderViewHeight) {
        if (y > kHeaderViewHeight / 2) {
            [self.mainTableView setContentOffset:CGPointMake(0, kHeaderViewHeight) animated:YES];
            _isHeaderViewOpened = NO;
            //self.mainTableView.mj_offsetY = kHeaderViewHeight;
        }else{
            [self.mainTableView setContentOffset:CGPointMake(0, 0) animated:YES];
            _isHeaderViewOpened = YES;
            //self.mainTableView.mj_offsetY = 0;
        }
    }
}

/**
 向上滑动，offsetY > 0, 向下滑动， offsetY < 0
 */
-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    
    CGFloat y = scrollView.mj_offsetY;
    
    /*if (y > kTitleViewHeight * 0.25 + kHeaderViewHeight) {
        
        self.title = @"测试主视图";
    }else{
        self.title = @"";
    }*/
    
    
    if (self.titleView.mj_y <= 64 - kTitleViewHeight * 0.5) {
        self.title = @"测试主视图";
        self.mainTableView.mj_h = SCREEN_HEIGHT - CGRectGetMaxY(self.titleView.frame);
    }else{
        self.title = @"";
        self.mainTableView.mj_h = SCREEN_HEIGHT - CGRectGetMaxY(self.titleView.frame);
    }
    
    
    NSLog(@"offsetY = %f", y);
    if (y > kHeaderViewHeight) {
        
        if (self.titleView.mj_y + self.titleView.mj_h > 64){
            
            CGFloat offsetY = y - kHeaderViewHeight;
            offsetY = offsetY/2;
            
            CGFloat dif = self.titleView.mj_y + self.titleView.mj_h - 64;
            offsetY = MIN(dif, offsetY);
            
            
            [UIView animateWithDuration:.3 animations:^{
                self.titleView.mj_y -= offsetY;
                self.mainTableView.mj_y -= offsetY;
                //self.mainTableView.mj_h += offsetY;
            }];
            
            //self.mainTableView.contentSize = CGSizeMake(self.mainTableView.contentSize.width, self.mainTableView.contentSize.height + offsetY);
        }
    }else if(y <= 0){
        CGFloat offsetY = fabs(y);
        if (self.titleView.mj_y < 64.f) {
            
            CGFloat dif = 64.f - self.titleView.mj_y;
            offsetY = MIN(dif, offsetY);
            
            self.titleView.mj_y += offsetY;
            self.mainTableView.mj_y += offsetY;
            //self.mainTableView.mj_h -= offsetY;
            
            /*[UIView animateWithDuration:.3 animations:^{
                
                
            }];*/
            
            //self.mainTableView.contentSize = CGSizeMake(self.mainTableView.contentSize.width, self.mainTableView.contentSize.height - offsetY);
        }
    }
    
    if (y > 0) {//上滑动
        
        /*if (self.titleView.mj_y + self.titleView.mj_h > 64) {
            
            //CGFloat offsetY = y - kHeaderViewHeight;
            
            self.titleView.mj_y -= y;
            self.mainTableView.mj_y -= y;
            self.mainTableView.mj_h += y;
            self.mainTableView.contentSize = CGSizeMake(self.mainTableView.contentSize.width, self.mainTableView.contentSize.height + y);
        }*/
        
        /*if (!_isHeaderViewOpened) {
            if (self.titleView.mj_y + self.titleView.mj_h > 64) {
                
                CGFloat offsetY = y - kHeaderViewHeight;
                
                self.titleView.mj_y -= offsetY;
                self.mainTableView.mj_y -= offsetY;
                self.mainTableView.mj_h += offsetY;
                self.mainTableView.contentSize = CGSizeMake(self.mainTableView.contentSize.width, self.mainTableView.contentSize.height + offsetY);
            }
        }*/
        
        
        /*if (y <= kHeaderViewHeight) {
            if (y > kHeaderViewHeight / 2) {
                [self.mainTableView setContentOffset:CGPointMake(0, kHeaderViewHeight) animated:YES];
                //self.mainTableView.mj_offsetY = kHeaderViewHeight;
            }else{
                [self.mainTableView setContentOffset:CGPointMake(0, 0) animated:YES];
                //self.mainTableView.mj_offsetY = 0;
            }
                
        }else{
            
            if (self.titleView.mj_y + self.titleView.mj_h > 64) {
                
                CGFloat offsetY = y - kHeaderViewHeight;
                
                self.titleView.mj_y -= offsetY;
                self.mainTableView.mj_y -= offsetY;
                self.mainTableView.mj_h += offsetY;
                self.mainTableView.contentSize = CGSizeMake(self.mainTableView.contentSize.width, self.mainTableView.contentSize.height + offsetY);
            }
            
        }*/
        
        
    }else{
        
        /*CGFloat offsetY = fabs(y);
        if (self.titleView.mj_y < 64.f) {
            self.titleView.mj_y += offsetY;
            self.mainTableView.mj_y += offsetY;
            self.mainTableView.mj_h -= offsetY;
            self.mainTableView.contentSize = CGSizeMake(self.mainTableView.contentSize.width, self.mainTableView.contentSize.height - offsetY);
        }*/
    }
    
    
}

@end
