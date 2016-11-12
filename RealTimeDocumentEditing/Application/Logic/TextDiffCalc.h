//
//  TextDiffCalc.h
//  RealTimeDocumentEditing
//
//  Created by Michael Tzach on 11/12/16.
//  Copyright © 2016 Michael Tzach. All rights reserved.
//

@import UIKit;

@interface TextDiffCalc : NSObject

+(void)setTextAndMaintainCursorPosInTextField:(UITextField *)textField newText:(NSString *)newText;
+(void)setTextAndMaintainCursorPosInTextView:(UITextView *)textView newText:(NSString *)newText;

@end
