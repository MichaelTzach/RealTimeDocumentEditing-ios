//
//  UsersInDocumentTableViewCell.m
//  RealTimeDocumentEditing
//
//  Created by Michael Tzach on 11/12/16.
//  Copyright © 2016 Michael Tzach. All rights reserved.
//

#import "UsersInDocumentTableViewCell.h"
#import "RealTimeDocumetUser.h"

@interface UsersInDocumentTableViewCell()

@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UILabel *currentStatusLabel;

@property (weak, nonatomic) IBOutlet UIButton *allowAccessButton;
@property (weak, nonatomic) IBOutlet UIButton *doNotAllowAccessButton;


@end

@implementation UsersInDocumentTableViewCell

-(void)setUser:(RealTimeDocumetUser *)user {
    _user = user;
    
    [self updateDisplay];
}

-(void)updateDisplay {
    if (![self.usernameLabel.text isEqualToString:self.user.username]) {
        self.usernameLabel.text = self.user.username;
    }
    
    NSString *userStateText = [self userStateText];
    if (![self.currentStatusLabel.text isEqualToString:userStateText]) {
        self.currentStatusLabel.text = userStateText;
    }
    
    if (self.user.status == RealTimeDocumetUserStatusRequested) {
        self.allowAccessButton.hidden = self.doNotAllowAccessButton.hidden = NO;
    } else {
        self.allowAccessButton.hidden = self.doNotAllowAccessButton.hidden = YES;
    }
}

-(NSString *)userStateText {
    switch (self.user.status) {
        case RealTimeDocumetUserStatusActive:
            return @"Currently active on the document";
        case RealTimeDocumetUserStatusDenied:
            return @"User was denied access to document";
        case RealTimeDocumetUserStatusApproved:
            return @"Contrbutor is offline";
        case RealTimeDocumetUserStatusRequested:
            return @"User requested access";
    }
}

- (IBAction)allowAccessPressed:(id)sender {
    [self.delegate userApprovedUserWithId:self.user.userId];
}

- (IBAction)doNotAllowAccessPressed:(id)sender {
    [self.delegate userRejectedUserWithId:self.user.userId];
}

@end
