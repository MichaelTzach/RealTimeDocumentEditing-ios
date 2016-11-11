//
//  DocumentsDataHandler.h
//  RealTimeDocumentEditing
//
//  Created by Michael Tzach on 11/11/16.
//  Copyright © 2016 Michael Tzach. All rights reserved.
//

#import <Foundation/Foundation.h>
@class RealTimeDocumetUser;
@class RealTimeDocumetDocument;

typedef void(^UsersCompletionBlock)(NSArray<RealTimeDocumetUser *> *);
typedef void(^DocumentCompletionBlock)(NSArray<RealTimeDocumetDocument *> *);
typedef void(^Completion)(NSError *error);

@interface DocumentsDataHandler : NSObject

#pragma mark - Initialization

+(DocumentsDataHandler *)handler;

#pragma mark - Commands

-(NSString *)createNewDocumentWithTitle:(NSString *)title userId:(NSString *)userId completion:(Completion)completion;

-(void)requestToJoinDocumentWithDocumentId:(NSString *)documentId withUserId:(NSString *)userId;

-(void)becomeActiveOnDocumentId:(NSString *)documentId withUserId:(NSString *)userId;

-(void)leaveDocumentWithDocumentId:(NSString *)documentId withUserId:(NSString *)userId;;

-(void)approveUserWithId:(NSString *)userId toWorkOnDocumentWithId:(NSString *)documentId;

-(void)rejectUserWithId:(NSString *)userId toWorkOnDocumentWithId:(NSString *)documentId;

#pragma mark - Observers

-(void)observeActiveDocumentsWithUpdateBlock:(DocumentCompletionBlock)updateBlock;

-(void)observeJoinRequestsOnDocumentWithId:(NSString *)documentId waitingForApprovalListUpdatedBlock:(UsersCompletionBlock)waitingForApprovalListUpdatedBlock;

@end
