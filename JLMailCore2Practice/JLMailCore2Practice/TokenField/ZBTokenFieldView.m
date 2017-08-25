//
//  ZBTokenFieldView.m
//  JLMailCore2Practice
//
//  Created by perfect on 2017/6/26.
//  Copyright © 2017年 JackLin. All rights reserved.
//

#import "ZBTokenFieldView.h"
#import "ZBTokenField.h"
#import "ZBToken.h"

@interface ZBTokenFieldView (Private)

- (void)setup;
- (NSString *)displayStringForRepresentedObject:(id)object;
- (NSString *)searchResultStringForRepresentedObject:(id)object;
- (void)setSearchResultsVisible:(BOOL)visible;
- (void)resultsForSearchString:(NSString *)searchString;
- (void)presentpopoverAtTokenFieldCaretAnimated:(BOOL)animated;

@end

@interface ZBTokenFieldView()<UITableViewDelegate, UITableViewDataSource, ZBTokenFieldDelegate>

@end

@implementation ZBTokenFieldView{
    UIView * _contentView;
    NSMutableArray * _resultsArray;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    
    UIPopoverController * _popoverController;
    
#pragma clang diagnostic pop
}

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
    
    [self setBackgroundColor:[UIColor clearColor]];
    [self setDelaysContentTouches:NO];
    [self setMultipleTouchEnabled:NO];
    
    _showAlreadyTokenized = NO;
    _searchSubtitles = YES;
    _subtitleIsPhoneNumber = NO;
    _forcePickSearchResult = NO;
    _alwaysShowSearchResult = NO;
    _shouldSortResults = YES;
    _shouldSearchInBackground = NO;
    _shouldAlwaysShowSeparator = YES;
    _permittedArrowDirections = UIPopoverArrowDirectionUp;
    _resultsArray = [NSMutableArray array];
    
    _tokenField = [[ZBTokenField alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, 70)];
    [_tokenField addTarget:self action:@selector(tokenFieldDidBeginEditing:) forControlEvents:UIControlEventEditingDidBegin];
    [_tokenField addTarget:self action:@selector(tokenFieldDidEndEditing:) forControlEvents:UIControlEventEditingDidEnd];
    [_tokenField addTarget:self action:@selector(tokenFieldTextDidChange:) forControlEvents:UIControlEventEditingChanged];
    [_tokenField addTarget:self action:@selector(tokenFieldFrameWillChange:) forControlEvents:(UIControlEvents)ZBTokenFieldControlEventFrameWillChange];
    [_tokenField addTarget:self action:@selector(tokenFieldFrameDidChange:) forControlEvents:(UIControlEvents)ZBTokenFieldControlEventFrameDidChange];
    [_tokenField setDelegate:self];
    [self addSubview:_tokenField];
    
    CGFloat tokenFieldBottom = CGRectGetMaxY(_tokenField.frame);
    
    _separator = [[UIView alloc] initWithFrame:CGRectMake(0, tokenFieldBottom, self.bounds.size.width, 1)];
    [_separator setBackgroundColor:[UIColor colorWithWhite:0.7 alpha:1]];
    
    _tableHeader = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, 1)];
    [_tableHeader setBackgroundColor:[UIColor colorWithWhite:0.7 alpha:1]];
    
    [self addSubview:_separator];
    
    // This view is created for convenience, because it resizes and moves with the rest of the subviews.
    _contentView = [[UIView alloc] initWithFrame:CGRectMake(0, tokenFieldBottom + 1, self.bounds.size.width,
                                                            self.bounds.size.height - tokenFieldBottom - 1)];
    [_contentView setBackgroundColor:[UIColor clearColor]];
    [self addSubview:_contentView];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
        
        UITableViewController * tableViewController = [[UITableViewController alloc] initWithStyle:UITableViewStylePlain];
        [tableViewController.tableView setDelegate:self];
        [tableViewController.tableView setDataSource:self];
        [tableViewController setContentSizeForViewInPopover:CGSizeMake(400, 400)];
        
        _resultsTable = tableViewController.tableView;
        
        _popoverController = [[UIPopoverController alloc] initWithContentViewController:tableViewController];
    }
    else
    {
        _resultsTable = [[UITableView alloc] initWithFrame:CGRectMake(0, tokenFieldBottom + 1, self.bounds.size.width, 10)];
        [_resultsTable setSeparatorColor:[UIColor colorWithWhite:0.85 alpha:1]];
        [_resultsTable setBackgroundColor:[UIColor colorWithRed:0.92 green:0.92 blue:0.92 alpha:1]];
        [_resultsTable setDelegate:self];
        [_resultsTable setDataSource:self];
        [_resultsTable setHidden:YES];
        [self addSubview:_resultsTable];
        
        _popoverController = nil;
    }
    
    if (_shouldAlwaysShowSeparator) {
        [self bringSubviewToFront:_separator];
    } else {
        _separator.hidden = YES;
        _resultsTable.tableHeaderView = _tableHeader;
    }
    [self bringSubviewToFront:_tokenField];
    [self updateContentSize];
}

#pragma mark Property Overrides
- (void) setChildFrames:(CGRect)frame {
    CGFloat width = frame.size.width;
    [_separator setFrame:((CGRect){_separator.frame.origin, {width, _separator.bounds.size.height}})];
    [_resultsTable setFrame:((CGRect){_resultsTable.frame.origin, {width, _resultsTable.bounds.size.height}})];
    [_contentView setFrame:((CGRect){_contentView.frame.origin, {width, (frame.size.height - CGRectGetMaxY(_tokenField.frame))}})];
    [_tokenField setFrame:((CGRect){_tokenField.frame.origin, {width, _tokenField.bounds.size.height}})];
}

- (void)setFrame:(CGRect)frame {
    
    [super setFrame:frame];
    
    [self setChildFrames:frame];
    
    if (_popoverController.popoverVisible){
        [_popoverController dismissPopoverAnimated:NO];
        [self presentpopoverAtTokenFieldCaretAnimated:NO];
    }
    
    [self updateContentSize];
    [self setNeedsLayout];
}

- (void)setContentOffset:(CGPoint)offset {
    [super setContentOffset:offset];
    [self setNeedsLayout];
}

- (NSArray *)tokenTitles {
    return _tokenField.tokenTitles;
}

- (void)setForcePickSearchResult:(BOOL)forcePickSearchResult
{
    _tokenField.forcePickSearchResult = forcePickSearchResult;
    _forcePickSearchResult = forcePickSearchResult;
}

- (void)setAlwaysShowSearchResult:(BOOL)alwaysShowSearchResult
{
    _tokenField.alwaysShowSearchResult = alwaysShowSearchResult;
    _alwaysShowSearchResult = alwaysShowSearchResult;
    if (_alwaysShowSearchResult) [self resultsForSearchString:_tokenField.text];
}

- (void) setShouldAlwaysShowSeparator:(BOOL)shouldAlwaysShowSeparator
{
    _shouldAlwaysShowSeparator = shouldAlwaysShowSeparator;
    if (_shouldAlwaysShowSeparator) {
        _resultsTable.tableHeaderView = nil;
        _separator.hidden = NO;
        [self bringSubviewToFront:_separator];
    } else {
        _separator.hidden = YES;
        _resultsTable.tableHeaderView = _tableHeader;
    }
}

#pragma mark Event Handling
- (void)layoutSubviews {
    
    [super layoutSubviews];
    
    [self setChildFrames:self.frame];
    
    CGFloat relativeFieldHeight = CGRectGetMaxY(_tokenField.frame) - self.contentOffset.y;
    CGFloat newHeight = self.bounds.size.height - relativeFieldHeight;
    if (newHeight > -1) [_resultsTable setFrame:((CGRect){_resultsTable.frame.origin, {_resultsTable.bounds.size.width, newHeight}})];
}

- (void)updateContentSize {
    [self setContentSize:CGSizeMake(self.bounds.size.width, CGRectGetMaxY(_contentView.frame) + 1)];
}

- (BOOL)canBecomeFirstResponder {
    return YES;
}

- (BOOL)becomeFirstResponder {
    return [_tokenField becomeFirstResponder];
}

- (BOOL)resignFirstResponder {
    return [_tokenField resignFirstResponder];
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if ([_tokenField.delegate respondsToSelector:@selector(tokenField:resultsTableView:heightForRowAtIndexPath:)]){
        return [_tokenField.delegate tokenField:_tokenField resultsTableView:tableView heightForRowAtIndexPath:indexPath];
    }
    
    return 44;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if ([_tokenField.delegate respondsToSelector:@selector(tokenField:didFinishSearch:)]){
        [_tokenField.delegate tokenField:_tokenField didFinishSearch:_resultsArray];
    }
    
    return _resultsArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    id representedObject = [_resultsArray objectAtIndex:indexPath.row];
    
    if ([_tokenField.delegate respondsToSelector:@selector(tokenField:resultsTableView:cellForRepresentedObject:)]){
        return [_tokenField.delegate tokenField:_tokenField resultsTableView:tableView cellForRepresentedObject:representedObject];
    }
    
    static NSString * CellIdentifier = @"ResultsCell";
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    NSString * subtitle = [self searchResultSubtitleForRepresentedObject:representedObject];
    
    if (!cell) cell = [[UITableViewCell alloc] initWithStyle:(subtitle ? UITableViewCellStyleSubtitle : UITableViewCellStyleDefault) reuseIdentifier:CellIdentifier];
    
    [cell.imageView setImage:[self searchResultImageForRepresentedObject:representedObject]];
    [cell.textLabel setText:[self searchResultStringForRepresentedObject:representedObject]];
    [cell.detailTextLabel setText:subtitle];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    id representedObject = [_resultsArray objectAtIndex:indexPath.row];
    ZBToken * token = [[ZBToken alloc] initWithTitle:[self displayStringForRepresentedObject:representedObject] representedObject:representedObject];
    [_tokenField addToken:token];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (!_alwaysShowSearchResult) [self setSearchResultsVisible:NO];
}

#pragma mark TextField Methods

- (void)tokenFieldDidBeginEditing:(ZBTokenField *)field {
    if (!_alwaysShowSearchResult) [_resultsArray removeAllObjects];
    [_resultsTable reloadData];
}

- (void)tokenFieldDidEndEditing:(ZBTokenField *)field {
    [self tokenFieldDidBeginEditing:field];
}

- (void)tokenFieldTextDidChange:(ZBTokenField *)field {
    [self resultsForSearchString:_tokenField.text];
    
    if (_forcePickSearchResult || _alwaysShowSearchResult) [self setSearchResultsVisible:YES];
    else [self setSearchResultsVisible:(_resultsArray.count > 0)];
}

- (void)tokenFieldFrameWillChange:(ZBTokenField *)field {
    
    CGFloat tokenFieldBottom = CGRectGetMaxY(_tokenField.frame);
    [_separator setFrame:((CGRect){{_separator.frame.origin.x, tokenFieldBottom}, _separator.bounds.size})];
    [_resultsTable setFrame:((CGRect){{_resultsTable.frame.origin.x, (tokenFieldBottom + 1)}, _resultsTable.bounds.size})];
    [_contentView setFrame:((CGRect){{_contentView.frame.origin.x, (tokenFieldBottom + 1)}, _contentView.bounds.size})];
}

- (void)tokenFieldFrameDidChange:(ZBTokenField *)field {
    [self updateContentSize];
}

#pragma mark Results Methods
- (NSString *)displayStringForRepresentedObject:(id)object {
    
    if ([_tokenField.delegate respondsToSelector:@selector(tokenField:displayStringForRepresentedObject:)]){
        return [_tokenField.delegate tokenField:_tokenField displayStringForRepresentedObject:object];
    }
    
    if ([object isKindOfClass:[NSString class]]){
        return (NSString *)object;
    }
    
    return [NSString stringWithFormat:@"%@", object];
}

- (NSString *)searchResultStringForRepresentedObject:(id)object {
    
    if ([_tokenField.delegate respondsToSelector:@selector(tokenField:searchResultStringForRepresentedObject:)]){
        return [_tokenField.delegate tokenField:_tokenField searchResultStringForRepresentedObject:object];
    }
    
    return [self displayStringForRepresentedObject:object];
}

- (NSString *)searchResultSubtitleForRepresentedObject:(id)object {
    
    if ([_tokenField.delegate respondsToSelector:@selector(tokenField:searchResultSubtitleForRepresentedObject:)]){
        return [_tokenField.delegate tokenField:_tokenField searchResultSubtitleForRepresentedObject:object];
    }
    
    return nil;
}

- (UIImage *)searchResultImageForRepresentedObject:(id)object {
    if ([_tokenField.delegate respondsToSelector:@selector(tokenField:searchResultImageForRepresentedObject:)]) {
        return [_tokenField.delegate tokenField:_tokenField searchResultImageForRepresentedObject:object];
    }
    
    return nil;
}


- (void)setSearchResultsVisible:(BOOL)visible {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
        
        if (visible) [self presentpopoverAtTokenFieldCaretAnimated:YES];
        else [_popoverController dismissPopoverAnimated:YES];
    }
    else
    {
        [_resultsTable setHidden:!visible];
        [_tokenField setResultsModeEnabled:visible];
    }
}

- (void)resultsForSearchString:(NSString *)searchString {
    
    // The brute force searching method.
    // Takes the input string and compares it against everything in the source array.
    // If the source is massive, this could take some time.
    // You could always subclass and override this if needed or do it on a background thread.
    // GCD would be great for that.
    
    [_resultsArray removeAllObjects];
    [_resultsTable reloadData];
    
    searchString = [searchString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if (searchString.length || _forcePickSearchResult || _alwaysShowSearchResult){
        
        if ([_tokenField.delegate respondsToSelector:@selector(tokenField:shouldUseCustomSearchForSearchString:)] && [_tokenField.delegate tokenField:_tokenField shouldUseCustomSearchForSearchString:searchString]) {
            if ([_tokenField.delegate respondsToSelector:@selector(tokenField:performCustomSearchForSearchString:withCompletionHandler:)]) {
                [_tokenField.delegate tokenField:_tokenField performCustomSearchForSearchString:searchString withCompletionHandler:^(NSArray *results) {
                    [self searchDidFinish:results];
                }];
            }
        } else {
            if (_shouldSearchInBackground) {
                [self performSelectorInBackground:@selector(performSearch:) withObject:searchString];
            } else {
                [self performSearch:searchString];
            }
        }
    }
}

- (void) performSearch:(NSString *)searchString {
    NSMutableArray * resultsToAdd = [[NSMutableArray alloc] init];
    [_sourceArray enumerateObjectsUsingBlock:^(id sourceObject, NSUInteger idx, BOOL *stop){
        
        NSString * query = [self searchResultStringForRepresentedObject:sourceObject];
        NSString * querySubtitle = [self searchResultSubtitleForRepresentedObject:sourceObject];
        if (!querySubtitle || !_searchSubtitles) {
            querySubtitle = @"";
        } else if (_subtitleIsPhoneNumber) {
            querySubtitle = [querySubtitle stringByReplacingOccurrencesOfString:@" " withString:@""];
        }
        
        if ([query rangeOfString:searchString options:NSCaseInsensitiveSearch].location != NSNotFound ||
            [querySubtitle rangeOfString:searchString options:NSCaseInsensitiveSearch].location != NSNotFound ||
            (_forcePickSearchResult && searchString.length == 0) ||
            (_alwaysShowSearchResult && searchString.length == 0)){
            
            __block BOOL shouldAdd = ![resultsToAdd containsObject:sourceObject];
            if (shouldAdd && !_showAlreadyTokenized){
                
                [_tokenField.tokens enumerateObjectsUsingBlock:^(ZBToken * token, NSUInteger idx, BOOL *secondStop){
                    if ([token.representedObject isEqual:sourceObject]){
                        shouldAdd = NO;
                        *secondStop = YES;
                    }
                }];
            }
            
            if (shouldAdd) [resultsToAdd addObject:sourceObject];
        }
    }];
    
    [self searchDidFinish:resultsToAdd];
}

- (void)searchDidFinish:(NSArray *)results
{
    [_resultsArray addObjectsFromArray:results];
    if (_resultsArray.count > 0) {
        if (_shouldSortResults) {
            [_resultsArray sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
                return [[self searchResultStringForRepresentedObject:obj1] localizedCaseInsensitiveCompare:[self searchResultStringForRepresentedObject:obj2]];
            }];
        }
        [self performSelectorOnMainThread:@selector(reloadResultsTable) withObject:nil waitUntilDone:YES];
    }
}


-(void) reloadResultsTable {
    [_resultsTable setHidden:NO];
    [_resultsTable reloadData];
}

- (void)presentpopoverAtTokenFieldCaretAnimated:(BOOL)animated {
    
    UITextPosition * position = [_tokenField positionFromPosition:_tokenField.beginningOfDocument offset:2];
    
    [_popoverController presentPopoverFromRect:[_tokenField caretRectForPosition:position]
                                        inView:_tokenField
                      permittedArrowDirections:[self permittedArrowDirections]
                                      animated:animated];
}

#pragma mark Other
- (NSString *)description {
    return [NSString stringWithFormat:@"<TITokenFieldView %p; Token count = %ld>", self, self.tokenTitles.count];
}

- (void)dealloc {
    [self setDelegate:nil];
}



@end
