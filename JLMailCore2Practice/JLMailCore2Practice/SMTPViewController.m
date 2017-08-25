//
//  SMTPViewController.m
//  JLMailCore2Practice
//
//  Created by perfect on 2017/6/23.
//  Copyright © 2017年 JackLin. All rights reserved.
//

#import "SMTPViewController.h"
#import <MailCore/MailCore.h>
#import "ZBTokenField.h"
#import "ZBToken.h"


@interface SMTPViewController ()<ZBTokenFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *receiverTextiled;
@property (weak, nonatomic) IBOutlet UITextField *chaosongTextified;
@property (weak, nonatomic) IBOutlet UITextField *subjectTextfield;
@property (weak, nonatomic) IBOutlet UITextView *contentTextView;
@property (weak, nonatomic) IBOutlet UIButton *sendButton;

@property (nonatomic, strong) MCOSMTPSession *stmpSession;
@property (nonatomic, strong) MCOMessageBuilder *msgBuilder;
//@property (nonatomic, strong)   *<#property name#>;

@property (nonatomic, strong) ZBTokenField *tokenField;

@end

@implementation SMTPViewController

#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"SMTP";
    [self.view addSubview:self.tokenField];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - Getters
- (ZBTokenField *)tokenField{
    if (!_tokenField) {
        _tokenField = [[ZBTokenField alloc] initWithFrame:CGRectMake(0, 500, CGRectGetWidth(self.view.frame), 42)];
        [_tokenField setDelegate:self];
        [_tokenField addTarget:self action:@selector(tokenFieldDidBeginEditing:) forControlEvents:UIControlEventEditingDidBegin];
        [_tokenField addTarget:self action:@selector(tokenFieldDidEndEditing:) forControlEvents:UIControlEventEditingDidEnd];
        [_tokenField addTarget:self action:@selector(tokenFieldTextDidChange:) forControlEvents:UIControlEventEditingChanged];
        [_tokenField addTarget:self action:@selector(tokenFieldFrameWillChange:) forControlEvents:(UIControlEvents)ZBTokenFieldControlEventFrameWillChange];
        [_tokenField addTarget:self action:@selector(tokenFieldFrameDidChange:) forControlEvents:(UIControlEvents)ZBTokenFieldControlEventFrameDidChange];
        [_tokenField setPromptText:@"收件人"];
        
    }
    return _tokenField;
}
#pragma mark - Action
- (void)tokenFieldDidBeginEditing:(ZBTokenField *)field {

}

- (void)tokenFieldDidEndEditing:(ZBTokenField *)field{
    
}

- (void)tokenFieldTextDidChange:(ZBTokenField *)field{
   
}

- (void)tokenFieldFrameWillChange:(ZBTokenField *)field{
     NSLog(@"height:%@  height:%f", field.description, field.bounds.size.height);
}

- (void)tokenFieldFrameDidChange:(ZBTokenField *)field{
    
}
#pragma mark - Private
#pragma mark - ZBTokenFieldDelegate
- (void)tokenField:(ZBTokenField *)tokenField didTapToken:(ZBToken *)token{
    
    
}

- (void)tokenField:(ZBTokenField *)tokenField didRemoveToken:(ZBToken *)token{
    
}

@end
