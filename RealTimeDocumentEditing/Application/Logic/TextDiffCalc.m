//
//  TextDiffCalc.m
//  RealTimeDocumentEditing
//
//  Created by Michael Tzach on 11/12/16.
//  Copyright © 2016 Michael Tzach. All rights reserved.
//

#import "TextDiffCalc.h"

@implementation TextDiffCalc

+(NSUInteger)newCursorFromOldCursorLocaion:(NSUInteger)oldCursorLocation oldText:(NSString *)oldText newText:(NSString *)newText {
    BOOL changeBeginsBeforeOldCursorLocation = NO;
    
    for (NSUInteger loc = 0; loc < oldText.length && loc < oldCursorLocation; loc++) {
        if (newText.length > loc) {
            if ([newText characterAtIndex:loc] != [oldText characterAtIndex:loc]) {
                changeBeginsBeforeOldCursorLocation = YES;
            }
        }
    }

    NSUInteger newCursorLocation;
    if (changeBeginsBeforeOldCursorLocation) {
        newCursorLocation = oldCursorLocation + (newText.length - oldText.length);
    } else {
        newCursorLocation = oldCursorLocation;
    }
    
    newCursorLocation = MIN(newCursorLocation, newText.length - 1);
    newCursorLocation = MAX(newCursorLocation, 0);

    return newCursorLocation;
}

+(void)setTextAndMaintainCursorPosInTextField:(UITextField *)textField newText:(NSString *)newText {
    if ([textField.text isEqualToString:newText]) { return; }
    
    NSUInteger oldCursorLocation = [textField offsetFromPosition:textField.beginningOfDocument toPosition:textField.selectedTextRange.start];
    NSUInteger newCursorLocation = [TextDiffCalc newCursorFromOldCursorLocaion:oldCursorLocation oldText:textField.text newText:newText];
    
    textField.text = newText;
    
    UITextPosition *newTextPosition = [textField positionFromPosition:textField.beginningOfDocument offset:newCursorLocation];
    [textField setSelectedTextRange:[textField textRangeFromPosition:newTextPosition toPosition:newTextPosition]];
}

+(void)setTextAndMaintainCursorPosInTextView:(UITextView *)textView newText:(NSString *)newText {
    if ([textView.text isEqualToString:newText]) { return; }
    
    NSUInteger oldCursorLocation = [textView offsetFromPosition:textView.beginningOfDocument toPosition:textView.selectedTextRange.start];
    NSUInteger newCursorLocation = [TextDiffCalc newCursorFromOldCursorLocaion:oldCursorLocation oldText:textView.text newText:newText];
    
    textView.text = newText;
    
    UITextPosition *newTextPosition = [textView positionFromPosition:textView.beginningOfDocument offset:newCursorLocation];
    [textView setSelectedTextRange:[textView textRangeFromPosition:newTextPosition toPosition:newTextPosition]];
}



@end
