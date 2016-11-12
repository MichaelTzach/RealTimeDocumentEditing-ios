//
//  CursorView.m
//  RealTimeDocumentEditing
//
//  Created by Michael Tzach on 11/12/16.
//  Copyright © 2016 Michael Tzach. All rights reserved.
//

#import "CursorView.h"

@interface CursorView()

@property (nonatomic) BOOL shouldBlink;

@end

@implementation CursorView

-(instancetype)init {
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor redColor];
        self.opaque = NO;
        [self startBlinking];
    }
    return self;
}

-(void)sizeToFit {
    [super sizeToFit];
    
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, 2, 16);
}

-(void)startBlinking {
    self.shouldBlink = YES;
    [self blink];
}

-(void)stopBlinking {
    self.shouldBlink = NO;
}

-(void)blink {
    if (self.shouldBlink) {
        [UIView animateWithDuration:0.35 animations:^{
            self.alpha = 0;
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.35 animations:^{
                self.alpha = 1;
            } completion:^(BOOL finished) {
                [self blink];
            }];
        }];
    }
}

@end
