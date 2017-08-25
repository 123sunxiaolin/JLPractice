//
//  ViewController.m
//  TestMailProject
//
//  Created by perfect on 2017/7/3.
//  Copyright © 2017年 JackLin. All rights reserved.
//

#import "ViewController.h"
#import <MessageUI/MessageUI.h>

@interface ViewController ()<MFMailComposeViewControllerDelegate>
- (IBAction)tapMailVC:(id)sender;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)tapMailVC:(id)sender {
    
    if (MFMailComposeViewController.canSendMail) {
        MFMailComposeViewController *mailVC = [[MFMailComposeViewController alloc] init];
        mailVC.mailComposeDelegate = self;
        [mailVC setSubject: @"eMail主题"];
        NSArray *toRecipients = [NSArray arrayWithObject: @"first@example.com"];
        [mailVC setToRecipients:toRecipients];
        [self presentViewController:mailVC animated:YES completion:nil];
    }
    
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(nullable NSError *)error{
    
}


@end
