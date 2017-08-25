//
//  POPDetailViewController.m
//  JLMailCore2Practice
//
//  Created by perfect on 2017/6/23.
//  Copyright © 2017年 JackLin. All rights reserved.
//

#import "POPDetailViewController.h"
#import <MailCore/MailCore.h>

static NSString * mainJavascript = @"\
var imageElements = function() {\
var imageNodes = document.getElementsByTagName('img');\
return [].slice.call(imageNodes);\
};\
\
var findCIDImageURL = function() {\
var images = imageElements();\
\
var imgLinks = [];\
for (var i = 0; i < images.length; i++) {\
var url = images[i].getAttribute('src');\
if (url.indexOf('cid:') == 0 || url.indexOf('x-mailcore-image:') == 0)\
imgLinks.push(url);\
}\
return JSON.stringify(imgLinks);\
};\
\
var replaceImageSrc = function(info) {\
var images = imageElements();\
\
for (var i = 0; i < images.length; i++) {\
var url = images[i].getAttribute('src');\
if (url.indexOf(info.URLKey) == 0) {\
images[i].setAttribute('src', info.LocalPathKey);\
break;\
}\
}\
};\
";

static NSString * mainStyle = @"\
body {\
font-family: Helvetica;\
font-size: 14px;\
word-wrap: break-word;\
-webkit-text-size-adjust:none;\
-webkit-nbsp-mode: space;\
}\
\
pre {\
white-space: pre-wrap;\
}\
";


@interface POPDetailViewController ()<UIWebViewDelegate, MCOHTMLRendererDelegate>

@property (nonatomic, strong) UIWebView *webView;

@end

@implementation POPDetailViewController

#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.view addSubview:self.webView];
    [self p_loadMailHtmlBody];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Getters
- (UIWebView *)webView{
    if (!_webView) {
        CGRect rect = CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame));
        _webView = [[UIWebView alloc] initWithFrame:rect];
    }
    return _webView;
}

#pragma mark - Private
- (void)p_loadMailHtmlBody{
    
    NSString *htmlString = [self.messageParser htmlBodyRendering];
    [self.webView stopLoading];
    
    NSMutableString * html = [NSMutableString string];
    [html appendFormat:@"<html><head><script>%@</script><style>%@</style></head>"
     @"<body>%@</body><iframe src='x-mailcore-msgviewloaded:' style='width: 0px; height: 0px; border: none;'>"
     @"</iframe></html>", mainJavascript, mainStyle, htmlString];
    
    [self.webView loadHTMLString:html baseURL:nil];
    
}

#pragma mark - Action
#pragma mark - UIWebViewDelegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    //To Do 可在这里实现图片资源的拦截
    
    return YES;
}
#pragma mark - MCOHTMLRendererDelegate
- (BOOL) MCOAbstractMessage:(MCOAbstractMessage *)msg canPreviewPart:(MCOAbstractPart *)part{
    
    static NSMutableSet * supportedImageMimeTypes = NULL;
    if (supportedImageMimeTypes == NULL) {
        supportedImageMimeTypes = [[NSMutableSet alloc] init];
        [supportedImageMimeTypes addObject:@"image/png"];
        [supportedImageMimeTypes addObject:@"image/gif"];
        [supportedImageMimeTypes addObject:@"image/jpg"];
        [supportedImageMimeTypes addObject:@"image/jpeg"];
    }
    static NSMutableSet * supportedImageExtension = NULL;
    if (supportedImageExtension == NULL) {
        supportedImageExtension = [[NSMutableSet alloc] init];
        [supportedImageExtension addObject:@"png"];
        [supportedImageExtension addObject:@"gif"];
        [supportedImageExtension addObject:@"jpg"];
        [supportedImageExtension addObject:@"jpeg"];
    }
    
    if ([supportedImageMimeTypes containsObject:[[part mimeType] lowercaseString]]) {
        return YES;
    }
    
    NSString * ext = nil;
    if ([part filename] != nil) {
        if ([[part filename] pathExtension] != nil) {
            ext = [[[part filename] pathExtension] lowercaseString];
        }
    }
    if (ext != nil) {
        if ([supportedImageExtension containsObject:ext])
            return YES;
    }
    
    // tiff, tif, pdf
    NSString * mimeType = [[part mimeType] lowercaseString];
    if ([mimeType isEqualToString:@"image/tiff"]) {
        return YES;
    }
    else if ([mimeType isEqualToString:@"image/tif"]) {
        return YES;
    }
    else if ([mimeType isEqualToString:@"application/pdf"]) {
        return YES;
    }
    
    NSString * ext1 = nil;
    if ([part filename] != nil) {
        if ([[part filename] pathExtension] != nil) {
            ext1 = [[[part filename] pathExtension] lowercaseString];
        }
    }
    if (ext1 != nil) {
        if ([ext1 isEqualToString:@"tiff"]) {
            return YES;
        }
        else if ([ext1 isEqualToString:@"tif"]) {
            return YES;
        }
        else if ([ext1 isEqualToString:@"pdf"]) {
            return YES;
        }
    }
    
    return NO;
}

- (NSDictionary *) MCOAbstractMessage:(MCOAbstractMessage *)msg templateValuesForHeader:(MCOMessageHeader *)header{
    // TO DO
    return nil;
}

- (NSString *) MCOAbstractMessage:(MCOAbstractMessage *)msg templateForMainHeader:(MCOMessageHeader *)header{
    //针对邮件头进行处理, 可以实现移除头
    return nil;
}

- (NSString *) MCOAbstractMessage:(MCOAbstractMessage *)msg templateForImage:(MCOAbstractPart *)header{
    NSString * templateString;
    templateString = @"<img src=\"{{URL}}\"/>";
    templateString = [NSString stringWithFormat:@"<div id=\"{{CONTENTID}}\">%@</div>", templateString];
    return templateString;
}

- (NSString *) MCOAbstractMessage:(MCOAbstractMessage *)msg templateForAttachment:(MCOAbstractPart *)part{
    
    NSString *templateString = @"<div><img src=\"http://www.iconshock.com/img_jpg/OFFICE/general/jpg/128/attachment_icon.jpg\"/></div>\
    {{#HASSIZE}}\
    <div>- {{FILENAME}}, {{SIZE}}</div>\
    {{/HASSIZE}}\
    {{#NOSIZE}}\
    <div>- {{FILENAME}}</div>\
    {{/NOSIZE}}";
    templateString = [NSString stringWithFormat:@"<div id=\"{{CONTENTID}}\">%@</div>", templateString];
    return templateString;
    
}

- (NSString *) MCOAbstractMessage_templateForMessage:(MCOAbstractMessage *)msg{
    
    return @"<div style=\"padding-bottom: 20px; font-family: Helvetica; font-size: 13px;\">{{HEADER}}</div><div>{{BODY}}</div>";
}

- (NSString *) MCOAbstractMessage:(MCOAbstractMessage *)msg templateForEmbeddedMessageHeader:(MCOMessageHeader *)header{
    
    return nil;
}

- (NSString *) MCOAbstractMessage:(MCOAbstractMessage *)msg filterHTMLForPart:(NSString *)html{
    return nil;
}

/*- (NSData *) MCOAbstractMessage:(MCOAbstractMessage *)msg dataForIMAPPart:(MCOIMAPPart *)part folder:(NSString *)folder
{
    return [self _dataForIMAPPart:part folder:folder];
}

- (void) MCOAbstractMessage:(MCOAbstractMessage *)msg prefetchAttachmentIMAPPart:(MCOIMAPPart *)part folder:(NSString *)folder
{
    if (!_prefetchIMAPAttachmentsEnabled)
        return;
    
    NSString * partUniqueID = [part uniqueID];
    [[self delegate] MCOMessageView:self fetchDataForPartWithUniqueID:partUniqueID downloadedFinished:^(NSError * error) {
        // do nothing
    }];
}

- (void) MCOAbstractMessage:(MCOAbstractMessage *)msg prefetchImageIMAPPart:(MCOIMAPPart *)part folder:(NSString *)folder
{
    if (!_prefetchIMAPImagesEnabled)
        return;
    
    NSString * partUniqueID = [part uniqueID];
    [[self delegate] MCOMessageView:self fetchDataForPartWithUniqueID:partUniqueID downloadedFinished:^(NSError * error) {
        // do nothing
    }];
}*/

@end
