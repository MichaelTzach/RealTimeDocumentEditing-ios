//
//  RealTimeDocumetUser.h
//  RealTimeDocumentEditing
//
//  Created by Michael Tzach on 11/11/16.
//  Copyright © 2016 Michael Tzach. All rights reserved.
//

#import <JSONModel/JSONModel.h>

typedef enum {
    RealTimeDocumetUserStatusRequested = 1,
    RealTimeDocumetUserStatusDenied = 2,
    RealTimeDocumetUserStatusApproved = 10,
    RealTimeDocumetUserStatusActive = 20
} RealTimeDocumetUserStatus;

@interface RealTimeDocumetUser : JSONModel

+(RealTimeDocumetUser *)userForCreatorWithUserId:(NSString *)userId username:(NSString *)username;
+(RealTimeDocumetUser *)userForRequestWithUserId:(NSString *)userId username:(NSString *)username;

@property (strong, nonatomic) NSString *userId;
@property (strong, nonatomic) NSString *username;
@property (nonatomic, assign) RealTimeDocumetUserStatus status;

+(NSArray<RealTimeDocumetUser *> *)usersArrayWithArray:(NSArray<NSDictionary *> *)array;

@end
