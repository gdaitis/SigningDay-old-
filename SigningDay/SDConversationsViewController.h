//
//  SDConversationsViewController.h
//  SigningDay
//
//  Created by Vytautas Gudaitis on 7/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SDLoginViewController.h"
#import "SDNavigationController.h"
#import "SDNewConversationViewController.h"

@class SDConversationsViewController;

@protocol SDConversationsViewControllerDelegate <NSObject>

- (void)conversationsViewControllerSettingsDidLogout:(SDConversationsViewController *)conversationsViewController;

@end

@interface SDConversationsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, SDLoginViewControllerDelegate, SDNavigationControllerDelegate, SDNewConversationViewControllerDelegate>

@property (nonatomic, strong) id <SDConversationsViewControllerDelegate> delegate;

@end