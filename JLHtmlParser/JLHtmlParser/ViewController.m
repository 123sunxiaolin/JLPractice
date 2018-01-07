//
//  ViewController.m
//  JLHtmlParser
//
//  Created by perfect on 2017/12/26.
//  Copyright © 2017年 JackLin. All rights reserved.
//

#import "ViewController.h"
#import "OCGumbo.h"
#import "OCGumbo+Query.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    NSString *urlString = @"https://www.baidu.com";
    NSURL *url = [NSURL URLWithString:urlString];
    NSString *htmlString = [NSString stringWithContentsOfURL:url
                                                    encoding:NSUTF8StringEncoding
                                                       error:nil];
    //1、获取文档对象
    OCGumboDocument *document = [[OCGumboDocument alloc] initWithHTMLString:htmlString];
    //OCGumboElement *headElement = document.head;
    
    
    //2、获取节点内容
    OCGumboElement *aElement = document.Query(@"body");
    NSLog(@"element = %@", aElement.text);
    
    
    
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
