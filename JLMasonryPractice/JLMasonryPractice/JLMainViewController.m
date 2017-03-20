//
//  JLMainViewController.m
//  JLMasonryPractice
//
//  Created by perfect on 2017/3/17.
//  Copyright © 2017年 JackLin. All rights reserved.
//

#import "JLMainViewController.h"
#import "JLDisplayViewController.h"
#import "JLMainView.h"
#import "JLUpdateConstantView.h"
#import <Masonry.h>

@interface JLMainViewController ()<UITableViewDelegate, UITableViewDataSource>{
    NSArray *_masFuncArray;
    NSArray *_masViewControllerArray;
}

@property(nonatomic, strong) UITableView *mainTableView;

@end

@implementation JLMainViewController

#pragma mark - Life Cycle
- (instancetype)init{
    self = [super init];
    if (!self) {
        return nil;
    }
    self.title = @"Masonry从入门到放弃";
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    _masFuncArray = @[@"基础使用", @"改变/重置约束"];
    _masViewControllerArray = @[
                                [[JLDisplayViewController alloc] initWithTitle:@"基础"
                                                                     viewClass:[JLMainView class]],
                                [[JLDisplayViewController alloc] initWithTitle:@"约束变更"
                                                                     viewClass:[JLUpdateConstantView class]]
                                
                                ];
    [self.view addSubview:self.mainTableView];
    
}

- (void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    
    [self.mainTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view).insets(UIEdgeInsetsMake(0, 0, 0, 0));
    }];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Getters
- (UITableView *)mainTableView{
    if (!_mainTableView) {
        _mainTableView = [[UITableView alloc] init];
        _mainTableView.dataSource = self;
        _mainTableView.delegate = self;
        _mainTableView.tableFooterView = [UIView new];
    }
    return _mainTableView;
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _masFuncArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellId = @"masFunctionTableViewCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    cell.textLabel.text = _masFuncArray[indexPath.row];
    return cell;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 55.f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    UIViewController *viewController = _masViewControllerArray[indexPath.row];
    [self.navigationController pushViewController:viewController animated:YES];
    
}


@end
