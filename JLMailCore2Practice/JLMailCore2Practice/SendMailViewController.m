//
//  SendMailViewController.m
//  JLMailCore2Practice
//
//  Created by perfect on 2017/6/26.
//  Copyright © 2017年 JackLin. All rights reserved.
//

#import "SendMailViewController.h"
#import "ZBTokenFieldConst.h"
#import "Masonry.h"
#import "ZBCustomTextField.h"
#import "ZBSendMailView.h"

static CGFloat const kTextFieldHeight = 55.f;

@interface SendMailViewController ()<ZBTokenFieldDelegate>

@property (nonatomic, strong) ZBTokenField *receiptField;//收件人
@property (nonatomic, strong) ZBTokenField *ccTextField;//抄送

@property (nonatomic, strong) ZBCustomTextField *subjectTextField;

@property (nonatomic, strong) UIView *subjectBackgroundView;
@property (nonatomic, strong) UILabel *subjectLabel;
@property (nonatomic, strong) UITextField *subjectsTextField;

@property (nonatomic, strong) ZBSendMailView *sendMailView;

@end

@implementation SendMailViewController

#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"发邮件";
    /*self.receiptField.frame = CGRectMake(0, 64, self.view.bounds.size.width, kTextFieldHeight);
    [self.view addSubview:self.receiptField];
    
    CGFloat bottomHeight = CGRectGetMaxY(self.receiptField.frame);
    self.ccTextField.frame = CGRectMake(0, bottomHeight, self.view.bounds.size.width, kTextFieldHeight);
    [self.view addSubview:self.ccTextField];
    
    bottomHeight = CGRectGetMaxY(self.ccTextField.frame);
    self.subjectTextField.frame = CGRectMake(0, bottomHeight, self.view.bounds.size.width, kTextFieldHeight);
    [self.view addSubview:self.subjectTextField];*/
    
    [self.view addSubview:self.sendMailView];
    
}

- (void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    /*[self.receiptField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(64);
        make.left.right.equalTo(self.view);
        make.height.mas_equalTo(kTextFieldHeight);
    }];
    
    
    [self.ccTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.receiptField);
        make.top.equalTo(self.receiptField.mas_bottom);
        make.height.mas_equalTo(kTextFieldHeight);
    }];*/
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Getters
- (ZBSendMailView *)sendMailView{
    if (!_sendMailView) {
        _sendMailView = [[ZBSendMailView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame))];
    }
    return _sendMailView;
}

- (UIView *)subjectBackgroundView{
    if (!_subjectBackgroundView) {
        _subjectBackgroundView = [[UIView alloc] initWithFrame:CGRectZero];
        _subjectBackgroundView.backgroundColor = [UIColor whiteColor];
    }
    return _subjectBackgroundView;
}

- (ZBTokenField *)receiptField{
    if (!_receiptField) {
        _receiptField = [[ZBTokenField alloc] initWithFrame:CGRectZero];
        _receiptField.tag = 1000;
        [_receiptField setDelegate:self];
        [_receiptField setPromptText:@"收件人:"];
        [_receiptField setShowShadow:NO];
        [_receiptField setRemovesTokensOnEndEditing:NO];
        [_receiptField addTarget:self
                          action:@selector(tokenFieldFrameWillChange:)
                forControlEvents:(UIControlEvents)ZBTokenFieldControlEventFrameWillChange];
        [_receiptField addTarget:self
                          action:@selector(tokenFieldFrameDidChange:)
                forControlEvents:(UIControlEvents)ZBTokenFieldControlEventFrameDidChange];
       
        
    }
    return _receiptField;
}

- (ZBTokenField *)ccTextField{
    if (!_ccTextField) {
        _ccTextField = [[ZBTokenField alloc] initWithFrame:CGRectZero];
        _ccTextField.tag = 1001;
        [_ccTextField setDelegate:self];
        [_ccTextField setPromptText:@"抄送:"];
        [_ccTextField setShowShadow:NO];
        [_ccTextField setRemovesTokensOnEndEditing:NO];
        _ccTextField.backgroundColor = [UIColor yellowColor];
        [_ccTextField addTarget:self
                          action:@selector(tokenFieldFrameWillChange:)
                forControlEvents:(UIControlEvents)ZBTokenFieldControlEventFrameWillChange];
        [_ccTextField addTarget:self
                          action:@selector(tokenFieldFrameDidChange:)
                forControlEvents:(UIControlEvents)ZBTokenFieldControlEventFrameDidChange];
    }
    return _ccTextField;
}

- (ZBCustomTextField *)subjectTextField{
    if (!_subjectTextField) {
        _subjectTextField = [[ZBCustomTextField alloc] initWithFrame:CGRectZero];
        _subjectTextField.delegate = self;
        _subjectTextField.borderStyle = UITextBorderStyleNone;
        _subjectTextField.placeholder = @"请输入主题";
    }
    return _subjectTextField;
}

#pragma mark - Action
- (void)tokenFieldFrameWillChange:(ZBTokenField *)field{
    NSLog(@"height:%@  height:%f", field.description, field.bounds.size.height);
}

- (void)tokenFieldFrameDidChange:(ZBTokenField *)field{
    [self updateViewSize];
}

#pragma mark - Private
- (void)updateViewSize{
    CGFloat recipetTextFieldBottom = CGRectGetMaxY(self.receiptField.frame);
    [self.ccTextField setFrame:CGRectMake(0, recipetTextFieldBottom, CGRectGetWidth(self.ccTextField.frame), CGRectGetHeight(self.ccTextField.frame))];
    CGFloat ccFieldBottom = CGRectGetMaxY(self.ccTextField.frame);
    [self.subjectTextField setFrame:CGRectMake(0, ccFieldBottom, CGRectGetWidth(self.subjectTextField.frame), CGRectGetHeight(self.subjectTextField.frame))];
}

#pragma mark - Delegate


@end
