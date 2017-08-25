//
//  JLSearchTextField.m
//  JLSrearchController
//
//  Created by perfect on 2017/5/22.
//  Copyright © 2017年 JackLin. All rights reserved.
//

#import "JLSearchTextField.h"

@implementation JLSearchTextField

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    self.canTouch = YES;
    return self;
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event{
    BOOL result = [super pointInside:point withEvent:event];
    if (_canTouch) {
        return result;
    }else{
        return NO;
    }
}

- (void)dealloc {
    NSLog(@"JLSearchTextField dealloc");
}
@end
