//
//  SDFollowingViewController.h
//  SigningDay
//
//  Created by Lukas Kekys on 5/13/13.
//
//

#import <UIKit/UIKit.h>

@class SDFollowingViewController;
@class User;

@protocol SDFollowingViewControllerDelegate <NSObject>

- (void)didFinishSelectingFollowersInFollowingViewController:(SDFollowingViewController *)followingViewController;

@end

@interface SDFollowingViewController : UITableViewController <UISearchDisplayDelegate, UISearchBarDelegate>

@property (nonatomic, strong) id <SDFollowingViewControllerDelegate> delegate;

@end

