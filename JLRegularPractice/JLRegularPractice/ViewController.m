//
//  ViewController.m
//  JLRegularPractice
//
//  Created by perfect on 2017/5/2.
//  Copyright © 2017年 JackLin. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    NSString *str = @"@{cube:123384,name:嘻嘻}";
    NSArray *array = [self matchString:str];
    
    [self p_regularMatchString:@"Is is the cost of of gasoline going up up"];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSArray *)matchString:(NSString *)sendText
{
    NSString* pattern =  @"@{cube:([0-9]*)?,name:([^\\}]*)}";
    //NSString *pattern = [NSString stringWithFormat:@"%@([^%@]+)%@",CWInputAtStartChar,CWInputAtEndChar,CWInputAtEndChar];
    NSError *error = nil;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:&error];
    NSArray *results = [regex matchesInString:sendText options:0 range:NSMakeRange(0, sendText.length)];
    NSMutableArray *matchs = [[NSMutableArray alloc] init];
    for (NSTextCheckingResult *result in results) {
        NSString *name = [sendText substringWithRange:result.range];
        name = [name substringFromIndex:1];
        name = [name substringToIndex:name.length -1];
        [matchs addObject:name];
    }
    return matchs;
}

- (void)p_regularMatchString:(NSString *)string{
    NSString *pattern = @"1[3578]";
    NSError *error = nil;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionDotMatchesLineSeparators error:&error];
    NSArray *results = [regex matchesInString:string options:0 range:NSMakeRange(0, string.length)];
    
}

@end
