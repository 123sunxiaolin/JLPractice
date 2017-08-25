//
//  ZBTokenField.m
//  JLMailCore2Practice
//
//  Created by perfect on 2017/6/26.
//  Copyright © 2017年 JackLin. All rights reserved.
//

#import "ZBTokenField.h"
#import "ZBTokenFieldInternalDelegate.h"
#import "ZBToken.h"

@interface ZBTokenField (Private)
- (void)setup;
- (CGFloat)layoutTokensInternal;
@end

@interface ZBTokenField(){
    id __weak delegate;
    ZBTokenFieldInternalDelegate * _internalDelegate;
    NSMutableArray * _tokens;
    CGPoint _tokenCaret;
    UILabel * _placeHolderLabel;
}

@property (nonatomic, readonly) CGFloat leftViewWidth;
@property (nonatomic, readonly) CGFloat rightViewWidth;
@property (weak, nonatomic, readonly) UIScrollView * scrollView;

@end

@implementation ZBTokenField

#pragma mark Init
- (instancetype)initWithFrame:(CGRect)frame {
    
    if ((self = [super initWithFrame:frame])){
        [self setup];
    }
    
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    
    if ((self = [super initWithCoder:aDecoder])){
        [self setup];
    }
    
    return self;
}

- (void)setup {
    
    [self setBorderStyle:UITextBorderStyleNone];
    [self setFont:[UIFont systemFontOfSize:14]];
    [self setBackgroundColor:[UIColor whiteColor]];
    [self setAutocorrectionType:UITextAutocorrectionTypeNo];
    [self setAutocapitalizationType:UITextAutocapitalizationTypeNone];
    [self setContentVerticalAlignment:UIControlContentVerticalAlignmentTop];
    
    [self addTarget:self action:@selector(didBeginEditing) forControlEvents:UIControlEventEditingDidBegin];
    [self addTarget:self action:@selector(didEndEditing) forControlEvents:UIControlEventEditingDidEnd];
    [self addTarget:self action:@selector(didChangeText) forControlEvents:UIControlEventEditingChanged];
    
    [self setPromptText:@"To:"];
    [self setText:kTextEmpty];
    self.promptColor = [UIColor colorWithWhite:0.5 alpha:1];
    
    _internalDelegate = [[ZBTokenFieldInternalDelegate alloc] init];
    [_internalDelegate setTokenField:self];
    [super setDelegate:_internalDelegate];
    
    [self setShowShadow:YES];
    
    _tokens = [NSMutableArray array];
    _editable = YES;
    _removesTokensOnEndEditing = YES;
    _tokenizingCharacters = [NSCharacterSet characterSetWithCharactersInString:@","];
    _tokenLimit = -1;
}

#pragma mark Property Overrides
- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    [self.layer setShadowPath:[[UIBezierPath bezierPathWithRect:self.bounds] CGPath]];
    [self layoutTokensAnimated:NO];
}

- (void)setShowShadow:(BOOL)showShadow {
    _showShadow = showShadow;
    if (showShadow) {
        [self.layer setShadowColor:[[UIColor blackColor] CGColor]];
        [self.layer setShadowOpacity:0.6];
        [self.layer setShadowRadius:12];
    } else {
        [self.layer setShadowColor:[[UIColor clearColor] CGColor]];
    }
}

- (void)setText:(NSString *)text {
    [super setText:(text.length == 0 ? kTextEmpty : text)];
}

- (void)setFont:(UIFont *)font {
    [super setFont:font];
    
    if ([self.leftView isKindOfClass:[UILabel class]]){
        [self setPromptText:((UILabel *)self.leftView).text];
    }
}

- (void)setDelegate:(id<ZBTokenFieldDelegate>)del {
    delegate = del;
    [_internalDelegate setDelegate:delegate];
}

- (NSArray *)tokens {
    return [_tokens copy];
}

- (NSArray *)tokenTitles {
    
    NSMutableArray * titles = [NSMutableArray array];
    [_tokens enumerateObjectsUsingBlock:^(ZBToken * token, NSUInteger idx, BOOL *stop){
        if (token.title) [titles addObject:token.title];
    }];
    return titles;
}

- (NSArray *)tokenObjects {
    
    NSMutableArray * objects = [NSMutableArray array];
    [_tokens enumerateObjectsUsingBlock:^(ZBToken * token, NSUInteger idx, BOOL *stop){
        if (token.representedObject) [objects addObject:token.representedObject];
        else if (token.title) [objects addObject:token.title];
    }];
    return objects;
}

- (UIScrollView *)scrollView {
    return ([self.superview isKindOfClass:[UIScrollView class]] ? (UIScrollView *)self.superview : nil);
}

#pragma mark Event Handling
- (BOOL)becomeFirstResponder {
    return (_editable ? [super becomeFirstResponder] : NO);
}

- (void)didBeginEditing {
    if (_removesTokensOnEndEditing) {
        [_tokens enumerateObjectsUsingBlock:^(ZBToken * token, NSUInteger idx, BOOL *stop){[self addTokenToView:token];}];
    }
}

- (void)didEndEditing {
    
    [_selectedToken setSelected:NO];
    _selectedToken = nil;
    
    [self tokenizeText];
    
    if (_removesTokensOnEndEditing){
        
        [_tokens enumerateObjectsUsingBlock:^(ZBToken * token, NSUInteger idx, BOOL *stop){[token removeFromSuperview];}];
        
        NSString * untokenized = kTextEmpty;
        if (_tokens.count){
            
            NSArray * titles = self.tokenTitles;
            untokenized = [titles componentsJoinedByString:@", "];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
            
            CGSize untokSize = [untokenized sizeWithFont:[UIFont systemFontOfSize:14]];
            
#pragma clang diagnostic pop
            
            CGFloat availableWidth = self.bounds.size.width - self.leftView.bounds.size.width - self.rightView.bounds.size.width;
            
            if (_tokens.count > 1 && untokSize.width > availableWidth){//隐藏后的默认提示语
                untokenized = [NSString stringWithFormat:@"%ld recipients", titles.count];
            }
            
        }
        
        [self setText:untokenized];
    }
    
    [self setResultsModeEnabled:NO];
    if (_tokens.count < 1 && self.forcePickSearchResult) {
        [self becomeFirstResponder];
    }
}

- (void)didChangeText {
    if (!self.text.length)[self setText:kTextEmpty];
    [self showOrHidePlaceHolderLabel];
}

- (void) showOrHidePlaceHolderLabel {
    [_placeHolderLabel setHidden:!(([self.text isEqualToString:kTextEmpty]) && !_tokens.count)];
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
    
    // Stop the cut, copy, select and selectAll appearing when the field is 'empty'.
    if (action == @selector(cut:) || action == @selector(copy:) || action == @selector(select:) || action == @selector(selectAll:))
        return ![self.text isEqualToString:kTextEmpty];
    
    return [super canPerformAction:action withSender:sender];
}

- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    
    if (_selectedToken && touch.view == self) [self deselectSelectedToken];
    return [super beginTrackingWithTouch:touch withEvent:event];
}

#pragma mark Token Handling
- (ZBToken *)addTokenWithTitle:(NSString *)title {
    return [self addTokenWithTitle:title representedObject:nil];
}

- (ZBToken *)addTokenWithTitle:(NSString *)title representedObject:(id)object {
    
    if (title.length){
        ZBToken * token = [[ZBToken alloc] initWithTitle:title representedObject:object font:self.font];
        [self addToken:token];
        return token;
    }
    
    return nil;
}

- (void)addTokensWithTitleList:(NSString *)titleList {
    if ([titleList length] > 0) {
        self.text = titleList;
        [self tokenizeText];
    }
}

- (void)addTokensWithTitleArray:(NSArray *)titleArray {
    for (NSString *title in titleArray) {
        [self addTokenWithTitle:title];
    }
}

- (void)addToken:(ZBToken *)token {
    
    BOOL shouldAdd = YES;
    if ([delegate respondsToSelector:@selector(tokenField:willAddToken:)]){
        shouldAdd = [delegate tokenField:self willAddToken:token];
    }
    
    if (shouldAdd){
        
        //[self becomeFirstResponder];
        if (![_tokens containsObject:token]) {
            [_tokens addObject:token];
            
            if ([delegate respondsToSelector:@selector(tokenField:didAddToken:)]){
                [delegate tokenField:self didAddToken:token];
            }
        }
        
        [self addTokenToView:token];
        
    }
}

- (void) addTokenToView:(ZBToken *)token
{
    [token addTarget:self action:@selector(tokenTouchDown:) forControlEvents:UIControlEventTouchDown];
    [token addTarget:self action:@selector(tokenTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:token];
    [self layoutTokensAnimated:YES];
    [self showOrHidePlaceHolderLabel];
    [self setResultsModeEnabled:_alwaysShowSearchResult];
    [self deselectSelectedToken];
}

- (void)removeToken:(ZBToken *)token {
    
    if (token == _selectedToken) [self deselectSelectedToken];
    
    BOOL shouldRemove = YES;
    if ([delegate respondsToSelector:@selector(tokenField:willRemoveToken:)]){
        shouldRemove = [delegate tokenField:self willRemoveToken:token];
    }
    
    if (shouldRemove){
        
        [token removeFromSuperview];
        [_tokens removeObject:token];
        [self layoutTokensAnimated:YES];
        
        if ([delegate respondsToSelector:@selector(tokenField:didRemoveToken:)]){
            [delegate tokenField:self didRemoveToken:token];
        }
        
        [self showOrHidePlaceHolderLabel];
        [self setResultsModeEnabled:_forcePickSearchResult || _alwaysShowSearchResult];
    }
}

- (void)removeAllTokens {
    
    [_tokens enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(ZBToken * token, NSUInteger idx, BOOL *stop) {
        [self removeToken:token];
    }];
    
    [self setText:@""];
}

- (void)selectToken:(ZBToken *)token {
    
    [self deselectSelectedToken];
    
    _selectedToken = token;
    [_selectedToken setSelected:YES];
    
    [self becomeFirstResponder];
    [self setText:kTextHidden];
}

- (void)deselectSelectedToken {
    
    [_selectedToken setSelected:NO];
    _selectedToken = nil;
    
    [self setText:kTextEmpty];
}

- (void)tokenizeText {
    
    __block BOOL textChanged = NO;
    
    if (![self.text isEqualToString:kTextEmpty] && ![self.text isEqualToString:kTextHidden] && !_forcePickSearchResult){
        [[self.text componentsSeparatedByCharactersInSet:_tokenizingCharacters] enumerateObjectsUsingBlock:^(NSString * component, NSUInteger idx, BOOL *stop){
            [self addTokenWithTitle:[component stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
            textChanged = YES;
        }];
    }
    
    if (textChanged) [self sendActionsForControlEvents:UIControlEventEditingChanged];
}

- (void)tokenTouchDown:(ZBToken *)token {
    
    if (_selectedToken != token){
        [_selectedToken setSelected:NO];
        _selectedToken = nil;
    }
}

- (void)tokenTouchUpInside:(ZBToken *)token {
    if (_editable) [self selectToken:token];
    if ([delegate respondsToSelector:@selector(tokenField:didTapToken:)]) {
        [delegate tokenField:self didTapToken:token];
    }
}

- (CGFloat)layoutTokensInternal {
    
    CGFloat topMargin = floor(self.font.lineHeight * 4 / 7);
    CGFloat leftMargin = self.leftViewWidth + 12;
    CGFloat hPadding = 8;
    CGFloat rightMargin = self.rightViewWidth + hPadding;
    CGFloat lineHeight = ceilf(self.font.lineHeight) + topMargin + 5;
    
    _numberOfLines = 1;
    _tokenCaret = (CGPoint){leftMargin, (topMargin - 1)};
    
    [_tokens enumerateObjectsUsingBlock:^(ZBToken * token, NSUInteger idx, BOOL *stop){
        
        [token setFont:self.font];
        [token setMaxWidth:(self.bounds.size.width - rightMargin - (_numberOfLines > 1 ? hPadding : leftMargin))];
        
        if (token.superview){
            
            if (_tokenCaret.x + token.bounds.size.width + rightMargin > self.bounds.size.width){
                _numberOfLines++;
                _tokenCaret.x = (_numberOfLines > 1 ? hPadding : leftMargin);
                _tokenCaret.y += lineHeight;
            }
            
            [token setFrame:(CGRect){_tokenCaret, token.bounds.size}];
            _tokenCaret.x += token.bounds.size.width + 4;
            
            if (self.bounds.size.width - _tokenCaret.x - rightMargin < 50){
                _numberOfLines++;
                _tokenCaret.x = (_numberOfLines > 1 ? hPadding : leftMargin);
                _tokenCaret.y += lineHeight;
            }
        }
    }];
    
    return ceilf(_tokenCaret.y + lineHeight);
}

#pragma mark View Handlers
- (void)layoutTokensAnimated:(BOOL)animated {
    
    CGFloat newHeight = [self layoutTokensInternal];
    if (self.bounds.size.height != newHeight){
        
        // Animating this seems to invoke the triple-tap-delete-key-loop-problem-thing™
        [UIView animateWithDuration:(animated && _editable ? 0.3 : 0) animations:^{
            [self setFrame:((CGRect){self.frame.origin, {self.bounds.size.width, newHeight}})];
            [self sendActionsForControlEvents:(UIControlEvents)ZBTokenFieldControlEventFrameWillChange];
            
        } completion:^(BOOL complete){
            if (complete) [self sendActionsForControlEvents:(UIControlEvents)ZBTokenFieldControlEventFrameDidChange];
        }];
    }
}

- (void)setResultsModeEnabled:(BOOL)flag {
    [self setResultsModeEnabled:flag animated:YES];
}

- (void)setResultsModeEnabled:(BOOL)flag animated:(BOOL)animated {
    
    [self layoutTokensAnimated:animated];
    
    if (_resultsModeEnabled != flag){
        
        //Hide / show the shadow
        [self.layer setMasksToBounds:!flag];
        
        UIScrollView * scrollView = self.scrollView;
        [scrollView setScrollsToTop:!flag];
        [scrollView setScrollEnabled:!flag];
        
        CGFloat offset = ((_numberOfLines == 1 || !flag) ? 0 : _tokenCaret.y - floor(self.font.lineHeight * 4 / 7) + 1);
        [scrollView setContentOffset:CGPointMake(0, self.frame.origin.y + offset) animated:animated];
    }
    
    _resultsModeEnabled = flag;
}

#pragma mark Left / Right view stuff
- (void)setPromptText:(NSString *)text {
    
    _promptText = text;
    if (text){
        
        UILabel * label = (UILabel *)self.leftView;
        if (!label || ![label isKindOfClass:[UILabel class]]){
            label = [[UILabel alloc] initWithFrame:CGRectZero];
            [self setLeftView:label];
            
            [self setLeftViewMode:UITextFieldViewModeAlways];
        }
        
        [label setTextColor:_promptColor];
        [label setText:text];
        [label setFont:[UIFont systemFontOfSize:(self.font.pointSize + 1)]];
        [label sizeToFit];
    }
    else
    {
        [self setLeftView:nil];
    }
    
    [self layoutTokensAnimated:YES];
}

- (void)setPromptColor:(UIColor *)promptColor
{
    _promptColor = promptColor;
    [self setPromptText:_promptText];
}

- (void)setPlaceholder:(NSString *)placeholder {
    
    if (placeholder){
        
        UILabel * label =  _placeHolderLabel;
        if (!label || ![label isKindOfClass:[UILabel class]]){
            label = [[UILabel alloc] initWithFrame:CGRectMake(_tokenCaret.x + 3, _tokenCaret.y + 2, self.rightView.bounds.size.width, self.rightView.bounds.size.height)];
            [label setTextColor:[UIColor colorWithWhite:0.75 alpha:1]];
            _placeHolderLabel = label;
            [self addSubview: _placeHolderLabel];
        }
        
        [label setText:placeholder];
        [label setFont:[UIFont systemFontOfSize:(self.font.pointSize + 1)]];
        [label sizeToFit];
    }
    else
    {
        [_placeHolderLabel removeFromSuperview];
        _placeHolderLabel = nil;
    }
    
    [self layoutTokensAnimated:YES];
}

#pragma mark Layout
- (CGRect)textRectForBounds:(CGRect)bounds {
    
    if ([self.text isEqualToString:kTextHidden]) return CGRectMake(0, -20, 0, 0);
    
    CGRect frame = CGRectOffset(bounds, _tokenCaret.x + 2, _tokenCaret.y + 3);
    frame.size.width -= (_tokenCaret.x + self.rightViewWidth + 10);
    
    return frame;
}

- (CGRect)editingRectForBounds:(CGRect)bounds {
    return [self textRectForBounds:bounds];
}

- (CGRect)placeholderRectForBounds:(CGRect)bounds {
    return [self textRectForBounds:bounds];
}

- (CGRect)leftViewRectForBounds:(CGRect)bounds {
    return ((CGRect){{8, ceilf(self.font.lineHeight * 4 / 7)}, self.leftView.bounds.size});
}

- (CGRect)rightViewRectForBounds:(CGRect)bounds {
    return ((CGRect){{bounds.size.width - self.rightView.bounds.size.width - 6,
        bounds.size.height - self.rightView.bounds.size.height - 6}, self.rightView.bounds.size});
}

- (CGFloat)leftViewWidth {
    
    if (self.leftViewMode == UITextFieldViewModeNever ||
        (self.leftViewMode == UITextFieldViewModeUnlessEditing && self.editing) ||
        (self.leftViewMode == UITextFieldViewModeWhileEditing && !self.editing)) return 0;
    
    return self.leftView.bounds.size.width;
}

- (CGFloat)rightViewWidth {
    
    if (self.rightViewMode == UITextFieldViewModeNever ||
        (self.rightViewMode == UITextFieldViewModeUnlessEditing && self.editing) ||
        (self.rightViewMode == UITextFieldViewModeWhileEditing && !self.editing)) return 0;
    
    return self.rightView.bounds.size.width;
}

#pragma mark Other
- (NSString *)description {
    return [NSString stringWithFormat:@"<TITokenField %p; prompt = \"%@\">", self, ((UILabel *)self.leftView).text];
}

- (void)dealloc {
    [self setDelegate:nil];
}

@end
