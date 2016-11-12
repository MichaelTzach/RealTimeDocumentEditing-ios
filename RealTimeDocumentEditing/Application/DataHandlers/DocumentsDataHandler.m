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

@property (strong, nonatomic) NSMutableArray<DocumentCompletionBlock> *documentListeners;

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
        
        self.documentListeners = [[NSMutableArray alloc] init];
        
        [self observeDocuments];
    }
    return self;
}

#pragma mark - Private

-(void)observeDocuments {
    [self.documetsRef observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        if (snapshot.value == [NSNull null]) {
            self.documents = [[NSArray alloc] init];
            return;
        }
        
        NSArray<NSDictionary *> *documentDicts = [(NSDictionary *)snapshot.value allValues];
    
        self.documents = [RealTimeDocumetDocument documentArrayWithArray:documentDicts];
    }];
}

-(void)setDocuments:(NSArray<RealTimeDocumetDocument *> *)documents {
    _documents = documents;
    [self notifyDocumentObserversOnChange];
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

-(NSString *)createNewDocumentWithTitle:(NSString *)title userId:(NSString *)userId creatingUserName:(NSString *)creatingUserName completion:(Completion)completion {
    FIRDatabaseReference *newDocumentRef = [self.documetsRef childByAutoId];
    NSString *newDocumentKey = newDocumentRef.key;
    
    RealTimeDocumetDocument *newDocument = [[RealTimeDocumetDocument alloc] initForCreationWithDocumentId:newDocumentKey title:title creatingUserId:userId creatingUserName:creatingUserName];
    
    [newDocumentRef setValue:[newDocument toDictionary] withCompletionBlock:^(NSError * _Nullable error, FIRDatabaseReference * _Nonnull ref) {
        if (completion) completion(error);
    }];
    
    return newDocumentKey;
}

-(void)requestToJoinDocumentWithDocumentId:(NSString *)documentId withUserId:(NSString *)userId requestingUserName:(NSString *)requestingUserName {
    [self getDocumentWithId:documentId completionBlock:^(RealTimeDocumetDocument *document) {
        if (!document) {
            return; //TODO: add fail block
        }
        
        RealTimeDocumetUser *requestingUserInDocument = [document userForId:userId];
        if (!requestingUserInDocument) {
            requestingUserInDocument = [RealTimeDocumetUser userForRequestWithUserId:userId username:requestingUserName];
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

#pragma mark - Commands for edit

-(void)editBodyForDocumentWithId:(NSString *)documentId newBody:(NSString *)newBody {
    [[[self.documetsRef child:documentId] child:@"body"] setValue:newBody];
}

-(void)editTitleForDocumentWithId:(NSString *)documentId newTitle:(NSString *)newTitle {
    [[[self.documetsRef child:documentId] child:@"title"] setValue:newTitle];
}

#pragma mark - Observers

-(void)observeDocumentsWithUpdateBlock:(DocumentCompletionBlock)updateBlock {
    updateBlock(self.documents);
    
    [self.documentListeners addObject:updateBlock];
}

-(void)notifyDocumentObserversOnChange {
    for (DocumentCompletionBlock completionBlock in self.documentListeners) {
        completionBlock(self.documents);
    }
}

-(void)observeNewJoinRequestsOnDocumentWithId:(NSString *)documentId userWaitingForApproval:(SingleUsersCompletionBlock)userWaitingForApproval {
    [[[self.documetsRef child:documentId] child:@"users"] observeEventType:FIRDataEventTypeChildAdded withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        if (snapshot.value == [NSNull null]) { return; }
        
        NSDictionary *userDict = snapshot.value;
        RealTimeDocumetUser *userAdded = [[RealTimeDocumetUser alloc] initWithDictionary:userDict error:nil];
        if (userAdded.status == RealTimeDocumetUserStatusRequested) {
            userWaitingForApproval(userAdded);
        }
    }];
}

-(NSArray<RealTimeDocumetUser *> *)requestedUsersFromListOfUsers:(NSArray<RealTimeDocumetUser *> *)users {
    return [users filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(RealTimeDocumetUser *user, NSDictionary *bindings) {
        return user.status == RealTimeDocumetUserStatusRequested;
    }]];
}

-(void)observeDocumentWithId:(NSString *)documentId updateBlock:(SingleDocumentCompletionBlock)updateBlock {
    [[self.documetsRef child:documentId] observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        if (snapshot.value == [NSNull null]) { return; }
        
        NSDictionary *documentDict = snapshot.value;
        RealTimeDocumetDocument *document = [[RealTimeDocumetDocument alloc] initWithDictionary:documentDict error:nil];
        updateBlock(document);
    }];
}

-(void)observeDocumentUsersWithDocumentId:(NSString *)documentId updateBlock:(UsersCompletionBlock)updateBlock {
    [[[self.documetsRef child:documentId] child:@"users"] observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        if (snapshot.value == [NSNull null]) { return; }
        
        NSArray<NSDictionary *> *userDicts = snapshot.value;
        NSArray<RealTimeDocumetUser *> *usersInDocument = [RealTimeDocumetUser usersArrayWithArray:userDicts];
        updateBlock(usersInDocument);
    }];
}

@end
