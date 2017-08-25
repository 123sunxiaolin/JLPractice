//
//  IMAPMailListViewController.h
//  JLMailCore2Practice
//
//  Created by perfect on 2017/6/20.
//  Copyright © 2017年 JackLin. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MCOIMAPFolder, MCOIMAPSession;
@interface IMAPMailListViewController : UIViewController

@property (nonatomic, strong) MCOIMAPSession *imapSession;
@property (nonatomic, strong) MCOIMAPFolder *imapFolder;

@end
