//
//  SPLibraryManager.m
//  FBSnapshotTestCase
//
//  Created by zhuguoqiang on 2018/3/16.
//

#import "SPLibraryManager.h"

@implementation SPLibraryManager

+(id)defaultManager
{
    static SPLibraryManager *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[SPLibraryManager alloc] init];
    });
    
    return instance;
}

- (SPLibraryManager *)init
{
    self = [super init];
    if (self) {
        
    }
    return  self;
}

- (NSArray *)queryLibray
{
    return @[@"AFNetworking", @"SDWebImage"];
}

@end
