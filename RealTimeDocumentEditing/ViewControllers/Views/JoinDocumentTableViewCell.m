//
//  JoinDocumentTableViewCell.m
//  RealTimeDocumentEditing
//
//  Created by Michael Tzach on 11/12/16.
//  Copyright © 2016 Michael Tzach. All rights reserved.
//

#import "JoinDocumentTableViewCell.h"
#import "RealTimeDocumetDocument.h"
#import "RealTimeDocumetUser.h"

@interface JoinDocumentTableViewCell()

@property (weak, nonatomic) IBOutlet UILabel *documentNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *documentStatusLabel;
@property (weak, nonatomic) IBOutlet UILabel *myStatusOnDocumentLabel;

@property (weak, nonatomic) IBOutlet UIButton *actionButton;

@end

@implementation JoinDocumentTableViewCell

-(void)setDocument:(RealTimeDocumetDocument *)document {
    _document = document;
    [self resetDocumentValues];
}

-(void)setCurrentUserId:(NSString *)currentUserId {
    _currentUserId = currentUserId;
    [self resetDocumentValues];
}

-(void)resetDocumentValues {
    self.documentNameLabel.text = self.document.title;
    
    if ([self.document documentIsActive]) {
        self.documentStatusLabel.text = [self activeAuthorsString];
    } else {
        self.documentStatusLabel.text = @"There are no active authors on the document";
    }
    
    self.myStatusOnDocumentLabel.hidden = [self myStatusOnDocument] == nil;
    self.myStatusOnDocumentLabel.text = [self myStatusOnDocument];
    
    self.actionButton.hidden = [self actionButtonText] == nil;
    [self.actionButton setTitle:[self actionButtonText] forState:UIControlStateNormal];
}

-(NSString *)myStatusOnDocument {
    if (!self.currentUserId) { return nil; }
    
    RealTimeDocumetUser *currentUserInDoc = [self.document userForId:self.currentUserId];
    if (currentUserInDoc) {
        switch (currentUserInDoc.status) {
            case RealTimeDocumetUserStatusDenied:
                return @"You were denied access to this document";
            case RealTimeDocumetUserStatusApproved:
            case RealTimeDocumetUserStatusActive:
                return @"You were approved to work on this document";
            case RealTimeDocumetUserStatusRequested:
                return @"You requested to join this document";
        }
    }
    return nil;
}

-(NSString *)actionButtonText {
    if (!self.currentUserId) { return nil; }
    
    RealTimeDocumetUser *currentUserInDoc = [self.document userForId:self.currentUserId];
    if (!currentUserInDoc) {
        return @"Ask to join";
    }
    
    switch (currentUserInDoc.status) {
        case RealTimeDocumetUserStatusActive:
        case RealTimeDocumetUserStatusApproved:
            return @"Go to document";
        case RealTimeDocumetUserStatusDenied:
        case RealTimeDocumetUserStatusRequested:
            return nil;
    }
}

- (IBAction)actionButtonPressed:(id)sender {
    if (!self.currentUserId) { return; }
    RealTimeDocumetUser *currentUserInDoc = [self.document userForId:self.currentUserId];

    if (!currentUserInDoc) {
        [self.delegate userAskedToJoinDocumentWithId:self.document.documentId];
    } else {
        [self.delegate userAskedToOpenDocumentWithId:self.document.documentId];
    }
}

-(NSString *)activeAuthorsString {
    NSArray<RealTimeDocumetUser *> *activeAuthors = [self.document.users filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(RealTimeDocumetUser *user, NSDictionary *bindings) {
        return user.status == RealTimeDocumetUserStatusActive;
    }]];
    if (activeAuthors.count == 1) {
        return [NSString stringWithFormat:@"%@ is active on the document", [activeAuthors firstObject].username];
    } else {
        NSMutableArray<NSString *> *activeUserNames = [[NSMutableArray alloc] init];
        for (RealTimeDocumetUser *user in activeAuthors) {
            if (user.username) {
                [activeUserNames addObject:user.username];
            }
        }
        return [NSString stringWithFormat:@"%@ are active on the document", [activeUserNames componentsJoinedByString:@", "]];
    }
}


@end
