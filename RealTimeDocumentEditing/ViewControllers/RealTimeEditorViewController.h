//
//  RealTimeEditorViewController.h
//  RealTimeDocumentEditing
//
//  Created by Michael Tzach on 11/11/16.
//  Copyright © 2016 Michael Tzach. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RealTimeEditorViewController : UIViewController

-(instancetype)initWithEditingUserId:(NSString *)editingUserId documentId:(NSString *)documentId;

@end
