//
//  JLMainView.m
//  JLMasonryPractice
//
//  Created by perfect on 2017/3/17.
//  Copyright © 2017年 JackLin. All rights reserved.
//

#import "JLMainView.h"
#import <Masonry.h>

@interface JLMainView(){
    UIView *thirdView;
}

@property (nonatomic, strong) UILabel *testAutolayoutLabel;

@end
@implementation JLMainView
- (instancetype)init{
    self = [super init];
    if (!self) {
        return nil;
    }
    
    UIView *firstView = [UIView new];
    firstView.backgroundColor = [UIColor grayColor];
    [self addSubview:firstView];
    
    UIView *secondView = [UIView new];
    secondView.backgroundColor = [UIColor redColor];
    [self addSubview:secondView];
    
    thirdView = [UIView new];
    thirdView.backgroundColor = [UIColor blueColor];
    [self addSubview:thirdView];
    
    CGFloat firstPadding = 10.f;
    
    //Basic1: left、top、right、bottom used in `equalTo`, size、height、width used in `mas_equalTo`
    [firstView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).offset(firstPadding);
        make.top.equalTo(self).offset(firstPadding + 64.f);
        make.size.mas_equalTo(CGSizeMake(100, 80));
        //equal to
        //following is in the same
//        make.height.mas_equalTo(80);
//        make.height.equalTo(@80);
        
        //make.width.mas_equalTo(@100);
    }];
    
    //lessThanOrEqualTo
    [secondView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(firstView);
        make.left.lessThanOrEqualTo(firstView.mas_right).offset(firstPadding);
        make.right.equalTo(self).offset(- firstPadding);
        make.width.mas_equalTo(250);
        make.height.mas_equalTo(100);
    }];
    
    //可以设置label的自动适应
    [self addSubview:self.testAutolayoutLabel];
    NSString *labelContent = @"bhjcBbudabu不好打巴萨机会成本的话差不多吧U币超级爱吃差不多加不加ABC就不错不急撒比成绩对比比较好的不会吧差不多就不参加爱吃";
    //NSString *shortContent = @"测试";
    self.testAutolayoutLabel.text = labelContent;
    [self.testAutolayoutLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).offset(10);
        make.top.equalTo(secondView.mas_bottom).offset(10);
        make.right.mas_equalTo(- 10);
    }];
    
    [thirdView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self);
        make.top.equalTo(self.testAutolayoutLabel.mas_bottom).offset(firstPadding);
        //make.height.equalTo(@[firstView, secondView]);
        make.height.equalTo(firstView);
    }];
    
    NSLog(@"height: %f", thirdView.frame.size.height);
    
    
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    //print tne final view layout and size
     NSLog(@"height: %f", thirdView.frame.size.height);
}

#pragma mark - getters
- (UILabel *)testAutolayoutLabel{
    if (!_testAutolayoutLabel) {
        _testAutolayoutLabel = [[UILabel alloc] init];
        _testAutolayoutLabel.backgroundColor = [UIColor lightGrayColor];
        _testAutolayoutLabel.textColor = [UIColor blackColor];
        _testAutolayoutLabel.numberOfLines = 0;
    }
    return _testAutolayoutLabel;
}

@end
