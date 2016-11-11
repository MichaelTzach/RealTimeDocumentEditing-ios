//
//  DocumentsDataHandler.m
//  RealTimeDocumentEditing
//
//  Created by Michael Tzach on 11/11/16.
//  Copyright © 2016 Michael Tzach. All rights reserved.
//

#import "DocumentsDataHandler.h"
@import FirebaseDatabase;
#import "RealTimeDocumetDocument.h"
#import "RealTimeDocumetUser.h"

@interface DocumentsDataHandler()

@property (strong, nonatomic) FIRDatabaseReference *documetsRef;
@property (strong, nonatomic) NSArray<RealTimeDocumetDocument *> *documents;

@property (strong, nonatomic) NSMutableArray<DocumentCompletionBlock> *callbacksForObserveActiveDocuments;
@property (strong, nonatomic) NSMutableArray<UsersCompletionBlock> *callbacksForObserveJoinRequests;

@end

@implementation DocumentsDataHandler

static DocumentsDataHandler *handler;

+(DocumentsDataHandler *)handler {
    return handler;
}

+(void)initialize {
    handler = [[DocumentsDataHandler alloc] init];
}

-(instancetype)init {
    self = [super init];
    if (self) {
        self.documetsRef = [[[FIRDatabase database] reference] child:@"documents"];
        
        self.callbacksForObserveActiveDocuments = [[NSMutableArray alloc] init];
        
        [self observeDocuments];
    }
    return self;
}

#pragma mark - Private

-(void)observeDocuments {
    [self.documetsRef observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        NSArray<NSDictionary *> *documentDicts = [(NSDictionary *)snapshot.value allValues];
        
        self.documents = [RealTimeDocumetDocument documentArrayWithArray:documentDicts];
    }];
}

-(void)setDocuments:(NSArray<RealTimeDocumetDocument *> *)documents {
    [self notifyObserversForActiveDocumentsIfNeededWithOldDocuments:_documents newDocumentsList:documents];
    
    _documents = documents;
}

-(void)getDocumentWithId:(NSString *)documentId completionBlock:(void(^)(RealTimeDocumetDocument *document))completionBlock {
    [[self.documetsRef child:documentId] observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        if (!snapshot.value) {
            completionBlock(nil);
        }
        
        RealTimeDocumetDocument *document = [[RealTimeDocumetDocument alloc] initWithDictionary:snapshot.value error:nil];
        completionBlock(document);
    }];
}

#pragma mark - Commands

-(NSString *)createNewDocumentWithTitle:(NSString *)title userId:(NSString *)userId {
    FIRDatabaseReference *newDocumentRef = [self.documetsRef childByAutoId];
    NSString *newDocumentKey = newDocumentRef.key;
    
    RealTimeDocumetDocument *newDocument = [[RealTimeDocumetDocument alloc] initForCreationWithDocumentId:newDocumentKey title:title creatingUserId:userId];
    
    [newDocumentRef setValue:[newDocument toDictionary] withCompletionBlock:^(NSError * _Nullable error, FIRDatabaseReference * _Nonnull ref) {
        
    }];
    
    return newDocumentKey;
}

-(void)requestToJoinDocumentWithDocumentId:(NSString *)documentId withUserId:(NSString *)userId {
    [self getDocumentWithId:documentId completionBlock:^(RealTimeDocumetDocument *document) {
        if (!document) {
            return; //TODO: add fail block
        }
        
        RealTimeDocumetUser *requestingUserInDocument = [document userForId:userId];
        if (!requestingUserInDocument) {
            requestingUserInDocument = [RealTimeDocumetUser userForRequestWithUserId:userId];
            [document addUser:requestingUserInDocument];
        } else {
            requestingUserInDocument.status = RealTimeDocumetUserStatusRequested;
        }
        
        [[self.documetsRef child:documentId] setValue:[document toDictionary]];
    }];
}

-(void)becomeActiveOnDocumentId:(NSString *)documentId withUserId:(NSString *)userId {
    [self getDocumentWithId:documentId completionBlock:^(RealTimeDocumetDocument *document) {
        RealTimeDocumetUser *requestingUserInDocument = [document userForId:userId];
        if (!document || !requestingUserInDocument) {
            return; //TODO: add fail block
        }
        
        if (requestingUserInDocument.status == RealTimeDocumetUserStatusApproved) {
            
            requestingUserInDocument.status = RealTimeDocumetUserStatusActive;
            [[self.documetsRef child:documentId] setValue:[document toDictionary]];
        } else {
            //TODO
        }
    }];
}

-(void)leaveDocumentWithDocumentId:(NSString *)documentId withUserId:(NSString *)userId {
    [self getDocumentWithId:documentId completionBlock:^(RealTimeDocumetDocument *document) {
        RealTimeDocumetUser *requestingUserInDocument = [document userForId:userId];
        if (!document || !requestingUserInDocument) {
            return; //TODO: add fail block
        }
        
        if (requestingUserInDocument.status == RealTimeDocumetUserStatusActive) {
            requestingUserInDocument.status = RealTimeDocumetUserStatusApproved;
            [[self.documetsRef child:documentId] setValue:[document toDictionary]];
        } else {
            //TODO
        }
    }];
}

-(void)approveUserWithId:(NSString *)userId toWorkOnDocumentWithId:(NSString *)documentId {
    [self getDocumentWithId:documentId completionBlock:^(RealTimeDocumetDocument *document) {
        RealTimeDocumetUser *requestingUserInDocument = [document userForId:userId];
        if (!document || !requestingUserInDocument) {
            return; //TODO: add fail block
        }
        
        if (requestingUserInDocument.status == RealTimeDocumetUserStatusRequested) {
            requestingUserInDocument.status = RealTimeDocumetUserStatusApproved;
            [[self.documetsRef child:documentId] setValue:[document toDictionary]];
        } else {
            //TODO
        }
    }];
}

-(void)rejectUserWithId:(NSString *)userId toWorkOnDocumentWithId:(NSString *)documentId {
    [self getDocumentWithId:documentId completionBlock:^(RealTimeDocumetDocument *document) {
        RealTimeDocumetUser *requestingUserInDocument = [document userForId:userId];
        if (!document || !requestingUserInDocument) {
            return; //TODO: add fail block
        }
        
        if (requestingUserInDocument.status == RealTimeDocumetUserStatusRequested) {
            requestingUserInDocument.status = RealTimeDocumetUserStatusDenied;
            [[self.documetsRef child:documentId] setValue:[document toDictionary]];
        } else {
            //TODO
        }
    }];
}

#pragma mark - Observers

-(void)observeActiveDocumentsWithUpdateBlock:(DocumentCompletionBlock)updateBlock {
    [self.callbacksForObserveActiveDocuments addObject:updateBlock];
}

-(void)notifyObserversForActiveDocumentsIfNeededWithOldDocuments:(NSArray<RealTimeDocumetDocument *> *)oldDocumentsList newDocumentsList:(NSArray<RealTimeDocumetDocument *> *)newDocumentsList {
    BOOL needsToNotify = NO;
    if (!oldDocumentsList) {
        needsToNotify = YES;
    }
    //TODO: check if need to notify
    
    NSArray<RealTimeDocumetDocument *> *activeDocuments = [self activeDocumentsInList:newDocumentsList];
    
    for (DocumentCompletionBlock block in self.callbacksForObserveActiveDocuments) {
        block(activeDocuments);
    }
}

-(NSArray<RealTimeDocumetDocument *> *)activeDocumentsInList:(NSArray<RealTimeDocumetDocument *> *)documents {
    NSMutableArray *activeDocs = [[NSMutableArray alloc] init];
    for (RealTimeDocumetDocument *document in documents) {
        if (document.documentIsActive) {
            [activeDocs addObject:document];
        }
    }
    return activeDocs;
}

-(void)observeJoinRequestsOnDocumentWithId:(NSString *)documentId waitingForApprovalListUpdatedBlock:(UsersCompletionBlock)waitingForApprovalListUpdatedBlock {
    [[[self.documetsRef child:documentId] child:@"users"] observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        NSArray<NSDictionary *> *userDicts = [(NSDictionary *)snapshot.value allValues];
        NSArray<RealTimeDocumetUser *> *usersInDocument = [RealTimeDocumetUser usersArrayWithArray:userDicts];
        NSArray<RealTimeDocumetUser *> *requestedUsersInDocument = [self requestedUsersFromListOfUsers:usersInDocument];
        waitingForApprovalListUpdatedBlock(requestedUsersInDocument);
    }];
}

-(NSArray<RealTimeDocumetUser *> *)requestedUsersFromListOfUsers:(NSArray<RealTimeDocumetUser *> *)users {
    NSMutableArray *requestedUsers = [[NSMutableArray alloc] init];
    for (RealTimeDocumetUser *user in users) {
        if (user.status == RealTimeDocumetUserStatusRequested) {
            [requestedUsers addObject:user];
        }
    }
    return requestedUsers;
}

@end
