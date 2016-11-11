//
//  RealTimeDocumetDocument.m
//  RealTimeDocumentEditing
//
//  Created by Michael Tzach on 11/11/16.
//  Copyright © 2016 Michael Tzach. All rights reserved.
//

#import "RealTimeDocumetDocument.h"
#import "RealTimeDocumetUser.h"

@implementation RealTimeDocumetDocument

+(BOOL)propertyIsOptional:(NSString *)propertyName {
    return YES;
}

-(instancetype)initForCreationWithDocumentId:(NSString *)documentId title:(NSString *)title creatingUserId:(NSString *)creatingUserId {
    self = [super init];
    if (self) {
        self.documentId = documentId;
        self.title = title;
        self.body = @"";
        self.users = @[[RealTimeDocumetUser userForCreatorWithUserId:creatingUserId]];
    }
    return self;
}

-(RealTimeDocumetUser *)userForId:(NSString *)userId {
    for (RealTimeDocumetUser *user in self.users) {
        if ([user.userId isEqualToString:userId]) {
            return user;
        }
    }
    
    return nil;
}

-(void)addUser:(RealTimeDocumetUser *)user {
    self.users = [self.users arrayByAddingObject:user];
}

-(BOOL)documentIsActive {
    for (RealTimeDocumetUser *user in self.users) {
        if (user.status == RealTimeDocumetUserStatusActive) {
            return YES;
        }
    }
    return NO;
}

+(NSArray<RealTimeDocumetDocument *> *)documentArrayWithArray:(NSArray<NSDictionary *> *)array {
    NSMutableArray<RealTimeDocumetDocument *> *docsArray = [[NSMutableArray alloc] init];
    for (NSDictionary *docDict in array) {
        RealTimeDocumetDocument *newDoc = [[RealTimeDocumetDocument alloc] initWithDictionary:docDict error:nil];
        [docsArray addObject:newDoc];
    }
    return [docsArray copy];
}

@end
