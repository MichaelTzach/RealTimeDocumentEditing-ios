//
//  ViewController.m
//  RealTimeDocumentEditing
//
//  Created by Michael Tzach on 11/11/16.
//  Copyright © 2016 Michael Tzach. All rights reserved.
//

#import "ViewController.h"
#import "CreateViewController.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UITextField *userIdTextField;
@property (weak, nonatomic) IBOutlet UIButton *createDocumentButton;
@property (weak, nonatomic) IBOutlet UIButton *joinDocumentButton;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setButtonEnabledDependingOnState];
}


- (IBAction)userIdChanged:(UITextField *)sender {
    [self setButtonEnabledDependingOnState];
}

-(void)setButtonEnabledDependingOnState {
    self.joinDocumentButton.enabled = self.userIdTextField.text.length > 0;
    self.createDocumentButton.enabled = self.userIdTextField.text.length > 0;
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"createDocument"]) {
        CreateViewController *destination = (CreateViewController *)segue.destinationViewController;
        destination.currentUserId = self.userIdTextField.text;
    }
}

@end
