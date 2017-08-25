//
//  ZBSendMailView.m
//  JLMailCore2Practice
//
//  Created by perfect on 2017/6/27.
//  Copyright © 2017年 JackLin. All rights reserved.
//

#import "ZBSendMailView.h"
#import "ZBTokenFieldConst.h"
#import "ZBCustomTextField.h"

static CGFloat const kTextFieldHeight = 55.f;
@interface ZBSendMailView()<ZBTokenFieldDelegate>{
    UIView *_contentView;
}

@property (nonatomic, strong) ZBTokenField *receiptField;//收件人
@property (nonatomic, strong) ZBTokenField *ccTextField;//抄送

@property (nonatomic, strong) ZBCustomTextField *subjectTextField;

@end

@implementation ZBSendMailView

#pragma mark - init
- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self setupView];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder{
    if (self = [super initWithCoder:aDecoder]) {
        [self setupView];
    }
    return self;
}

- (void)setupView{
    
    [self setBackgroundColor:[UIColor clearColor]];
    [self setDelaysContentTouches:NO];
    [self setMultipleTouchEnabled:NO];
    
    ZBToken *token1 = [[ZBToken alloc] initWithTitle:@"123"];
    ZBToken *token2 = [[ZBToken alloc] initWithTitle:@"1234vhjbvhadvfvfvgfdvfhvfghvdhvdhvhdvdhvdhdhvdhvdhdhddhdhvdhvdh"];
    
    NSArray *temp = @[token1, token2];
    temp = [temp copy];
    self.receiptField.frame = CGRectMake(0, 0, self.bounds.size.width, kTextFieldHeight);
    for (ZBToken *token in temp) {
        [self.receiptField addToken:token];
    }
    [self addSubview:self.receiptField];
    
    CGFloat bottomHeight = CGRectGetMaxY(self.receiptField.frame);
    self.ccTextField.frame = CGRectMake(0, bottomHeight, self.bounds.size.width, kTextFieldHeight);
    [self addSubview:self.ccTextField];
    
    bottomHeight = CGRectGetMaxY(self.ccTextField.frame);
    self.subjectTextField.frame = CGRectMake(0, bottomHeight, self.bounds.size.width, kTextFieldHeight);
    [self addSubview:self.subjectTextField];
    
    bottomHeight = CGRectGetMaxY(self.subjectTextField.frame);
    _contentView = [[UIView alloc] initWithFrame:CGRectMake(0, bottomHeight, self.bounds.size.width, self.bounds.size.height - bottomHeight)];
    _contentView.backgroundColor = [UIColor redColor];
    [self addSubview:_contentView];
    
    [self updateViewSize];
    
}

#pragma mark - Getters
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

#pragma mark - ZBTokenFieldDelegate

#pragma mark - Action
- (void)tokenFieldFrameWillChange:(ZBTokenField *)field{
    NSLog(@"height:%@  height:%f", field.description, field.bounds.size.height);
     [self updateViewSize];
}

- (void)tokenFieldFrameDidChange:(ZBTokenField *)field{
    [self updateContentSize];
}

#pragma mark - Private
- (void)updateViewSize{
    CGFloat recipetTextFieldBottom = CGRectGetMaxY(self.receiptField.frame);
    [self.ccTextField setFrame:CGRectMake(0, recipetTextFieldBottom, CGRectGetWidth(self.ccTextField.frame), CGRectGetHeight(self.ccTextField.frame))];
    CGFloat ccFieldBottom = CGRectGetMaxY(self.ccTextField.frame);
    [self.subjectTextField setFrame:CGRectMake(0, ccFieldBottom, CGRectGetWidth(self.subjectTextField.frame), CGRectGetHeight(self.subjectTextField.frame))];
    CGFloat subjectFileldBottom = CGRectGetMaxY(self.subjectTextField.frame);
    [_contentView setFrame:CGRectMake(0, subjectFileldBottom, CGRectGetWidth(_contentView.frame), CGRectGetHeight(_contentView.frame))];
}

- (void)updateContentSize{
    [self setContentSize:CGSizeMake(self.bounds.size.width, CGRectGetMaxY(_contentView.frame))];
}

@end
