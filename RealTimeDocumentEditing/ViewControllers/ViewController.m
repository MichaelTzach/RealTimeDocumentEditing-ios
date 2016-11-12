//
//  ViewController.m
//  RealTimeDocumentEditing
//
//  Created by Michael Tzach on 11/11/16.
//  Copyright © 2016 Michael Tzach. All rights reserved.
//

#import "ViewController.h"
#import "CreateViewController.h"
#import "JoinDocumentTableViewController.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UITextField *userIdTextField;
@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;

@property (weak, nonatomic) IBOutlet UIButton *createDocumentButton;
@property (weak, nonatomic) IBOutlet UIButton *joinDocumentButton;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setButtonEnabledDependingOnState];
    
    self.userIdTextField.text = @"456";
    self.usernameTextField.text = @"michaeltzach";
    [self setButtonEnabledDependingOnState];
}


- (IBAction)userIdChanged:(UITextField *)sender {
    [self setButtonEnabledDependingOnState];
}
- (IBAction)userNameChanged:(UITextField *)sender {
    [self setButtonEnabledDependingOnState];
}

-(void)setButtonEnabledDependingOnState {
    BOOL actionsEnabled = self.userIdTextField.text.length > 0 && self.usernameTextField.text.length > 0;
    self.joinDocumentButton.enabled = actionsEnabled;
    self.createDocumentButton.enabled = actionsEnabled;
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"createDocument"] && [segue.destinationViewController isKindOfClass:[CreateViewController class]]) {
        CreateViewController *destination = segue.destinationViewController;
        destination.currentUserId = self.userIdTextField.text;
        destination.currentUserName = self.usernameTextField.text;
    } else if ([segue.identifier isEqualToString:@"joinDocument"] && [segue.destinationViewController isKindOfClass:[JoinDocumentTableViewController class]]) {
        JoinDocumentTableViewController *destination = segue.destinationViewController;
        destination.currentUserId = self.userIdTextField.text;
        destination.currentUserName = self.usernameTextField.text;
    }
}

@end
