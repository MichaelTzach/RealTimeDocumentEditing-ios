//
//  UsersInDocumentTableViewCell.h
//  RealTimeDocumentEditing
//
//  Created by Michael Tzach on 11/12/16.
//  Copyright © 2016 Michael Tzach. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RealTimeDocumetUser;

@protocol UsersInDocumentTableViewCellDelegate <NSObject>

-(void)userApprovedUserWithId:(NSString *)userId;
-(void)userRejectedUserWithId:(NSString *)userId;

@end

@interface UsersInDocumentTableViewCell : UITableViewCell

@property (weak, nonatomic) id<UsersInDocumentTableViewCellDelegate> delegate;

@property (strong, nonatomic) RealTimeDocumetUser *user;

@end
