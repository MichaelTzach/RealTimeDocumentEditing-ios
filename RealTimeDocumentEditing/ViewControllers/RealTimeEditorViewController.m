//
//  RealTimeEditorViewController.m
//  RealTimeDocumentEditing
//
//  Created by Michael Tzach on 11/11/16.
//  Copyright © 2016 Michael Tzach. All rights reserved.
//

#import "RealTimeEditorViewController.h"
#import "DocumentsDataHandler.h"
#import "RealTimeDocumetDocument.h"
#import "RealTimeDocumetUser.h"
#import "CWStatusBarNotification.h"
#import "TextDiffCalc.h"
#import "UsersInDocumentTableViewController.h"
#import "CursorViewsManager.h"

@interface RealTimeEditorViewController () <UITextViewDelegate, CursorViewsManagerDelegate>

//Views
@property (strong, nonatomic) CWStatusBarNotification *statusBarNotification;
@property (strong, nonatomic) UIBarButtonItem *authorsOnDocument;

@property (strong, nonatomic) UITextField *titleTextField;
@property (strong, nonatomic) UIView *seperatorView;
@property (strong, nonatomic) UITextView *bodyTextView;

@property (strong, nonatomic) NSMutableDictionary<NSString *, UIView *> *cursorViews;

//State
@property (strong, nonatomic) NSString *userId;
@property (strong, nonatomic) NSString *documentId;

@property (strong, nonatomic) RealTimeDocumetDocument *document;
@property (strong, nonatomic) NSDictionary<NSString *, NSNumber *> *userIdToCursorLocation;

@property (nonatomic) BOOL preventResigningActiveState;

//Helpers
@property (strong, nonatomic) CursorViewsManager *cursorManager;

@end

@implementation RealTimeEditorViewController

-(instancetype)initWithEditingUserId:(NSString *)editingUserId documentId:(NSString *)documentId {
    self = [super init];
    if (self) {
        self.userId = editingUserId;
        self.documentId = documentId;
        
        self.preventResigningActiveState = NO;
        
        self.userIdToCursorLocation = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.authorsOnDocument = [[UIBarButtonItem alloc] init];
    [self.authorsOnDocument setTarget:self];
    [self.authorsOnDocument setAction:@selector(authorsOnDocumentPressed)];
    
    self.statusBarNotification = [[CWStatusBarNotification alloc] init];
    
    self.titleTextField = [[UITextField alloc] init];
    [self.titleTextField addTarget:self action:@selector(titleTextFieldChanged) forControlEvents:UIControlEventEditingChanged];
    [self.view addSubview:self.titleTextField];
    
    self.seperatorView = [[UIView alloc] init];
    self.seperatorView.backgroundColor = [UIColor lightGrayColor];
    [self.view addSubview:self.seperatorView];
    
    self.bodyTextView = [[UITextView alloc] init];
    self.bodyTextView.delegate = self;
    self.bodyTextView.font = [UIFont systemFontOfSize:16.0];
    [self.view addSubview:self.bodyTextView];
    
    [self registerForRequestingUsersOnDocument];
    [self registerForUpdatesOnDocument];
    [self registerForCursorUpdatesOnDocument];
}

-(void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    CGFloat navigationBarBottom = self.navigationController.navigationBar.frame.origin.y + self.navigationController.navigationBar.frame.size.height;
    
    CGFloat margins = 10;
    CGFloat fullWidth = self.view.bounds.size.width;
    CGFloat widthWithMargins = fullWidth - 2 * margins;
    CGFloat viewHeightWithKeyboard = self.view.frame.size.height; //TODO
    
    CGFloat bottom = navigationBarBottom;
    
    [self.titleTextField sizeToFit];
    self.titleTextField.frame = CGRectMake(margins, margins + bottom, widthWithMargins, self.titleTextField.bounds.size.height);
    bottom = self.titleTextField.frame.origin.y + self.titleTextField.frame.size.height;
    
    self.seperatorView.frame = CGRectMake(0, bottom + margins, fullWidth, 1);
    bottom += margins + 1;
    
    self.bodyTextView.frame = CGRectMake(margins, bottom + margins, widthWithMargins, viewHeightWithKeyboard - bottom - margins * 2);
}

-(void)registerForRequestingUsersOnDocument {
    [[DocumentsDataHandler handler] observeNewJoinRequestsOnDocumentWithId:self.documentId userWaitingForApproval:^(RealTimeDocumetUser *requstingUser) {
        if (self.statusBarNotification.notificationIsShowing || self.statusBarNotification.notificationIsDismissing) {
            return;
        }
        
        NSString *requstString = [NSString stringWithFormat:@"%@ requsted to join document", requstingUser.username];
        
        [self.statusBarNotification displayNotificationWithMessage:requstString forDuration:4.0];
    }];
}

-(void)registerForUpdatesOnDocument {
    [[DocumentsDataHandler handler] observeDocumentWithId:self.documentId updateBlock:^(RealTimeDocumetDocument *document) {
        self.document = document;
    }];
}

-(void)registerForCursorUpdatesOnDocument {
    [[DocumentsDataHandler handler] observeCursorsOnDocumentWithId:self.documentId updateBlock:^(NSDictionary<NSString *,NSNumber *> *userIdToUserLoc) {
        self.userIdToCursorLocation = userIdToUserLoc;
    }];
}

-(void)setUserIdToCursorLocation:(NSDictionary<NSString *,NSNumber *> *)userIdToCursorLocation {
    _userIdToCursorLocation = userIdToCursorLocation;
    
    [self updateCursorManagerDependingOnActiveUsersAndCursors];
}

-(void)updateCursorManagerDependingOnActiveUsersAndCursors {
    NSMutableArray<CursorViewManagerModel *> *cursorModels = [[NSMutableArray alloc] init];
    NSArray<NSString *> *activeUserIds = [self activeUserIdsInDocumentThatAreNotCurrentUser];
    
    [self.userIdToCursorLocation enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull userId, NSNumber * _Nonnull userLoc, BOOL * _Nonnull stop) {
        if ([activeUserIds containsObject:userId]) {
            CGPoint topPoint = [CursorViewsManager topOfCursorLocationFromLocation:userLoc inTextView:self.bodyTextView];
            
            CursorViewManagerModel *model = [[CursorViewManagerModel alloc] init];
            model.userId = userId;
            model.topPoint = topPoint;
            
            [cursorModels addObject:model];
        }
    }];
    
    [self.cursorManager updateCursors:cursorModels];
}

-(NSArray<NSString *> *)activeUserIdsInDocumentThatAreNotCurrentUser {
    NSMutableArray<NSString *> *activeUserIds = [[NSMutableArray alloc] init];
    
    for (RealTimeDocumetUser *user in self.document.users) {
        if (user.status == RealTimeDocumetUserStatusActive && ![user.userId isEqualToString:self.userId]) {
            [activeUserIds addObject:user.userId];
        }
    }
    
    return activeUserIds;
}

-(void)setDocument:(RealTimeDocumetDocument *)document {
    RealTimeDocumetDocument *oldDoc = _document;
    
    _document = document;
    
    [self setAuthorsOnDocumentImageDependingOnState];
    [self setTitleDependingOnOldDocument:oldDoc newDocument:document];
    [self setBodyDependingOnOldDocument:oldDoc newDocument:document];
    
    [self updateCursorManagerDependingOnActiveUsersAndCursors];
}

-(void)setTitleDependingOnOldDocument:(RealTimeDocumetDocument *)oldDocument newDocument:(RealTimeDocumetDocument *)newDocument {
    [TextDiffCalc setTextAndMaintainCursorPosInTextField:self.titleTextField newText:newDocument.title];
}

-(void)setBodyDependingOnOldDocument:(RealTimeDocumetDocument *)oldDocument newDocument:(RealTimeDocumetDocument *)newDocument {
    [TextDiffCalc setTextAndMaintainCursorPosInTextView:self.bodyTextView newText:newDocument.body];
}

-(void)setAuthorsOnDocumentImageDependingOnState {
    BOOL documentHasPendingUsers = NO;
    for (RealTimeDocumetUser *user in self.document.users) {
        if (user.status == RealTimeDocumetUserStatusRequested) {
            documentHasPendingUsers = YES;
            break;
        }
    }
    
    if (!self.navigationItem.rightBarButtonItem) {
        self.navigationItem.rightBarButtonItem = self.authorsOnDocument;
    }
    
    if (documentHasPendingUsers) {
        [self.authorsOnDocument setImage:[UIImage imageNamed:@"callingFace"]];
    } else {
        [self.authorsOnDocument setImage:[UIImage imageNamed:@"face"]];
    }
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (!self.preventResigningActiveState) {
        [[DocumentsDataHandler handler] becomeActiveOnDocumentId:self.documentId withUserId:self.userId];
    }
    self.preventResigningActiveState = NO;
}

-(void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    if (!self.preventResigningActiveState) {
        [[DocumentsDataHandler handler] leaveDocumentWithDocumentId:self.documentId withUserId:self.userId];
    }
}

-(void)authorsOnDocumentPressed {
    self.preventResigningActiveState = YES;
    
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    UsersInDocumentTableViewController *vc = [sb instantiateViewControllerWithIdentifier:@"UsersInDocumentTableViewController"];
    
    vc.documentId = self.documentId;
    
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - UITextViewDelegate

- (void)textViewDidChange:(UITextView *)textView {
    if ([self.bodyTextView.text isEqualToString:self.document.body]) {
        return;
    }
    
    [[DocumentsDataHandler handler] editBodyForDocumentWithId:self.documentId newBody:self.bodyTextView.text];
}

-(void)textViewDidChangeSelection:(UITextView *)textView {
    if (textView.isFirstResponder) {
        NSInteger loc = [textView offsetFromPosition:textView.beginningOfDocument toPosition:textView.selectedTextRange.start];
        
        [[DocumentsDataHandler handler] changeCursorLocationForDocumntId:self.documentId userId:self.userId newLocation:loc];
    }
}

-(void)textViewDidEndEditing:(UITextView *)textView {
    [[DocumentsDataHandler handler] changeCursorLocationForDocumntId:self.documentId userId:self.userId newLocation:-1];
}

-(void)textViewDidBeginEditing:(UITextView *)textView {
    NSInteger loc = [textView offsetFromPosition:textView.beginningOfDocument toPosition:textView.selectedTextRange.start];
    
    [[DocumentsDataHandler handler] changeCursorLocationForDocumntId:self.documentId userId:self.userId newLocation:loc];
}

#pragma mark - UITextFieldDelegate

-(void)titleTextFieldChanged {
    if ([self.titleTextField.text isEqualToString:self.document.title]) {
        return;
    }
    
    [[DocumentsDataHandler handler] editTitleForDocumentWithId:self.documentId newTitle:self.titleTextField.text];
}

#pragma mark - CursorViewsManagerDelegate

-(void)addViewToContainer:(UIView *)viewToAdd {
    [self.bodyTextView addSubview:viewToAdd];
}

#pragma mark - Lazy inits

-(CursorViewsManager *)cursorManager {
    if (!_cursorManager) {
        _cursorManager = [[CursorViewsManager alloc] init];
        _cursorManager.delegate = self;
    }
    return _cursorManager;
}

@end
