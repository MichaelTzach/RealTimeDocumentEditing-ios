//
//  CursorViewsManager.m
//  RealTimeDocumentEditing
//
//  Created by Michael Tzach on 11/12/16.
//  Copyright © 2016 Michael Tzach. All rights reserved.
//

#import "CursorViewsManager.h"
#import "CursorView.h"

@implementation CursorViewManagerModel

@end

@interface CursorViewsManager()

@property (strong, nonatomic) NSDictionary<NSString *, CursorViewManagerModel *> *userIdsToCursors;

@property (strong, nonatomic) NSMutableDictionary<NSString *, CursorView *> *userIdsToViews;

@end

@implementation CursorViewsManager

-(instancetype)init {
    self = [super init];
    if (self) {
        self.userIdsToViews = [[NSMutableDictionary alloc] init];
    }
    return self;
}

-(void)updateCursors:(NSArray<CursorViewManagerModel *> *)cursors {
    NSArray<NSString *> *addedCursorUserIds = [CursorViewsManager addedCursorArray:self.userIdsToCursors.allValues newCursors:cursors];
    for (NSString *addUserId in addedCursorUserIds) {
        [self addViewWithUserId:addUserId];
    }
    
    NSArray<NSString *> *deletedCursorUserIds = [CursorViewsManager deletedCursorArray:self.userIdsToCursors.allValues newCursors:cursors];
    for (NSString *removeUserId in deletedCursorUserIds) {
        [self removeViewWithUserId:removeUserId];
    }
    
    self.userIdsToCursors = [CursorViewsManager userIdsToCursorsWithCursorArray:cursors];
    
    [self layoutCursorViewsWithAnimation];
}

+(CGPoint)topOfCursorLocationFromLocation:(NSNumber *)location inTextView:(UITextView *)textView {
    NSInteger loc = [location integerValue];
    if (loc < 0) {
        return CGPointZero;
    }
    
    UITextPosition *pos = [textView positionFromPosition:textView.beginningOfDocument offset:loc];
    
    CGRect caretRect = [textView caretRectForPosition:pos];
    
    return caretRect.origin;
}

#pragma mark - Managing views (private)

-(void)layoutCursorViewsWithAnimation {
    [UIView animateWithDuration:0.2 animations:^{
        [self.userIdsToViews enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull userId, CursorView * _Nonnull cursorView, BOOL * _Nonnull stop) {
            CursorViewManagerModel *modelForCursor = [self.userIdsToCursors valueForKey:userId];
            if (!modelForCursor) { return; }
            
            [cursorView sizeToFit];
            CGRect frame = CGRectMake(modelForCursor.topPoint.x, modelForCursor.topPoint.y + 3.5, cursorView.bounds.size.width, cursorView.bounds.size.height);
            cursorView.frame = frame;
        }];
    }];
}

-(void)addViewWithUserId:(NSString *)userId {
    CursorView *cursorView = [[CursorView alloc] init];
    
    [self.delegate addViewToContainer:cursorView];
    
    cursorView.alpha = 0;
    cursorView.opaque = NO;
    [UIView animateWithDuration:1.0 animations:^{
        cursorView.alpha = 1;
    } completion:^(BOOL finished) {
        cursorView.opaque = YES;
    }];
    
    [self.userIdsToViews setValue:cursorView forKey:userId];
}

-(void)removeViewWithUserId:(NSString *)userId {
    CursorView *cursorView = [self.userIdsToViews valueForKey:userId];
    [self.userIdsToViews removeObjectForKey:userId];
    
    cursorView.opaque = NO;
    [UIView animateWithDuration:1.0 animations:^{
        cursorView.alpha = 0;
    } completion:^(BOOL finished) {
        [cursorView removeFromSuperview];
    }];
}

#pragma mark - Private

+(NSDictionary<NSString *, CursorViewManagerModel *> *)userIdsToCursorsWithCursorArray:(NSArray<CursorViewManagerModel *> *)cursors {
    NSMutableDictionary<NSString *, CursorViewManagerModel *> *userIdsToCursors = [[NSMutableDictionary alloc] init];
    
    for (CursorViewManagerModel *cursor in cursors) {
        if (cursor.userId) {
            [userIdsToCursors setValue:cursor forKey:cursor.userId];
        }
    }
    
    return [userIdsToCursors copy];
}

+(NSArray<NSString *> *)deletedCursorArray:(NSArray<CursorViewManagerModel *> *)oldCursors newCursors:(NSArray<CursorViewManagerModel *> *)newCursors {
    NSMutableArray<NSString *> *deletedArray = [[NSMutableArray alloc] init];
    
    for (CursorViewManagerModel *oldCursor in oldCursors) {
        BOOL oldCursorFound = NO;
        for (CursorViewManagerModel *newCursor in newCursors) {
            if ([newCursor.userId isEqualToString:oldCursor.userId]) {
                oldCursorFound = YES;
                break;
            }
        }
        if (!oldCursorFound) {
            [deletedArray addObject:oldCursor.userId];
        }
    }
    
    return [deletedArray copy];
}

+(NSArray<NSString *> *)addedCursorArray:(NSArray<CursorViewManagerModel *> *)oldCursors newCursors:(NSArray<CursorViewManagerModel *> *)newCursors {
    NSMutableArray<NSString *> *addedArray = [[NSMutableArray alloc] init];
    
    for (CursorViewManagerModel *newCursor in newCursors) {
        BOOL foundInOldCursors = NO;
        for (CursorViewManagerModel *oldCursor in oldCursors) {
            if ([newCursor.userId isEqualToString:oldCursor.userId]) {
                foundInOldCursors = YES;
                break;
            }
        }
        if (!foundInOldCursors) {
            [addedArray addObject:newCursor.userId];
        }
    }
    
    return [addedArray copy];
}

@end
