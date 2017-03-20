//
//  JLUpdateConstantView.m
//  JLMasonryPractice
//
//  Created by perfect on 2017/3/20.
//  Copyright © 2017年 JackLin. All rights reserved.
//

#import "JLUpdateConstantView.h"
#import <Masonry.h>

@interface JLUpdateConstantView()

@property (nonatomic, strong) UIButton *updateButton;

@end

@implementation JLUpdateConstantView

- (instancetype)init{
    if (self = [super init]) {
        
        [self addSubview:self.updateButton];
        [self.updateButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.mas_top).offset(10 + 64);
            make.left.equalTo(self.mas_left).offset(20);
            make.size.mas_equalTo(CGSizeMake(100, 100));
        }];
        
    }
    return self;
}

- (void)layoutSubviews{
   
}

#pragma mark - update Method
+ (BOOL)requiresConstraintBasedLayout{
    return NO;
}

//这是苹果推荐更新约束的方法
- (void)updateConstraints{
    CGFloat topPadding = arc4random() % 100 + 64;
    NSLog(@"toppading = %f", topPadding);
    [self.updateButton mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(topPadding);
        make.right.equalTo(self.mas_right).offset(- 20);
        //make.size.mas_equalTo(CGSizeMake(100, 100));
        make.height.equalTo(@100);
        make.width.equalTo(@100);
    }];
    
    // required
    //according to apple super should be called at end of method
    [super updateConstraints];
}

#pragma mark - getters
- (UIButton *)updateButton{
    if (!_updateButton) {
        _updateButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _updateButton.backgroundColor = [UIColor orangeColor];
        _updateButton.showsTouchWhenHighlighted = YES;
        [_updateButton setTitle:@"点击我" forState:UIControlStateNormal];
        [_updateButton setTitleColor:[UIColor cyanColor] forState:UIControlStateNormal];
        [_updateButton addTarget:self
                          action:@selector(onClickUpdateBtn:)
                forControlEvents:UIControlEventTouchUpInside];
        
    }
    return _updateButton;
}

#pragma mark - Action
- (void)onClickUpdateBtn:(UIButton *)sender{
    
    // tell constraints they need updating
    [self setNeedsUpdateConstraints];
    
    // update constraints now so we can animate the change
    [self updateConstraintsIfNeeded];
    
    [UIView animateWithDuration:0.4 animations:^{
        [self layoutIfNeeded];
    }];
    
}

@end
