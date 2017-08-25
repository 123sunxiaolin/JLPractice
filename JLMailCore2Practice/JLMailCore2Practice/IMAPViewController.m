//
//  IMAPViewController.m
//  JLMailCore2Practice
//
//  Created by perfect on 2017/6/20.
//  Copyright © 2017年 JackLin. All rights reserved.
//

#import "IMAPViewController.h"
#import <MailCore/MailCore.h>
#import "JLMailCore2Const.h"
#import "IMAPMailListViewController.h"

@interface IMAPViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) MCOIMAPSession *imapSession;

@property (nonatomic, strong) NSArray<MCOIMAPFolder *> *allMailFolders;

@property (nonatomic, strong) UISegmentedControl *segmentedControl;

@property (nonatomic, strong) UITableView *folderTableView;

@end

@implementation IMAPViewController

#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"IMAP";
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.folderTableView];
    [self p_startConnectMail];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Getters
- (MCOIMAPSession *)imapSession{
    if (!_imapSession) {
        _imapSession = [[MCOIMAPSession alloc] init];
        _imapSession.hostname = IMAP_HOST;
        _imapSession.port = IMAP_PORT;
        _imapSession.username = IMAP_UserName;
        _imapSession.password = IMAP_Password;
        _imapSession.connectionType = MCOConnectionTypeTLS;
    }
    return _imapSession;
}

- (UISegmentedControl *)segmentedControl{
    if (!_segmentedControl) {
        CGRect rect = CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 30.f);
        _segmentedControl = [[UISegmentedControl alloc] initWithFrame:rect];
        _segmentedControl.selectedSegmentIndex = 0;
        _segmentedControl.momentary = YES;
        
        
    }
   // [_segmentedControl setit]
    return _segmentedControl;
}

- (UITableView *)folderTableView{
    if (!_folderTableView) {
        CGRect rect = CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame));
        _folderTableView = [[UITableView alloc] initWithFrame:rect];
        _folderTableView.delegate = self;
        _folderTableView.dataSource = self;
        _folderTableView.tableFooterView = [UIView new];
    }
    return _folderTableView;
}

#pragma mark - Action
#pragma mark - Private

- (void)p_startConnectMail{
    
    //打印连接的log
    __weak typeof(self) weakSelf = self;
    self.imapSession.connectionLogger = ^(void *connectionID, MCOConnectionLogType type, NSData *data) {
        @synchronized(weakSelf) {
            if (type != MCOConnectionLogTypeSentPrivate) {
                NSLog(@"event logged:%p %li withData: %@", connectionID, (long)type, [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
            }
        }
    };
    
    //检测邮箱的连接操作
    MCOIMAPOperation *imapCheckOperation = [self.imapSession checkAccountOperation];
    [imapCheckOperation start:^(NSError *error) {
        if (!error) {
            //连接成功
            
            [self p_fetchAllMailFolders];
            
        }else{
            //连接失败
            NSLog(@"error loading account: %@", error);
        }
    }];
}

- (void)p_fetchAllMailFolders{
    
    __weak typeof(self) weakSelf = self;
    MCOIMAPFetchFoldersOperation *folderOperation = [self.imapSession fetchAllFoldersOperation];
    [folderOperation start:^(NSError * _Nullable error, NSArray * _Nullable folders) {
        if (!error) {
            IMAPViewController *strongSelf = weakSelf;
            strongSelf.allMailFolders = [folders copy];
            [strongSelf.folderTableView reloadData];
            NSLog(@"all folders = %@", folders);
            
            for (MCOIMAPFolder *folder in folders) {
                NSArray * sections = [folder.path componentsSeparatedByString:[NSString stringWithFormat:@"%c",folder.delimiter]];
                NSString *folderName = [sections lastObject];
                //Mailbox names are 7-bit.
                const char *stringAsChar = [folderName cStringUsingEncoding:[NSString defaultCStringEncoding]];
                folderName = [NSString stringWithCString:stringAsChar encoding:CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingUTF7_IMAP)];
                
                 NSLog(@"pasered folder = %@  flag = %ld", folderName, folder.flags);
            }
            
        }else{
            NSLog(@"error fetch folder, error = %@", error);
        }
    }];
}

- (NSString *)p_switchFlagToStringWithFlag:(MCOIMAPFolderFlag)flag{
    NSString *flagString = @"";
    switch (flag) {
        case MCOIMAPFolderFlagAll:{//所有邮件
            flagString = @"MCOIMAPFolderFlagAll or MCOIMAPFolderFlagAllMail";
        }
            break;
        case MCOIMAPFolderFlagJunk:{//垃圾箱
            flagString = @"垃圾箱 - MCOIMAPFolderFlagJunk or MCOIMAPFolderFlagSpam";
        }
            break;
        case MCOIMAPFolderFlagNone:{
            flagString = @"MCOIMAPFolderFlagNone";
        }
            break;
        case MCOIMAPFolderFlagInbox:{//收件箱
            flagString = @"MCOIMAPFolderFlagInbox - 收件箱";
        }
            break;
        case MCOIMAPFolderFlagTrash:{//已删除
            flagString = @"MCOIMAPFolderFlagTrash - 已删除";
        }
            break;
        case MCOIMAPFolderFlagDrafts:{//草稿箱
            flagString = @"MCOIMAPFolderFlagDrafts - 草稿箱";
        }
            break;
        case MCOIMAPFolderFlagMarked:{//已标记
            flagString = @"MCOIMAPFolderFlagMarked - 已标记";
        }
            break;
        case MCOIMAPFolderFlagArchive:{//归档
            flagString = @"MCOIMAPFolderFlagArchive - 归档";
        }
            break;
        case MCOIMAPFolderFlagFlagged:{//星标
             flagString = @"MCOIMAPFolderFlagFlagged - 星标";
        }
            break;
        case MCOIMAPFolderFlagNoSelect:{
             flagString = @"MCOIMAPFolderFlagNoSelect";
        }
            break;
        case MCOIMAPFolderFlagSentMail:{//已发送
             flagString = @"MCOIMAPFolderFlagSentMail - 已发送";
        }
            break;
        case MCOIMAPFolderFlagUnmarked:{//未标记
             flagString = @"MCOIMAPFolderFlagUnmarked - 未标记";
        }
            break;
        case MCOIMAPFolderFlagImportant:{//重要
            flagString = @"MCOIMAPFolderFlagImportant - 重要";
        }
            break;
        case MCOIMAPFolderFlagNoInferiors:{//无子文件夹
            flagString = @"MCOIMAPFolderFlagNoInferiors - 无子文件夹";
        }
            break;
        case MCOIMAPFolderFlagFolderTypeMask:{//多种组合
            flagString = @"MCOIMAPFolderFlagFolderTypeMask - 多种组合";
        }
            break;
            
        default:
            flagString = @"暂无该种Flags";
            break;
    }
    
    return flagString;
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.allMailFolders.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellId = @"MailFolderCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellId];
    }
    MCOIMAPFolder *folder = self.allMailFolders[indexPath.row];
    cell.textLabel.textColor = [UIColor cyanColor];
    cell.textLabel.text = [self p_switchFlagToStringWithFlag:folder.flags];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ delimiter:%c", folder.path, folder.delimiter];
    return cell;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 70;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    MCOIMAPFolder *folder = self.allMailFolders[indexPath.row];
    IMAPMailListViewController *mailListVC = [[IMAPMailListViewController alloc] init];
    mailListVC.title = [self p_switchFlagToStringWithFlag:folder.flags];
    mailListVC.imapFolder = folder;
    mailListVC.imapSession = self.imapSession;
    [self.navigationController pushViewController:mailListVC animated:YES];
    
    
}


@end
