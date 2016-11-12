//
//  JoinDocumentTableViewController.m
//  RealTimeDocumentEditing
//
//  Created by Michael Tzach on 11/12/16.
//  Copyright © 2016 Michael Tzach. All rights reserved.
//

#import "JoinDocumentTableViewController.h"
#import "DocumentsDataHandler.h"
#import "RealTimeDocumetDocument.h"
#import "JoinDocumentTableViewCell.h"
#import "RealTimeEditorViewController.h"

@interface JoinDocumentTableViewController () <JoinDocumentTableViewCellDelegate>

//Model
@property (strong, nonatomic) NSArray<RealTimeDocumetDocument *> *documents;

@end

@implementation JoinDocumentTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[DocumentsDataHandler handler] observeDocumentsWithUpdateBlock:^(NSArray<RealTimeDocumetDocument *> *documents) {
        self.documents = documents;
    }];
}

-(void)setDocuments:(NSArray<RealTimeDocumetDocument *> *)documents {
    _documents = documents;
    [self.tableView reloadData];
}

#pragma mark - Model handling

-(NSArray<RealTimeDocumetDocument *> *)openDocuments {
    return [self.documents filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(RealTimeDocumetDocument *evaluatedDocument, NSDictionary<NSString *,id> * _Nullable bindings) {
        return evaluatedDocument.state == RealTimeDocumetStateOpen;
    }]];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self openDocuments].count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    JoinDocumentTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"joinDocumentCell" forIndexPath:indexPath];
    
    cell.currentUserId = self.currentUserId;
    cell.document = [self openDocuments][indexPath.row];
    cell.delegate = self;
    
    return cell;
}

#pragma mark - JoinDocumentTableViewCellDelegate

-(void)userAskedToJoinDocumentWithId:(NSString *)documentId {
    [[DocumentsDataHandler handler] requestToJoinDocumentWithDocumentId:documentId withUserId:self.currentUserId requestingUserName:self.currentUserName];
}

-(void)userAskedToOpenDocumentWithId:(NSString *)documentId {
    RealTimeEditorViewController *documentEditor = [[RealTimeEditorViewController alloc] initWithEditingUserId:self.currentUserId documentId:documentId];
    [self.navigationController pushViewController:documentEditor animated:YES];
}

@end
