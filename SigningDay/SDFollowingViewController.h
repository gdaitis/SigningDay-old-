//
//  SDFollowingViewController.h
//  SigningDay
//
//  Created by Lukas Kekys on 5/13/13.
//
//

#import <UIKit/UIKit.h>

typedef enum {

	CONTROLLER_TYPE_FOLLOWING = 0,
	CONTROLLER_TYPE_FOLLOWERS
} ControllerType;

@class SDFollowingViewController;
@class User;

@interface SDFollowingViewController : UITableViewController <UISearchDisplayDelegate, UISearchBarDelegate>

@property (nonatomic, assign) ControllerType controllerType;

@end

