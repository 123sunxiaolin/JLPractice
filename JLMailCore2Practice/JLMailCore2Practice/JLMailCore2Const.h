//
//  JLMailCore2Const.h
//  JLMailCore2Practice
//
//  Created by perfect on 2017/6/20.
//  Copyright © 2017年 JackLin. All rights reserved.
//

#ifndef JLMailCore2Const_h
#define JLMailCore2Const_h

static NSInteger const DefaultLoadMessageNumber = 10;

static NSString *const kInbox = @"INBOX";//INBOX 收件箱
static NSString *const kSent = @"Sent Messages";//已发送
static NSString *const kDrafts = @"Drafts";//草稿箱
static NSString *const kDeletedMsg = @"Deleted Messages";//已删除
static NSString *const kJunk = @"Junk";//Junk 垃圾箱

#pragma mark - IMAP
//Gmail
static NSString *const IMAP_HOST = @"imap.gmail.com";
static NSInteger const IMAP_PORT = 993;
static NSString *const IMAP_UserName = @"sun15369302871@gmail.com";
static NSString *const IMAP_Password = @"dxtecmbidgiqikny";

//163
/*static NSString *const IMAP_HOST = @"imap.163.com";
static NSInteger const IMAP_PORT = 993;
static NSString *const IMAP_UserName = @"jacklin88888888@163.com";
static NSString *const IMAP_Password = @"sunxiaolin123";*/

//sina
/*static NSString *const IMAP_HOST = @"imap.sina.com";
static NSInteger const IMAP_PORT = 993;
static NSString *const IMAP_UserName = @"jacklin88888888@sina.com";
static NSString *const IMAP_Password = @"sunxiaolin";*/

//QQ
/*static NSString *const IMAP_HOST = @"imap.qq.com";
static NSInteger const IMAP_PORT = 993;
static NSString *const IMAP_UserName = @"907249371@qq.com";
static NSString *const IMAP_Password = @"ogflmpeebhnbbfgi";*/

//yahoo
/*static NSString *const IMAP_HOST = @"imap.mail.yahoo.com";
 static NSInteger const IMAP_PORT = 993;
 static NSString *const IMAP_UserName = @"jacklin.lin@yahoo.com";
 static NSString *const IMAP_Password = @"ogmzg vzwhmj eaaqch";*/

/*static NSString *const IMAP_HOST = @"imap.qq.com";
static NSInteger const IMAP_PORT = 993;
static NSString *const IMAP_UserName = @"946158139@qq.com";
static NSString *const IMAP_Password = @"lgrhkrewpogrbech";*/

#pragma mark - POP
/*static NSString *const POP_HOST = @"pop.qq.com";
static NSInteger const POP_PORT = 995;
static NSString *const POP_UserName = @"907249371@qq.com";
static NSString *const POP_Password = @"spzftbeyimcxbdgg";*/

//163
static NSString *const POP_HOST = @"pop.163.com";
static NSInteger const POP_PORT = 995;
static NSString *const POP_UserName = @"jacklin88888888@163.com";
static NSString *const POP_Password = @"sunxiaolin123";


#pragma mark - SMTP
//163
static NSString *const SMTP_HOST = @"smtp.163.com";
static NSInteger const SMTP_PORT = 465;
static NSString *const SMTP_UserName = @"jacklin88888888@163.com";
static NSString *const SMTP_Password = @"sunxiaolin123";

#endif /* JLMailCore2Const_h */
