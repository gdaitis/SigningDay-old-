//
//  SDSettingsViewController.h
//  SigningDay
//
//  Created by Vytautas Gudaitis on 7/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SDSettingsViewController;

@protocol SDSettingsViewControllerDelegate <NSObject>

- (void)settingsViewControllerDidLogOut:(SDSettingsViewController *)settingsViewController;

@end

@interface SDSettingsViewController : UITableViewController

@property (nonatomic, strong) id <SDSettingsViewControllerDelegate> delegate;

@end
