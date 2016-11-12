//
//  RealTimeDocumetUser.m
//  RealTimeDocumentEditing
//
//  Created by Michael Tzach on 11/11/16.
//  Copyright © 2016 Michael Tzach. All rights reserved.
//

#import "RealTimeDocumetUser.h"

@implementation RealTimeDocumetUser

-(instancetype)initWithUserId:(NSString *)userId username:(NSString *)username {
    self = [super init];
    if (self) {
        self.userId = userId;
        self.username = username;
    }
    return self;
}

+(RealTimeDocumetUser *)userForCreatorWithUserId:(NSString *)userId username:(NSString *)username {
    RealTimeDocumetUser *user = [[RealTimeDocumetUser alloc] initWithUserId:userId username:username];
    user.status = RealTimeDocumetUserStatusApproved;
    return user;
}

+(RealTimeDocumetUser *)userForRequestWithUserId:(NSString *)userId username:(NSString *)username {
    RealTimeDocumetUser *user = [[RealTimeDocumetUser alloc] initWithUserId:userId username:username];
    user.status = RealTimeDocumetUserStatusRequested;
    return user;
}

+(NSArray<RealTimeDocumetUser *> *)usersArrayWithArray:(NSArray<NSDictionary *> *)array {
    NSMutableArray<RealTimeDocumetUser *> *usersArray = [[NSMutableArray alloc] init];
    for (NSDictionary *userDict in array) {
        RealTimeDocumetUser *newUser = [[RealTimeDocumetUser alloc] initWithDictionary:userDict error:nil];
        if (newUser) {
            [usersArray addObject:newUser];
        }
    }
    return [usersArray copy];
}

@end
