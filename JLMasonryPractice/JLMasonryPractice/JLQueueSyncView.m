//
//  JLQueueSyncView.m
//  JLMasonryPractice
//
//  Created by Sunxiaolin on 17/3/22.
//  Copyright © 2017年 JackLin. All rights reserved.
//

#import "JLQueueSyncView.h"
#import <Masonry.h>

@interface JLQueueSyncView(){
    @private
    dispatch_queue_t _queue;
    dispatch_semaphore_t _semaphore;
}

@property  (nonatomic, strong) UIButton *waitButton;
@property  (nonatomic, strong) UIButton *signalButton;
@property  (nonatomic, strong) UIButton *doButton;

@end
@implementation JLQueueSyncView

- (instancetype)init{
    self = [super init];
    if (self) {
        //创建序列化线程
        _queue = dispatch_queue_create("com.jack.lin", nil);
        
        [self setupView];
    }
    
    return self;
}

- (void)setupView{
    
    NSMutableArray *buttonArray = [[NSMutableArray alloc] init];
    
    [self addSubview:self.waitButton];
    [buttonArray addObject:self.waitButton];
    
    [self addSubview:self.signalButton];
    [buttonArray addObject:self.signalButton];
    
    [self addSubview:self.doButton];
    [buttonArray addObject:self.doButton];
    
    [buttonArray mas_distributeViewsAlongAxis:MASAxisTypeHorizontal
                          withFixedItemLength:50
                                  leadSpacing:20
                                  tailSpacing:20];
    
    [buttonArray mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_top).offset(80);
    }];
    
    
}

#pragma mark - getters
- (UIButton *)waitButton{
    if (!_waitButton) {
        _waitButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_waitButton setTitle:@"Wait" forState:UIControlStateNormal];
        _waitButton.backgroundColor = [UIColor blueColor];
        _waitButton.titleLabel.font = [UIFont systemFontOfSize:16];
        [_waitButton addTarget:self
                        action:@selector(onClickWaitButton:)
              forControlEvents:UIControlEventTouchUpInside];
        
    }
    return _waitButton;
}

- (UIButton *)signalButton{
    if (!_signalButton) {
        _signalButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_signalButton setTitle:@"Signal" forState:UIControlStateNormal];
        _signalButton.backgroundColor = [UIColor blueColor];
        _signalButton.titleLabel.font = [UIFont systemFontOfSize:16];
        [_signalButton addTarget:self
                        action:@selector(onClickSignalButton:)
              forControlEvents:UIControlEventTouchUpInside];
        
    }
    return _signalButton;
}

- (UIButton *)doButton{
    if (!_doButton) {
        _doButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_doButton setTitle:@"DO" forState:UIControlStateNormal];
        _doButton.backgroundColor = [UIColor blueColor];
        _doButton.titleLabel.font = [UIFont systemFontOfSize:16];
        [_doButton addTarget:self
                          action:@selector(onClickDoButton:)
                forControlEvents:UIControlEventTouchUpInside];
        
    }
    return _doButton;
}

#pragma mark - ActionMethod
- (void)onClickWaitButton:(UIButton *)sender{

    if (!_semaphore) {
         _semaphore = dispatch_semaphore_create(0);
    }
   
    
    dispatch_async(_queue, ^{
        dispatch_semaphore_wait(_semaphore, DISPATCH_TIME_FOREVER);
    });
    
}

- (void)onClickSignalButton:(UIButton *)sender{
    dispatch_semaphore_signal(_semaphore);
}

- (void)onClickDoButton:(UIButton *)sender{
    dispatch_async(_queue, ^{
        
        NSLog(@"dodo Something!!");
    });
}
@end
