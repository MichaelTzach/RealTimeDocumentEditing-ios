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
typedef void(^SingleUsersCompletionBlock)(RealTimeDocumetUser *);

typedef void(^DocumentCompletionBlock)(NSArray<RealTimeDocumetDocument *> *);
typedef void(^SingleDocumentCompletionBlock)(RealTimeDocumetDocument *);
typedef void(^Completion)(NSError *error);

@interface DocumentsDataHandler : NSObject

#pragma mark - Initialization

+(DocumentsDataHandler *)handler;

#pragma mark - Commands for join and create

-(NSString *)createNewDocumentWithTitle:(NSString *)title userId:(NSString *)userId creatingUserName:(NSString *)creatingUserName completion:(Completion)completion;

-(void)requestToJoinDocumentWithDocumentId:(NSString *)documentId withUserId:(NSString *)userId requestingUserName:(NSString *)requestingUserName;

-(void)becomeActiveOnDocumentId:(NSString *)documentId withUserId:(NSString *)userId;

-(void)leaveDocumentWithDocumentId:(NSString *)documentId withUserId:(NSString *)userId;;

-(void)approveUserWithId:(NSString *)userId toWorkOnDocumentWithId:(NSString *)documentId;

-(void)rejectUserWithId:(NSString *)userId toWorkOnDocumentWithId:(NSString *)documentId;

#pragma mark - Commands for edit

-(void)editBodyForDocumentWithId:(NSString *)documentId newBody:(NSString *)newBody;

-(void)editTitleForDocumentWithId:(NSString *)documentId newTitle:(NSString *)newTitle;

#pragma mark - Observers

-(void)observeDocumentsWithUpdateBlock:(DocumentCompletionBlock)updateBlock;

-(void)observeNewJoinRequestsOnDocumentWithId:(NSString *)documentId userWaitingForApproval:(SingleUsersCompletionBlock)userWaitingForApproval;

-(void)observeDocumentWithId:(NSString *)documentId updateBlock:(SingleDocumentCompletionBlock)updateBlock;

-(void)observeDocumentUsersWithDocumentId:(NSString *)documentId updateBlock:(UsersCompletionBlock)updateBlock;

@end
