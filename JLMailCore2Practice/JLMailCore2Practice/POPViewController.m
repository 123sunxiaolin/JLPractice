//
//  POPViewController.m
//  JLMailCore2Practice
//
//  Created by perfect on 2017/6/21.
//  Copyright © 2017年 JackLin. All rights reserved.
//

#import "POPViewController.h"
#import <MailCore/MailCore.h>
#import "JLMailCore2Const.h"
#import "POPMessageModel.h"
#import "MCTMsgViewController.h"
#import "POPDetailViewController.h"

@interface POPViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) MCOPOPSession *popSession;

@property (nonatomic, strong) UITableView *popFolderTableView;

@property (nonatomic, strong) NSArray<MCOPOPMessageInfo *> *allMailPopMessages;//原始

@property (nonatomic, strong) NSMutableArray<MCOPOPMessageInfo *> *popMessageInfoMutableArray;//用于实现请求队列

@property (nonatomic, strong) NSMutableArray<POPMessageModel *> *popMessagesArray;//最后组装的数据

@end

@implementation POPViewController

#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"POP";
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.popFolderTableView];
    self.popMessagesArray = [[NSMutableArray alloc] init];
    [self p_startConnectMail];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Getters
- (UITableView *)popFolderTableView{
    if (!_popFolderTableView) {
        CGRect rect = CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame));
        _popFolderTableView = [[UITableView alloc] initWithFrame:rect];
        _popFolderTableView.dataSource = self;
        _popFolderTableView.delegate = self;
        _popFolderTableView.tableFooterView = [UIView new];
    }
    return _popFolderTableView;
}

- (MCOPOPSession *)popSession{
    if (!_popSession) {
        _popSession = [[MCOPOPSession alloc] init];
        _popSession.hostname = POP_HOST;
        _popSession.port = POP_PORT;
        _popSession.username = POP_UserName;
        _popSession.password = POP_Password;
        _popSession.connectionType = MCOConnectionTypeTLS;
    }
    return _popSession;
}

#pragma mark - Private
- (void)p_startConnectMail{
    
    //打印连接的log
    __weak typeof(self) weakSelf = self;
    self.popSession.connectionLogger = ^(void *connectionID, MCOConnectionLogType type, NSData *data) {
        @synchronized(weakSelf) {
            if (type != MCOConnectionLogTypeSentPrivate) {
                NSLog(@"event logged:%p %li withData: %@", connectionID, (long)type, [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
            }
        }
    };
    
    //检测邮箱的连接操作
    MCOPOPOperation *popCheckOperation = [self.popSession checkAccountOperation];
    [popCheckOperation start:^(NSError *error) {
        if (!error) {
            //连接成功
            [self p_fetchAllMessageInfos];
            
        }else{
            //连接失败
            NSLog(@"error loading account: %@", error);
        }
    }];
    
}

- (void)p_fetchAllMessageInfos{
    
    if (self.popMessageInfoMutableArray) {
        [self.popMessageInfoMutableArray removeAllObjects];
    }else{
        self.popMessageInfoMutableArray = [[NSMutableArray alloc] init];
    }
    
    MCOPOPFetchMessagesOperation *messagesFetchOperation = [self.popSession fetchMessagesOperation];
    [messagesFetchOperation start:^(NSError *error, NSArray *messages) {
        if (error) {
            NSLog(@"pop fetch error:%@", error);
            return ;
        }
        
        NSLog(@"messages = %@", messages);
        
        self.popMessageInfoMutableArray = [messages mutableCopy];
        
        //测试
        [self p_fetchMessageInfoWithMsgInfo:self.popMessageInfoMutableArray.firstObject];
        
    }];
        
}

- (void)p_fetchMessageInfoWithMsgInfo:(MCOPOPMessageInfo *)msgInfo{
    
    int index = msgInfo.index;
    //获取邮件的头
    MCOPOPFetchHeaderOperation *headerFetchOperation = [self.popSession fetchHeaderOperationWithIndex:index];
    [headerFetchOperation start:^(NSError *error, MCOMessageHeader *header) {
        if (error) {
            NSLog(@"fetch header error, %@", error);
            return ;
        }
        NSLog(@"header = %@", header);
        
        POPMessageModel *msgModel = [[POPMessageModel alloc] init];
        msgModel.messageHeader = header;
        msgModel.popMessageInfo = msgInfo;
        [self.popMessagesArray addObject:msgModel];
        
        [self p_checkMessageInfoCompleted];
    }];

    /*MCOPOPFetchMessageOperation *fetchMessageOperation = [self.popSession fetchMessageOperationWithIndex:index];
    [fetchMessageOperation start:^(NSError *error, NSData *messageData) {
        if (error) {
            NSLog(@"fetch Message error, %@", error);
            return ;
        }
        
        MCOMessageParser *messageParser = [MCOMessageParser messageParserWithData:messageData];
        NSLog(@"messageContent = %@", messageParser.plainTextBodyRendering);
        
    }];*/
    
}

- (void)p_checkMessageInfoCompleted{
    [self.popMessageInfoMutableArray removeObjectAtIndex:0];
    if (self.popMessageInfoMutableArray.count) {
        [self p_fetchMessageInfoWithMsgInfo:self.popMessageInfoMutableArray.firstObject];
    }else{
        [self.popFolderTableView reloadData];
    }
}


#pragma mark - Action

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.popMessagesArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellId = @"POPMessageCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellId];
    }
    POPMessageModel *popMsgModel = self.popMessagesArray[indexPath.row];
    cell.textLabel.text = popMsgModel.messageHeader.subject;
    MCOAddress *address = popMsgModel.messageHeader.to.firstObject;
    NSString *detailString = [NSString stringWithFormat:@"由%@发送给%@", popMsgModel.messageHeader.from.mailbox,  address.mailbox];
    cell.detailTextLabel.text = detailString;
    
    return cell;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 70;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    POPMessageModel *popModel = self.popMessagesArray[indexPath.row];
    int index = popModel.popMessageInfo.index;
    MCOPOPFetchMessageOperation *fetchOperation = [self.popSession fetchMessageOperationWithIndex:index];
    [fetchOperation start:^(NSError *error, NSData *messageData) {
        if (error) {
            NSLog(@"fetch message error:%@", error);
            return ;
        }
        
        MCOMessageParser *msgParser = [MCOMessageParser messageParserWithData:messageData];
        
        //获取邮件HTML正文
        NSString *htmlString = [msgParser htmlRenderingWithDelegate:nil];
        NSString *htmlBodyString = [msgParser htmlBodyRendering];
        
        //获取plainText
        NSString *plainText = [msgParser plainTextRendering];
        NSString *plainBodyText = [msgParser plainTextBodyRendering];
        
        //获取邮件的头
        MCOMessageHeader *header = msgParser.header;
        
        //获取附件(多个)
        NSMutableArray *attachments=[[NSMutableArray alloc]initWithArray:msgParser.attachments];
        //MCOAttachment *attachment=attachments[0]; //拿到一个附件MCOAttachment,可从中得到文件名，文件内容data
        
        /*MCTMsgViewController *vc = [[MCTMsgViewController alloc] init];
        vc.folder = @"INBOX";
        vc.message = msgParser;
        //vc.session = self.imapSession;
        [self.navigationController pushViewController:vc animated:YES];*/
        
        POPDetailViewController *popVC = [[POPDetailViewController alloc] init];
        popVC.messageParser = msgParser;
        [self.navigationController pushViewController:popVC animated:YES];
        
        
        
        
    }];
    
}

@end
