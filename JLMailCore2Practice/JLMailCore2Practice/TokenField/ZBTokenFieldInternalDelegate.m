//
//  ZBTokenFieldInternalDelegate.m
//  JLMailCore2Practice
//
//  Created by perfect on 2017/6/26.
//  Copyright © 2017年 JackLin. All rights reserved.
//

#import "ZBTokenFieldInternalDelegate.h"
#import "ZBTokenField.h"

NSString * const kTextEmpty = @"\u200B"; // Zero-Width Space
NSString * const kTextHidden = @"\u200D"; // Zero-Width Joiner

@implementation ZBTokenFieldInternalDelegate

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    
    if ([_delegate respondsToSelector:@selector(textFieldShouldBeginEditing:)]){
        return [_delegate textFieldShouldBeginEditing:textField];
    }
    
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    
    if ([_delegate respondsToSelector:@selector(textFieldDidBeginEditing:)]){
        [_delegate textFieldDidBeginEditing:textField];
    }
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    
    if ([_delegate respondsToSelector:@selector(textFieldShouldEndEditing:)]){
        return [_delegate textFieldShouldEndEditing:textField];
    }
    
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    
    if ([_delegate respondsToSelector:@selector(textFieldDidEndEditing:)]){
        [_delegate textFieldDidEndEditing:textField];
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    if (_tokenField.tokens.count
        && [string isEqualToString:@""]
        && [_tokenField.text isEqualToString:kTextEmpty]){
        [_tokenField selectToken:[_tokenField.tokens lastObject]];
        return NO;
    }
    
    if ([textField.text isEqualToString:kTextHidden]){
        [_tokenField removeToken:_tokenField.selectedToken];
        return (![string isEqualToString:@""]);
    }
    
    if ([string rangeOfCharacterFromSet:_tokenField.tokenizingCharacters].location != NSNotFound && !_tokenField.forcePickSearchResult){
        [_tokenField tokenizeText];
        return NO;
    }
    
    if ([_delegate respondsToSelector:@selector(textField:shouldChangeCharactersInRange:replacementString:)]){
        return [_delegate textField:textField shouldChangeCharactersInRange:range replacementString:string];
    }
    
    if (_tokenField.tokenLimit!=-1
        &&[_tokenField.tokens count] >= _tokenField.tokenLimit) {
        return NO;
    }
    
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    [_tokenField tokenizeText];
    
    if ([_delegate respondsToSelector:@selector(textFieldShouldReturn:)]){
        return [_delegate textFieldShouldReturn:textField];
    }
    
    return YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField {
    
    if ([_delegate respondsToSelector:@selector(textFieldShouldClear:)]){
        return [_delegate textFieldShouldClear:textField];
    }
    
    return YES;
}

@end
