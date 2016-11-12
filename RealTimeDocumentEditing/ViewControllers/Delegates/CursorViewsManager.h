//
//  CursorViewsManager.h
//  RealTimeDocumentEditing
//
//  Created by Michael Tzach on 11/12/16.
//  Copyright © 2016 Michael Tzach. All rights reserved.
//

@import UIKit;

@interface CursorViewManagerModel : NSObject

@property (nonatomic) CGPoint topPoint;
@property (strong, nonatomic) NSString *userId;
@property (strong, nonatomic) NSString *initials;
@property (strong, nonatomic) UIImage *avatar;

@end

@protocol CursorViewsManagerDelegate <NSObject>

-(void)addViewToContainer:(UIView *)viewToAdd;

@end

//Sets the cursors with animations according to location

@interface CursorViewsManager : NSObject

@property (weak, nonatomic) id<CursorViewsManagerDelegate> delegate;

-(void)updateCursors:(NSArray<CursorViewManagerModel *> *)cursors;

+(CGPoint)topOfCursorLocationFromLocation:(NSNumber *)location inTextView:(UITextView *)textView;

@end
