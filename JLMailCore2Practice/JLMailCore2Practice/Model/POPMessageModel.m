//
//  POPMessageModel.m
//  JLMailCore2Practice
//
//  Created by perfect on 2017/6/21.
//  Copyright © 2017年 JackLin. All rights reserved.
//

#import "POPMessageModel.h"


@implementation POPMessageModel

- (id)copyWithZone:(nullable NSZone *)zone{
    
    POPMessageModel *model = [[POPMessageModel alloc] init];
    model.messageHeader = _messageHeader;
    model.popMessageInfo = _popMessageInfo;
    return model;
    
}

@end
