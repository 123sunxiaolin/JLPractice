//
//  TestViewController.m
//  JLTableHeaderViewPractice
//
//  Created by perfect on 2017/9/21.
//  Copyright © 2017年 JackLin. All rights reserved.
//

#import "TestViewController.h"
#import "Fg_tableView.h"

static const CGFloat kTitleViewHeight = 264.f;
static const CGFloat kSectionViewHeight = 50.f;
#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height

@interface TestViewController ()<UIScrollViewDelegate>{
    BOOL _isPageOffset;
    CGFloat _preContentOffsetY;
}

@property (strong, nonatomic) Fg_tableView *tableView;

@property (strong, nonatomic) UIScrollView *mainScrollView;

@property (nonatomic, strong) UIView *headerView;

@property (nonatomic, strong) UIView *testView;

@end

@implementation TestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
   
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"收件箱";
    
    _isPageOffset = YES;
    
    [self.view addSubview:self.mainScrollView];
    [self.mainScrollView addSubview:self.headerView];
    [self.headerView addSubview:self.testView];
    [self.mainScrollView addSubview:self.tableView];
    
    //当该属性设置为YES时，系统默认会滚动scrollView, 在该场景下不进行滚动视图的默认操作
    self.automaticallyAdjustsScrollViewInsets = NO;

}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self p_updateContentSize:self.tableView.contentSize];
}

#pragma mark - Getters
- (UIScrollView *)mainScrollView{
    if (!_mainScrollView) {
        _mainScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - 20)];
        _mainScrollView.scrollIndicatorInsets = UIEdgeInsetsMake(kTitleViewHeight, 0, 0, 0);
        [_mainScrollView setContentSize:CGSizeMake(SCREEN_WIDTH, SCREEN_HEIGHT * 5)];
        _mainScrollView.delegate = self;
        
    }
    return _mainScrollView;
}

- (UIView *)headerView{
    if (!_headerView) {
        _headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), kTitleViewHeight)];
        _headerView.backgroundColor = [UIColor blueColor];
    }
    return _headerView;
}

- (UIView *)testView{
    if (!_testView) {
        _testView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, kTitleViewHeight)];
        _testView.backgroundColor = [UIColor yellowColor];
        _testView.alpha = 0.5f;
    }
    return _testView;
}

- (Fg_tableView *)tableView{
    if (!_tableView) {
        _tableView = [[Fg_tableView alloc] initWithFrame:CGRectMake(0, kTitleViewHeight, SCREEN_WIDTH, SCREEN_HEIGHT * 5 - kTitleViewHeight) style:UITableViewStylePlain];
        _tableView.scrollEnabled = NO;
    }
    return _tableView;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)p_updateContentSize:(CGSize)size{
    
    CGSize contentSize = size;
    contentSize.height = contentSize.height + kTitleViewHeight + kSectionViewHeight;
    self.mainScrollView.contentSize = contentSize;
    CGRect frame = self.tableView.frame;
    frame.size.height = size.height;
    self.tableView.frame = frame;
    
}

#pragma mark - UIScrollViewDelegate
-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    CGFloat y = scrollView.contentOffset.y;
    
    
    if (y < kTitleViewHeight) {//滑动到导航栏地底部之前
        CGFloat colorAlpha = y/kTitleViewHeight;
        self.navigationController.navigationBar.alpha = colorAlpha;
        self.title = @"";
    }else {//超过导航栏底部
        self.title = @"收件箱";
    }
    
    if (y <= 1) {
        CGRect newFrame = self.headerView.frame;
        newFrame.origin.y = y;
        self.headerView.frame = newFrame;
        
        newFrame = self.tableView.frame;
        newFrame.origin.y = y + kTitleViewHeight;
        self.tableView.frame = newFrame;
        
        //偏移量给到tableview，tableview自己来滑动
        
        /*CGFloat absolute_Y = fabs(y);
        if (absolute_Y > 0 && absolute_Y <= 50){
            
            self.tableView.contentOffsetY = y;
            if (absolute_Y > 25) {
                [self.tableView setContentOffset:CGPointMake(0, - 50) animated:YES];
            }else{
                [self.tableView setContentOffset:CGPointMake(0, 0) animated:YES];
            }
        }else{
            self.tableView.contentOffsetY = y;
        }*/
        
        self.tableView.contentOffsetY = y;
        
        
         NSLog(@"consetOff = %f", y);
        
        /*CGFloat offset = self.tableView.contentOffset.y;
        CGFloat absolute_Y = fabs(y);
        
        NSLog(@"consetOff = %f", y);
        
        if (offset > 0 && offset <= 50) {
            //下拉的时候 标记视图未显示时处理
            
            
            if (absolute_Y > 25) {
                [self.tableView setContentOffset:CGPointMake(0, 0) animated:YES];
            }else{
                [self.tableView setContentOffset:CGPointMake(0, 50) animated:YES];
            }
            
            [self.tableView setContentOffset:CGPointMake(0, 0) animated:YES];
        }else{
            self.tableView.contentOffsetY = y;
        }*/
        
        
        /*newFrame = self.testView.frame;
        newFrame.origin.y = 0;
        self.testView.frame = newFrame;*/
        
    }else  if (y > 1 && y <= 50) {
        
        //if (y > _preContentOffsetY) {// 向上滑
            
            self.tableView.contentOffsetY = y;
            if (y > 25) {
                [self.tableView setContentOffset:CGPointMake(0, 50) animated:YES];
            }else{
                [self.tableView setContentOffset:CGPointMake(0, 0) animated:YES];
            }
            
       /* }else{//向下滑
            
            CGFloat offset = 50 - y;
            if (offset > 25) {
                [self.tableView setContentOffset:CGPointMake(0, 0) animated:YES];
            }else{
                [self.tableView setContentOffset:CGPointMake(0, 50) animated:YES];
            }
            
        }*/
        
    } else {
        //视差处理
//        CGRect newFrame = self.imageView.frame;
//        newFrame.origin.y = y/2;
//        self.imageView.frame = newFrame;
        
    }
    _preContentOffsetY = y;
}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    
    // 松手时判断是否刷新
    CGFloat y = scrollView.contentOffset.y;
    if (y < - 65) {
        [self.tableView startRefreshing];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.tableView endRefreshing];
            //self.tableView.contentOffsetY = 50;
        });
    }
}


@end
