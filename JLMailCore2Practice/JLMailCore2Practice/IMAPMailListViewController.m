//
//  IMAPMailListViewController.m
//  JLMailCore2Practice
//
//  Created by perfect on 2017/6/20.
//  Copyright © 2017年 JackLin. All rights reserved.
//

#import "IMAPMailListViewController.h"
#import "JLMailCore2Const.h"
#import <MailCore/MailCore.h>
#import "MCTTableViewCell.h"
#import "MCTMsgViewController.h"
@import MessageUI;

static NSString *mailCellIdentifier = @"MailCell";
static NSString *inboxInfoIdentifier = @"InboxStatusCell";

@interface IMAPMailListViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *mailTableView;
@property (nonatomic, strong) UIProgressView *progrsessView;

/**
 folder下全部数量
 */
@property (nonatomic) NSInteger totalNumberOfInboxMessages;

@property (nonatomic, strong) NSArray <MCOIMAPMessage *> *messages;
@property (nonatomic) BOOL isLoading;
@property (nonatomic, strong) UIActivityIndicatorView *loadMoreActivityView;
@property (nonatomic, strong) NSMutableDictionary *messagePreviews;


@end

@implementation IMAPMailListViewController

#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    [self.mailTableView registerClass:[MCTTableViewCell class]
           forCellReuseIdentifier:mailCellIdentifier];
    [self.view addSubview:self.mailTableView];
    [self p_resetState];
    [self p_loadMailMessageHeadersWithNumber:DefaultLoadMessageNumber];
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Getters
- (UITableView *)mailTableView{
    if (!_mailTableView) {
        CGRect rect = CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame));
        _mailTableView = [[UITableView alloc] initWithFrame:rect];
        _mailTableView.delegate = self;
        _mailTableView.dataSource = self;
        _mailTableView.tableFooterView = [UIView new];
        _mailTableView.tableHeaderView = self.progrsessView;
    }
    return _mailTableView;
}

- (UIProgressView *)progrsessView{
    if (_progrsessView) {
        CGRect rect = CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 5);
        _progrsessView = [[UIProgressView alloc] initWithFrame:rect];
        _progrsessView.progressViewStyle = UIProgressViewStyleDefault;
    }
    return _progrsessView;
}

- (UIActivityIndicatorView *)loadMoreActivityView{
    if (!_loadMoreActivityView) {
        _loadMoreActivityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    }
    return _loadMoreActivityView;
}

#pragma mark - Private
- (void)p_resetState{
    
    self.messages = nil;
    self.totalNumberOfInboxMessages = -1;
    self.isLoading = NO;
    self.messagePreviews = [NSMutableDictionary dictionary];
    
}

- (void)p_loadMailMessageHeadersWithNumber:(NSInteger)nMessages{
    
    self.isLoading = YES;
    
    MCOIMAPMessagesRequestKind requestKind = (MCOIMAPMessagesRequestKind)
    (MCOIMAPMessagesRequestKindHeaders | MCOIMAPMessagesRequestKindStructure |
     MCOIMAPMessagesRequestKindInternalDate | MCOIMAPMessagesRequestKindHeaderSubject |
     MCOIMAPMessagesRequestKindFlags);
    
    //Junk 垃圾箱
    //INBOX 收件箱
    //Drafts 草稿箱
    //Deleted Messages 已删除
    
    
    
    NSString *folderName = [[[self.imapSession defaultNamespace] componentsFromPath:self.imapFolder.path] lastObject];
    MCOIMAPFolderStatusOperation *operation = [self.imapSession folderStatusOperation:folderName];
    [operation start:^(NSError *error, MCOIMAPFolderStatus *status) {
        
        NSLog(@"123");
    }];
    
    /*MCOIMAPFetchMessagesOperation * op = [self.imapSession syncMessagesWithFolder:@"INBOX"
                                                             requestKind:MCOIMAPMessagesRequestKindUID
                                                                    uids:[NSIndexSet indexSetWithIndexesInRange:MCORangeMake(1, UINT64_MAX)]
                                                                  modSeq:lastModSeq];
    [op start:^(NSError * error, NSArray * messages, MCOIndexSet * vanishedMessages) {
        NSLog(@"added or modified messages: %@", messages);
        NSLog(@"deleted messages: %@", vanishedMessages);
    }];*/
    
    MCOIMAPCapabilityOperation * op = [self.imapSession capabilityOperation];
    [op start:^(NSError * __nullable error, MCOIndexSet * capabilities) {
        if ([capabilities containsIndex:MCOIMAPCapabilityIdle]) {
            //canIdle = YES;
        }
    }];
    
    //NSString *folderName = [self p_convertToUnifomCommond];
    MCOIMAPFolderInfoOperation *folderInfoOperation = [self.imapSession folderInfoOperation:folderName];
    [folderInfoOperation start:^(NSError *error, MCOIMAPFolderInfo *info) {
        
        if (error) {
            NSLog(@"error fetch Imap folder,error = %@", error);
            return ;
        }
        BOOL totalNumberOfMessagesDidChange =
        self.totalNumberOfInboxMessages != [info messageCount];
        
        self.totalNumberOfInboxMessages = [info messageCount];
        
        NSUInteger numberOfMessagesToLoad = MIN(self.totalNumberOfInboxMessages, nMessages);
        
        if (numberOfMessagesToLoad == 0)
        {
            self.isLoading = NO;
            return;
        }
        
        MCORange fetchRange;
        
        // If total number of messages did not change since last fetch,
        // assume nothing was deleted since our last fetch and just
        // fetch what we don't have
        if (!totalNumberOfMessagesDidChange && self.messages.count)
        {
            numberOfMessagesToLoad -= self.messages.count;
            
            fetchRange =
            MCORangeMake(self.totalNumberOfInboxMessages -
                         self.messages.count -
                         (numberOfMessagesToLoad - 1),
                         (numberOfMessagesToLoad - 1));
        }
        
        // Else just fetch the last N messages
        else
        {
            fetchRange =
            MCORangeMake(self.totalNumberOfInboxMessages -
                         (numberOfMessagesToLoad - 1),
                         (numberOfMessagesToLoad - 1));
        }
        
        MCOIMAPFetchMessagesOperation *messageFetchOperation =
        [self.imapSession fetchMessagesByNumberOperationWithFolder:folderName
                                                       requestKind:requestKind
                                                           numbers:[MCOIndexSet indexSetWithRange:fetchRange]];
        
        __weak typeof(self) weakSelf = self;
        [messageFetchOperation setProgress:^(unsigned int progress) {
            
            [weakSelf.progrsessView setProgress:progress / numberOfMessagesToLoad];
            NSLog(@"Progress: %u of %lu", progress, (unsigned long)numberOfMessagesToLoad);
        }];
        
        [messageFetchOperation start:^(NSError *error, NSArray *messages, MCOIndexSet *vanishedMessages) {
            
            __strong IMAPMailListViewController *strongSelf = weakSelf;
            //strongSelf.messages = [messages copy];
            NSLog(@"fetched all messages.");
            
//            for (MCOIMAPMessage *aMessage in messages) {
//                
//                NSLog(@"info: %llu", aMessage.modSeqValue);
//            }
            
            [self p_logMessages:messages];
            
            self.isLoading = NO;
            
            NSSortDescriptor *sort =
            [NSSortDescriptor sortDescriptorWithKey:@"header.date" ascending:NO];
            
            NSMutableArray *combinedMessages =
            [NSMutableArray arrayWithArray:messages];
            [combinedMessages addObjectsFromArray:strongSelf.messages];
            
            strongSelf.messages =
            [combinedMessages sortedArrayUsingDescriptors:@[sort]];
            [strongSelf.mailTableView reloadData];
            
        }];
        
    }];
    
}

- (void)p_logMessages:(NSArray *)messages
{
    for (MCOIMAPMessage *msg in messages) {
        long uid = msg.uid;
        long seqNum = msg.sequenceNumber;
        NSString *msgId = msg.header.messageID;
        NSString *subject = msg.header.subject;
        NSLog(@"uid = %ld, seqNum = %ld, msgId = %@, subject = %@ modSeqValue = %llu", uid, seqNum, msgId, subject, msg.modSeqValue);
    }
}

- (NSString *)p_convertToUnifomCommond{
    
    NSString *flagString = @"";
    NSString *originalFolderName =
    [[[self.imapSession defaultNamespace] componentsFromPath:self.imapFolder.path] lastObject];
    
    switch (self.imapFolder.flags) {
        case MCOIMAPFolderFlagAll:{//所有邮件
            flagString = originalFolderName;
        }
            break;
        case MCOIMAPFolderFlagJunk:{//垃圾箱
            flagString = kJunk;
        }
            break;
        case MCOIMAPFolderFlagNone:{
            flagString = originalFolderName;
        }
            break;
        case MCOIMAPFolderFlagInbox:{//收件箱
            flagString = originalFolderName;
        }
            break;
        case MCOIMAPFolderFlagTrash:{//已删除
            flagString = kDeletedMsg;
        }
            break;
        case MCOIMAPFolderFlagDrafts:{//草稿箱
            flagString = kDrafts;
        }
            break;
        case MCOIMAPFolderFlagMarked:{//已标记
            flagString = originalFolderName;
        }
            break;
        case MCOIMAPFolderFlagArchive:{//归档
            flagString = originalFolderName;
        }
            break;
        case MCOIMAPFolderFlagFlagged:{//星标
            flagString = originalFolderName;
        }
            break;
        case MCOIMAPFolderFlagNoSelect:{
            flagString = originalFolderName;
        }
            break;
        case MCOIMAPFolderFlagSentMail:{//已发送
            flagString = kSent;
        }
            break;
        case MCOIMAPFolderFlagUnmarked:{//未标记
            flagString = originalFolderName;
        }
            break;
        case MCOIMAPFolderFlagImportant:{//重要
            flagString = originalFolderName;
        }
            break;
        case MCOIMAPFolderFlagNoInferiors:{//无子文件夹
            flagString = originalFolderName;
        }
            break;
        case MCOIMAPFolderFlagFolderTypeMask:{//多种组合
            flagString = originalFolderName;
        }
            break;
            
        default:
            flagString = originalFolderName;
            break;
    }
    
    return flagString;
    
}
#pragma mark - Action

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 1)
    {
        if (self.totalNumberOfInboxMessages >= 0)
            return 1;
        
        return 0;
    }
    
    return self.messages.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    switch (indexPath.section)
    {
        case 0:
        {
            MCTTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:mailCellIdentifier forIndexPath:indexPath];
            MCOIMAPMessage *message = self.messages[indexPath.row];
            
            cell.textLabel.text = message.header.subject;
            
            NSString *uidKey = [NSString stringWithFormat:@"%d", message.uid];
            NSString *cachedPreview = self.messagePreviews[uidKey];
            
            if (cachedPreview)
            {
                cell.detailTextLabel.text = cachedPreview;
            }
            else
            {
                NSString *folderName = [self.imapSession.defaultNamespace componentsFromPath:self.imapFolder.path][0];
                cell.messageRenderingOperation = [self.imapSession plainTextBodyRenderingOperationWithMessage:message
                                                                                                       folder:folderName];
                
                [cell.messageRenderingOperation start:^(NSString * plainTextBodyString, NSError * error) {
                    cell.detailTextLabel.text = plainTextBodyString;
                    cell.messageRenderingOperation = nil;
                    self.messagePreviews[uidKey] = plainTextBodyString;
                }];
            }
            
            return cell;
            break;
        }
            
        case 1:
        {
            UITableViewCell *cell =
            [tableView dequeueReusableCellWithIdentifier:inboxInfoIdentifier];
            
            if (!cell)
            {
                cell =
                [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                       reuseIdentifier:inboxInfoIdentifier];
                
                cell.textLabel.font = [UIFont boldSystemFontOfSize:14];
                cell.textLabel.textAlignment = NSTextAlignmentCenter;
                cell.detailTextLabel.textAlignment = NSTextAlignmentCenter;
            }
            
            if (self.messages.count < self.totalNumberOfInboxMessages)
            {
                cell.textLabel.text =
                [NSString stringWithFormat:@"Load %lu more",
                 MIN(self.totalNumberOfInboxMessages - self.messages.count,
                     DefaultLoadMessageNumber)];
            }
            else
            {
                cell.textLabel.text = nil;
                
            }
            
            cell.detailTextLabel.text =
            [NSString stringWithFormat:@"%ld message(s)",
             (long)self.totalNumberOfInboxMessages];
            
            cell.accessoryView = self.loadMoreActivityView;
            
            if (self.isLoading)
                [self.loadMoreActivityView startAnimating];
            else
                [self.loadMoreActivityView stopAnimating];
            
            return cell;
            break;
        }
            
        default:
            return nil;
            break;
    }
    

}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 70;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 1) {
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        
        if (!self.isLoading &&
            self.messages.count < self.totalNumberOfInboxMessages)
        {
            [self p_loadMailMessageHeadersWithNumber:self.messages.count + DefaultLoadMessageNumber];
            cell.accessoryView = self.loadMoreActivityView;
            [self.loadMoreActivityView startAnimating];
        }
        
    }else{
        
        MCOIMAPMessage *msg = self.messages[indexPath.row];
        MCTMsgViewController *vc = [[MCTMsgViewController alloc] init];
        vc.folder = @"INBOX";
        vc.message = msg;
        vc.session = self.imapSession;
        [self.navigationController pushViewController:vc animated:YES];
        
    }
}


@end
