//
//  ZBToken.m
//  JLMailCore2Practice
//
//  Created by perfect on 2017/6/26.
//  Copyright © 2017年 JackLin. All rights reserved.
//

#import "ZBToken.h"

CGFloat const hTextPadding = 14;
CGFloat const vTextPadding = 8;
CGFloat const kDisclosureThickness = 2.5;
NSLineBreakMode const kLineBreakMode = NSLineBreakByTruncatingTail;

@interface ZBToken (Private)

CGPathRef CGPathCreateTokenPath(CGSize size, BOOL innerPath);
CGPathRef CGPathCreateDisclosureIndicatorPath(CGPoint arrowPointFront, CGFloat height, CGFloat thickness, CGFloat * width);
- (BOOL)getTintColorRed:(CGFloat *)red green:(CGFloat *)green blue:(CGFloat *)blue alpha:(CGFloat *)alpha;

@end

@implementation ZBToken

#pragma mark Init
- (instancetype)initWithTitle:(NSString *)aTitle {
    return [self initWithTitle:aTitle representedObject:nil];
}

- (instancetype)initWithTitle:(NSString *)aTitle representedObject:(id)object {
    return [self initWithTitle:aTitle representedObject:object font:[UIFont systemFontOfSize:14]];
}

- (instancetype)initWithTitle:(NSString *)aTitle representedObject:(id)object font:(UIFont *)aFont {
    
    if ((self = [super init])){
        
        _title = [aTitle copy];
        _representedObject = object;
        
        _font = aFont;
        _tintColor = [ZBToken blueTintColor];
        _textColor = [UIColor blackColor];
        _highlightedTextColor = [UIColor whiteColor];
        
        _accessoryType = ZBTokenAccessoryTypeNone;
        _maxWidth = 200;
        
        [self setBackgroundColor:[UIColor clearColor]];
        [self sizeToFit];
    }
    
    return self;
}

#pragma mark Property Overrides
- (void)setHighlighted:(BOOL)flag {
    
    if (self.highlighted != flag){
        [super setHighlighted:flag];
        [self setNeedsDisplay];
    }
}

- (void)setSelected:(BOOL)flag {
    
    if (self.selected != flag){
        [super setSelected:flag];
        [self setNeedsDisplay];
    }
}

- (void)setTitle:(NSString *)newTitle {
    
    if (newTitle){
        _title = [newTitle copy];
        [self sizeToFit];
        [self setNeedsDisplay];
    }
}

- (void)setFont:(UIFont *)newFont {
    
    if (!newFont) newFont = [UIFont systemFontOfSize:14];
    
    if (_font != newFont){
        _font = newFont;
        [self sizeToFit];
        [self setNeedsDisplay];
    }
}

- (void)setTintColor:(UIColor *)newTintColor {
    
    if (!newTintColor) newTintColor = [ZBToken blueTintColor];
    
    if (_tintColor != newTintColor){
        _tintColor = newTintColor;
        [self setNeedsDisplay];
    }
}

- (void)setAccessoryType:(ZBTokenAccessoryType)type {
    
    if (_accessoryType != type){
        _accessoryType = type;
        [self sizeToFit];
        [self setNeedsDisplay];
    }
}

- (void)setMaxWidth:(CGFloat)width {
    
    if (_maxWidth != width){
        _maxWidth = width;
        [self sizeToFit];
        [self setNeedsDisplay];
    }
}

#pragma Tint Color Convenience

+ (UIColor *)blueTintColor {
    return [UIColor colorWithRed:0.216 green:0.373 blue:0.965 alpha:1];
}

+ (UIColor *)redTintColor {
    return [UIColor colorWithRed:1 green:0.15 blue:0.15 alpha:1];
}

+ (UIColor *)greenTintColor {
    return [UIColor colorWithRed:0.333 green:0.741 blue:0.235 alpha:1];
}

#pragma mark Layout
- (CGSize)sizeThatFits:(CGSize)size {
    
    CGFloat accessoryWidth = 0;
    
    if (_accessoryType == ZBTokenAccessoryTypeDisclosureIndicator){
        CGPathRelease(CGPathCreateDisclosureIndicatorPath(CGPointZero, _font.pointSize, kDisclosureThickness, &accessoryWidth));
        accessoryWidth += floorf(hTextPadding / 2);
    }
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    
    CGSize titleSize = [_title sizeWithFont:_font forWidth:(_maxWidth - hTextPadding - accessoryWidth) lineBreakMode:kLineBreakMode];
    
#pragma clang diagnostic pop
    
    CGFloat height = floorf(titleSize.height + vTextPadding);
    
    return (CGSize){MAX(floorf(titleSize.width + hTextPadding + accessoryWidth), height - 3), height};
}

#pragma mark Drawing
- (void)drawRect:(CGRect)rect {
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // Draw the outline.
    CGContextSaveGState(context);
    CGPathRef outlinePath = CGPathCreateTokenPath(self.bounds.size, NO);
    CGContextAddPath(context, outlinePath);
    CGPathRelease(outlinePath);
    
    BOOL drawHighlighted = (self.selected || self.highlighted);
    CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceRGB();
    CGPoint endPoint = CGPointMake(0, self.bounds.size.height);
    
    CGFloat red = 1;
    CGFloat green = 1;
    CGFloat blue = 1;
    CGFloat alpha = 1;
    [self getTintColorRed:&red green:&green blue:&blue alpha:&alpha];
    
    if (drawHighlighted){
        CGContextSetFillColor(context, (CGFloat[4]){red, green, blue, 1});
        CGContextFillPath(context);
    }
    else
    {
        CGContextClip(context);
        CGFloat locations[2] = {0, 0.95};
        CGFloat components[8] = {red + 0.2, green + 0.2, blue + 0.2, alpha, red, green, blue, 0.8};
        CGGradientRef gradient = CGGradientCreateWithColorComponents(colorspace, components, locations, 2);
        CGContextDrawLinearGradient(context, gradient, CGPointZero, endPoint, 0);
        CGGradientRelease(gradient);
    }
    
    CGContextRestoreGState(context);
    
    CGPathRef innerPath = CGPathCreateTokenPath(self.bounds.size, YES);
    
    // Draw a white background so we can use alpha to lighten the inner gradient
    CGContextSaveGState(context);
    CGContextAddPath(context, innerPath);
    CGContextSetFillColor(context, (CGFloat[4]){1, 1, 1, 1});
    CGContextFillPath(context);
    CGContextRestoreGState(context);
    
    // Draw the inner gradient.
    CGContextSaveGState(context);
    CGContextAddPath(context, innerPath);
    CGPathRelease(innerPath);
    CGContextClip(context);
    
    CGFloat locations[2] = {0, (drawHighlighted ? 0.9 : 0.6)};
    CGFloat highlightedComp[8] = {red, green, blue, 0.7, red, green, blue, 1};
    CGFloat nonHighlightedComp[8] = {red, green, blue, 0.15, red, green, blue, 0.3};
    
    CGGradientRef gradient = CGGradientCreateWithColorComponents(colorspace, (drawHighlighted ? highlightedComp : nonHighlightedComp), locations, 2);
    CGContextDrawLinearGradient(context, gradient, CGPointZero, endPoint, 0);
    CGGradientRelease(gradient);
    CGContextRestoreGState(context);
    
    CGFloat accessoryWidth = 0;
    
    if (_accessoryType == ZBTokenAccessoryTypeDisclosureIndicator){
        CGPoint arrowPoint = CGPointMake(self.bounds.size.width - floorf(hTextPadding / 2), (self.bounds.size.height / 2) - 1);
        CGPathRef disclosurePath = CGPathCreateDisclosureIndicatorPath(arrowPoint, _font.pointSize, kDisclosureThickness, &accessoryWidth);
        accessoryWidth += floorf(hTextPadding / 2);
        
        CGContextAddPath(context, disclosurePath);
        CGContextSetFillColor(context, (CGFloat[4]){1, 1, 1, 1});
        
        if (drawHighlighted){
            CGContextFillPath(context);
        }
        else
        {
            CGContextSaveGState(context);
            CGContextSetShadowWithColor(context, CGSizeMake(0, 1), 1, [[[UIColor whiteColor] colorWithAlphaComponent:0.6] CGColor]);
            CGContextFillPath(context);
            CGContextRestoreGState(context);
            
            CGContextSaveGState(context);
            CGContextAddPath(context, disclosurePath);
            CGContextClip(context);
            
            CGGradientRef disclosureGradient = CGGradientCreateWithColorComponents(colorspace, highlightedComp, NULL, 2);
            CGContextDrawLinearGradient(context, disclosureGradient, CGPointZero, endPoint, 0);
            CGGradientRelease(disclosureGradient);
            
            arrowPoint.y += 0.5;
            CGPathRef innerShadowPath = CGPathCreateDisclosureIndicatorPath(arrowPoint, _font.pointSize, kDisclosureThickness, NULL);
            CGContextAddPath(context, innerShadowPath);
            CGPathRelease(innerShadowPath);
            CGContextSetStrokeColor(context, (CGFloat[4]){0, 0, 0, 0.3});
            CGContextStrokePath(context);
            CGContextRestoreGState(context);
        }
        
        CGPathRelease(disclosurePath);
    }
    
    CGColorSpaceRelease(colorspace);
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    
    CGSize titleSize = [_title sizeWithFont:_font forWidth:(_maxWidth - hTextPadding - accessoryWidth) lineBreakMode:kLineBreakMode];
    
#pragma clang diagnostic pop
    
    CGFloat vPadding = floor((self.bounds.size.height - titleSize.height) / 2);
    CGFloat titleWidth = ceilf(self.bounds.size.width - hTextPadding - accessoryWidth);
    CGRect textBounds = CGRectMake(floorf(hTextPadding / 2), vPadding - 1, titleWidth, floorf(self.bounds.size.height - (vPadding * 2)));
    
    CGContextSetFillColorWithColor(context, (drawHighlighted ? _highlightedTextColor : _textColor).CGColor);
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    
    [_title drawInRect:textBounds withFont:_font lineBreakMode:kLineBreakMode];
    
#pragma clang diagnostic pop
}

CGPathRef CGPathCreateTokenPath(CGSize size, BOOL innerPath) {
    
    CGMutablePathRef path = CGPathCreateMutable();
    CGFloat arcValue = (size.height / 2) - 1;
    //修改显示的弧度
    CGFloat radius = arcValue - (innerPath ? (1 / [[UIScreen mainScreen] scale]) : 0);
    CGPathAddArc(path, NULL, arcValue, arcValue, radius, (M_PI / 2), (M_PI * 3 / 2), NO);
    CGPathAddArc(path, NULL, size.width - arcValue, arcValue, radius, (M_PI  * 3 / 2), (M_PI / 2), NO);
    CGPathCloseSubpath(path);
    
    return path;
}

CGPathRef CGPathCreateDisclosureIndicatorPath(CGPoint arrowPointFront, CGFloat height, CGFloat thickness, CGFloat * width) {
    
    thickness /= cosf(M_PI / 4);
    
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, arrowPointFront.x, arrowPointFront.y);
    
    CGPoint bottomPointFront = CGPointMake(arrowPointFront.x - (height / (2 * tanf(M_PI / 4))), arrowPointFront.y - height / 2);
    CGPathAddLineToPoint(path, NULL, bottomPointFront.x, bottomPointFront.y);
    
    CGPoint bottomPointBack = CGPointMake(bottomPointFront.x - thickness * cosf(M_PI / 4),  bottomPointFront.y + thickness * sinf(M_PI / 4));
    CGPathAddLineToPoint(path, NULL, bottomPointBack.x, bottomPointBack.y);
    
    CGPoint arrowPointBack = CGPointMake(arrowPointFront.x - thickness / cosf(M_PI / 4), arrowPointFront.y);
    CGPathAddLineToPoint(path, NULL, arrowPointBack.x, arrowPointBack.y);
    
    CGPoint topPointFront = CGPointMake(bottomPointFront.x, arrowPointFront.y + height / 2);
    CGPoint topPointBack = CGPointMake(bottomPointBack.x, topPointFront.y - thickness * sinf(M_PI / 4));
    
    CGPathAddLineToPoint(path, NULL, topPointBack.x, topPointBack.y);
    CGPathAddLineToPoint(path, NULL, topPointFront.x, topPointFront.y);
    CGPathAddLineToPoint(path, NULL, arrowPointFront.x, arrowPointFront.y);
    
    if (width) *width = (arrowPointFront.x - topPointBack.x);
    return path;
}

- (BOOL)getTintColorRed:(CGFloat *)red green:(CGFloat *)green blue:(CGFloat *)blue alpha:(CGFloat *)alpha {
    
    CGColorSpaceModel colorSpaceModel = CGColorSpaceGetModel(CGColorGetColorSpace(_tintColor.CGColor));
    const CGFloat * components = CGColorGetComponents(_tintColor.CGColor);
    
    if (colorSpaceModel == kCGColorSpaceModelMonochrome || colorSpaceModel == kCGColorSpaceModelRGB){
        
        if (red) *red = components[0];
        if (green) *green = (colorSpaceModel == kCGColorSpaceModelMonochrome ? components[0] : components[1]);
        if (blue) *blue = (colorSpaceModel == kCGColorSpaceModelMonochrome ? components[0] : components[2]);
        if (alpha) *alpha = (colorSpaceModel == kCGColorSpaceModelMonochrome ? components[1] : components[3]);
        
        return YES;
    }
    
    return NO;
}

#pragma mark Other
- (NSString *)description {
    return [NSString stringWithFormat:@"<TIToken %p; title = \"%@\"; representedObject = \"%@\">", self, _title, _representedObject];
}
@end
