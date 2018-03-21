//
//  SPLibraryManager.h
//  FBSnapshotTestCase
//
//  Created by zhuguoqiang on 2018/3/16.
//

#import <Foundation/Foundation.h>

@interface SPLibraryManager : NSObject

+(id)defaultManager;

- (NSArray *)queryLibray;

@end
