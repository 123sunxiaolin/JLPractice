//
//  ViewController.m
//  SamplesObjC
//
//  Created by Shin Yamamoto on 2018/12/07.
//  Copyright © 2018 Shin Yamamoto. All rights reserved.
//

#import "ViewController.h"

/* --- Importing Swift into Objective-C -- */
#import "SamplesObjC-Swift.h"
@class FloatingPanelAdapter;
/* --------------------------------------- */

@interface ViewController ()
@property FloatingPanelAdapter *fpAdapter;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.fpAdapter = [[FloatingPanelAdapter alloc] init];
    [self.fpAdapter addPanelWithVc:self];
}


@end
