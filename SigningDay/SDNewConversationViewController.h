//
//  SDNewConversationViewController.h
//  SigningDay
//
//  Created by Vytautas Gudaitis on 8/10/12.
//
//

#import <UIKit/UIKit.h>

@class SDNewConversationViewController;
@class User;

@protocol SDNewConversationViewControllerDelegate <NSObject>

- (void)newConversationViewController:(SDNewConversationViewController *)newConversationViewController didFinishPickingUser:(User *)user;

@end

@interface SDNewConversationViewController : UITableViewController <UISearchDisplayDelegate, UISearchBarDelegate>

@property (nonatomic, strong) id <SDNewConversationViewControllerDelegate> delegate;

@end
