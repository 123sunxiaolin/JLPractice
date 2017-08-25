//
//  ZBCustomTextField.m
//  JLMailCore2Practice
//
//  Created by perfect on 2017/6/27.
//  Copyright © 2017年 JackLin. All rights reserved.
//

#import "ZBCustomTextField.h"
#import "Masonry.h"

@interface ZBCustomTextField()

@property (nonatomic, strong) UIView *textFieldLeftView;
@property (nonatomic, strong) UILabel *promptLabel;

@end

@implementation ZBCustomTextField

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup{
    
    [self setBorderStyle:UITextBorderStyleNone];
    [self setFont:[UIFont systemFontOfSize:14]];
    [self setBackgroundColor:[UIColor whiteColor]];
    [self setAutocorrectionType:UITextAutocorrectionTypeNo];
    [self setAutocapitalizationType:UITextAutocapitalizationTypeNone];
    [self setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
    
    [self setLeftView:self.textFieldLeftView];
    [self setLeftViewMode:UITextFieldViewModeAlways];
    
}


#pragma mark - Getters or Setters
- (UIView *)textFieldLeftView{
    if (!_textFieldLeftView) {
        _textFieldLeftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 50, 55)];
        _textFieldLeftView.backgroundColor = [UIColor clearColor];
    }
    
    [_textFieldLeftView addSubview:self.promptLabel];
    [self.promptLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_textFieldLeftView).offset(8);
        make.centerY.equalTo(_textFieldLeftView.mas_centerY);
        make.size.mas_equalTo(CGSizeMake(35, 18));
    }];
    return _textFieldLeftView;
}

- (UILabel *)promptLabel{
    if (!_promptLabel) {
        _promptLabel = [[UILabel alloc] initWithFrame:CGRectMake(8, 0, 35, 18)];
        _promptLabel.font = self.font;
        _promptLabel.textColor = [UIColor colorWithWhite:0.5 alpha:1];
        _promptLabel.textAlignment = NSTextAlignmentLeft;
        _promptLabel.text = @"主题:";
    }
    return _promptLabel;
}

- (void)setPromptText:(NSString *)text{
    _promptText = text;
    if (text) {
        self.promptLabel.text = text;
    }else{
        [self setLeftView:nil];
    }
}

- (void)setPromptColor:(UIColor *)promptColor{
    if (promptColor) {
        self.promptLabel.textColor = promptColor;
    }
}
@end
