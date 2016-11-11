//
//  RealTimeDocumetUser.m
//  RealTimeDocumentEditing
//
//  Created by Michael Tzach on 11/11/16.
//  Copyright © 2016 Michael Tzach. All rights reserved.
//

#import "RealTimeDocumetUser.h"

@implementation RealTimeDocumetUser

-(instancetype)initWithUserId:(NSString *)userId {
    self = [super init];
    if (self) {
        self.userId = userId;
        self.cursorPosition = 0;
    }
    return self;
}

+(RealTimeDocumetUser *)userForCreatorWithUserId:(NSString *)userId {
    RealTimeDocumetUser *user = [[RealTimeDocumetUser alloc] initWithUserId:userId];
    user.status = RealTimeDocumetUserStatusApproved;
    return user;
}

+(RealTimeDocumetUser *)userForRequestWithUserId:(NSString *)userId {
    RealTimeDocumetUser *user = [[RealTimeDocumetUser alloc] initWithUserId:userId];
    user.status = RealTimeDocumetUserStatusRequested;
    return user;
}

+(NSArray<RealTimeDocumetUser *> *)usersArrayWithArray:(NSArray<NSDictionary *> *)array {
    NSMutableArray<RealTimeDocumetUser *> *usersArray = [[NSMutableArray alloc] init];
    for (NSDictionary *userDict in array) {
        RealTimeDocumetUser *newUser = [[RealTimeDocumetUser alloc] initWithDictionary:userDict error:nil];
        [usersArray addObject:newUser];
    }
    return [usersArray copy];
}

@end
