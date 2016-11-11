//
//  ViewController.m
//  RealTimeDocumentEditing
//
//  Created by Michael Tzach on 11/11/16.
//  Copyright © 2016 Michael Tzach. All rights reserved.
//

#import "ViewController.h"
#import "DocumentsDataHandler.h"

@interface ViewController ()

@property (strong, nonatomic) NSString *documentId;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.documentId = @"-KWHrxCJXFJZLRvr6FYb";
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 

- (IBAction)create:(id)sender {
    [[DocumentsDataHandler handler] createNewDocumentWithTitle:@"my document" userId:@"123"];
}

-(IBAction)join:(id)sender {
    [[DocumentsDataHandler handler] requestToJoinDocumentWithDocumentId:self.documentId withUserId:@"234"];
}

- (IBAction)becomeActive:(id)sender {
    [[DocumentsDataHandler handler] becomeActiveOnDocumentId:self.documentId withUserId:@"234"];
}

- (IBAction)approve:(id)sender {
    [[DocumentsDataHandler handler] approveUserWithId:@"234" toWorkOnDocumentWithId:self.documentId];
}

- (IBAction)leave:(id)sender {
    [[DocumentsDataHandler handler] leaveDocumentWithDocumentId:self.documentId withUserId:@"123"];
}

@end
