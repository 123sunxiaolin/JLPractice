//
//  POPMessageModel.h
//  JLMailCore2Practice
//
//  Created by perfect on 2017/6/21.
//  Copyright © 2017年 JackLin. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MCOMessageHeader, MCOPOPMessageInfo;
@interface POPMessageModel : NSObject<NSCopying>

@property (nonatomic, copy) MCOMessageHeader *messageHeader;
@property (nonatomic, copy) MCOPOPMessageInfo *popMessageInfo;

@end
