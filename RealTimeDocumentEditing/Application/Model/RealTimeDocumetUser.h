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

+(RealTimeDocumetUser *)userForCreatorWithUserId:(NSString *)userId;
+(RealTimeDocumetUser *)userForRequestWithUserId:(NSString *)userId;

@property (strong, nonatomic) NSString *userId;
@property (nonatomic) RealTimeDocumetUserStatus status;
@property (nonatomic) NSUInteger cursorPosition;

+(NSArray<RealTimeDocumetUser *> *)usersArrayWithArray:(NSArray<NSDictionary *> *)array;

@end
