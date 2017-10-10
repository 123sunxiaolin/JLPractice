//
//  Fg_tableView.m
//  支付宝跟新demo
//
//  Created by zgy_smile on 16/8/12.
//  Copyright © 2016年 zgy_smile. All rights reserved.
//

#import "Fg_tableView.h"
#import <MJRefresh.h>

#define kWidth [UIScreen mainScreen].bounds.size.width
#define kHeight [UIScreen mainScreen].bounds.size.height
@interface Fg_tableView ()<UITableViewDataSource,UITableViewDelegate>

@end

@implementation Fg_tableView

-(instancetype)initWithFrame:(CGRect)frame style:(UITableViewStyle)style {
    
    self = [super initWithFrame:frame style:style];
    
    if (self) {
        self.dataSource = self;
        self.delegate = self;
        self.rowHeight = (kHeight * 5 - 200) / 20;
        
        UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kWidth, 50)];
        headerView.backgroundColor = [UIColor redColor];
        self.tableHeaderView = headerView;
        
        self.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:nil];
        
    }
    return self;
}

-(void)setContentOffsetY:(CGFloat)contentOffsetY {
    
    _contentOffsetY = contentOffsetY;
    if (![self.mj_header isRefreshing]) {
        
        self.contentOffset = CGPointMake(0, contentOffsetY);
    }
}

-(void)startRefreshing {
    [self.mj_header beginRefreshing];
}
-(void)endRefreshing {
    [self.mj_header endRefreshingWithCompletionBlock:^{
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self setContentOffset:CGPointMake(0, 50) animated:YES];
        });
        
    }];
    
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return 20;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}


- (NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewRowAction *deleteRowAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"删除" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        
        NSLog(@"点击了删除");
    }];
    return @[deleteRowAction];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    
    cell.textLabel.text = [NSString stringWithFormat:@"%ld",indexPath.row];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    CGFloat y = scrollView.contentOffset.y;
    /*if (y > 0) {
        
        CGFloat mid = 25.f;
        if (y > 25) {
            <#statements#>
        }
        
    }*/
}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    
    CGFloat y = scrollView.contentOffset.y;
    
    if (y > 0 && y <= 50) {
        if (y > 25) {
            [self setContentOffset:CGPointMake(0, 50) animated:YES];
        }else{
            [self setContentOffset:CGPointMake(0, 0) animated:YES];
        }
    }
    
}


@end
