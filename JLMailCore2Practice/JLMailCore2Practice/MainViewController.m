//
//  MainViewController.m
//  JLMailCore2Practice
//
//  Created by perfect on 2017/6/20.
//  Copyright © 2017年 JackLin. All rights reserved.
//

#import "MainViewController.h"
#import "IMAPViewController.h"
#import "POPViewController.h"
#import "SMTPViewController.h"
#import "SendMailViewController.h"
#import <MessageUI/MessageUI.h>

@interface MainViewController ()<UITableViewDelegate, UITableViewDataSource, MFMailComposeViewControllerDelegate>{
    NSArray *_functionsArray;
}

@property (nonatomic, strong) UITableView *mainTableView;

@end

@implementation MainViewController

#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"邮箱收发";
    self.view.backgroundColor = [UIColor whiteColor];
    _functionsArray = @[@"IMAP协议的使用", @"POP协议的使用", @"SMTP协议的使用"];
    [self.view addSubview:self.mainTableView];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Getters
- (UITableView *)mainTableView{
    if (!_mainTableView) {
        CGRect rect = CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame));
        _mainTableView = [[UITableView alloc] initWithFrame:rect];
        _mainTableView.delegate = self;
        _mainTableView.dataSource = self;
        _mainTableView.tableFooterView = [UIView new];
    }
    return _mainTableView;
}

#pragma mark - Action
#pragma mark - Private
#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _functionsArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellId = @"mailFuncTableCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    cell.textLabel.text = _functionsArray[indexPath.row];
    return cell;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 75;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    switch (indexPath.row) {
        case 0:{
            
            IMAPViewController *imapVC = [[IMAPViewController alloc] init];
            [self.navigationController pushViewController:imapVC animated:YES];
            
        }
          break;
        case 1:{
            
            POPViewController *popVC = [[POPViewController alloc] init];
            [self.navigationController pushViewController:popVC animated:YES];
            
        }
            break;
        case 2:{
            /*SMTPViewController *smtpVC = [[SMTPViewController alloc] init];
            [self.navigationController pushViewController:smtpVC animated:YES];*/
            //SendMailViewController *sendVC = [[SendMailViewController alloc] init];
            //[self.navigationController pushViewController:sendVC animated:YES];
            
            if (MFMailComposeViewController.canSendMail) {
                MFMailComposeViewController *mailVC = [[MFMailComposeViewController alloc] init];
                mailVC.mailComposeDelegate = self;
                [mailVC setSubject: @"eMail主题"];
                NSArray *toRecipients = [NSArray arrayWithObject: @"first@example.com"];
                [mailVC setToRecipients:toRecipients];
                [self presentViewController:mailVC animated:YES completion:nil];
            }
            
            
        }
            break;
            
        default:
            break;
    }
}


- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(nullable NSError *)error{
    
}


@end
