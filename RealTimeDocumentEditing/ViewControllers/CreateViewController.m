//
//  CreateViewController.m
//  RealTimeDocumentEditing
//
//  Created by Michael Tzach on 11/11/16.
//  Copyright © 2016 Michael Tzach. All rights reserved.
//

#import "CreateViewController.h"
#import "DocumentsDataHandler.h"
#import "RealTimeEditorViewController.h"

@interface CreateViewController ()

//Views
@property (weak, nonatomic) IBOutlet UITextField *titleTextField;
@property (weak, nonatomic) IBOutlet UIButton *createButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

//State
@property (nonatomic) BOOL isCreating;

@end

@implementation CreateViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setCreateEnabledDependingOnState];
}

- (IBAction)titleChanged:(UITextField *)sender {
    [self setCreateEnabledDependingOnState];
}

-(void)setCreateEnabledDependingOnState {
    self.createButton.enabled = self.currentUserId.length > 0 && self.titleTextField.text.length > 0 && !self.isCreating;
}

- (IBAction)createButtonPressed {
    NSString *userId = self.currentUserId;
    NSString *documentTitle = self.titleTextField.text;
    
    self.isCreating = YES;
    __block NSString *createdDocumentId = [[DocumentsDataHandler handler] createNewDocumentWithTitle:documentTitle userId:userId creatingUserName:self.currentUserName completion:^(NSError *error) {
        self.isCreating = NO;

        RealTimeEditorViewController *documentEditor = [[RealTimeEditorViewController alloc] initWithEditingUserId:self.currentUserId documentId:createdDocumentId];
        [self.navigationController pushViewController:documentEditor animated:YES];
    }];
}

-(void)setIsCreating:(BOOL)isCreating {
    _isCreating = isCreating;
    
    [self setCreateEnabledDependingOnState];
    if (isCreating) {
        [self.activityIndicator startAnimating];
    } else {
        [self.activityIndicator stopAnimating];
    }
}

@end
