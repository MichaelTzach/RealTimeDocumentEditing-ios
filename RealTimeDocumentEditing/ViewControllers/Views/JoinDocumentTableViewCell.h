//
//  JoinDocumentTableViewCell.h
//  RealTimeDocumentEditing
//
//  Created by Michael Tzach on 11/12/16.
//  Copyright © 2016 Michael Tzach. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RealTimeDocumetDocument;

@protocol JoinDocumentTableViewCellDelegate <NSObject>

-(void)userAskedToJoinDocumentWithId:(NSString *)documentId;
-(void)userAskedToOpenDocumentWithId:(NSString *)documentId;

@end

@interface JoinDocumentTableViewCell : UITableViewCell

@property (weak, nonatomic) id<JoinDocumentTableViewCellDelegate> delegate;

@property (strong, nonatomic) RealTimeDocumetDocument *document;
@property (strong, nonatomic) NSString *currentUserId;

@end
