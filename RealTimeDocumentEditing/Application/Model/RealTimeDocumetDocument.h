//
//  RealTimeDocumetDocument.h
//  RealTimeDocumentEditing
//
//  Created by Michael Tzach on 11/11/16.
//  Copyright © 2016 Michael Tzach. All rights reserved.
//

#import <JSONModel/JSONModel.h>

@protocol RealTimeDocumetUser;
@class RealTimeDocumetUser;

@interface RealTimeDocumetDocument : JSONModel

-(instancetype)init __unavailable;

-(instancetype)initForCreationWithDocumentId:(NSString *)documentId title:(NSString *)title creatingUserId:(NSString *)creatingUserId;

+(NSArray<RealTimeDocumetDocument *> *)documentArrayWithArray:(NSArray<NSDictionary *> *)array;

@property (strong, nonatomic) NSString *documentId;
@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSString *body;
@property (strong, nonatomic) NSArray<RealTimeDocumetUser> *users;

-(void)addUser:(RealTimeDocumetUser *)user;

-(RealTimeDocumetUser *)userForId:(NSString *)userId;

-(BOOL)documentIsActive;

@end
