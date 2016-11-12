//
//  UsersInDocumentTableViewController.m
//  RealTimeDocumentEditing
//
//  Created by Michael Tzach on 11/12/16.
//  Copyright © 2016 Michael Tzach. All rights reserved.
//

#import "UsersInDocumentTableViewController.h"
#import "DocumentsDataHandler.h"
#import "RealTimeDocumetUser.h"
#import "UsersInDocumentTableViewCell.h"

@interface UsersInDocumentTableViewController () <UsersInDocumentTableViewCellDelegate>

@property (strong, nonatomic) NSArray<RealTimeDocumetUser *> *users;

@end

@implementation UsersInDocumentTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[DocumentsDataHandler handler] observeDocumentUsersWithDocumentId:self.documentId updateBlock:^(NSArray<RealTimeDocumetUser *> *users) {
        self.users = users;
    }];
}

-(void)setUsers:(NSArray<RealTimeDocumetUser *> *)users {
    _users = users;
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.users count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UsersInDocumentTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"userInDocumentCell" forIndexPath:indexPath];
    
    cell.user = self.users[indexPath.row];
    cell.delegate = self;
    
    return cell;
}

#pragma mark - UsersInDocumentTableViewCellDelegate

-(void)userApprovedUserWithId:(NSString *)userId {
    [[DocumentsDataHandler handler] approveUserWithId:userId toWorkOnDocumentWithId:self.documentId];
}

-(void)userRejectedUserWithId:(NSString *)userId {
    [[DocumentsDataHandler handler] rejectUserWithId:userId toWorkOnDocumentWithId:self.documentId];
}

@end
