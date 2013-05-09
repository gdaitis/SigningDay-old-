//
//  SDProfileViewController.h
//  SigningDay
//
//  Created by Vytautas Gudaitis on 7/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SDNavigationController.h"

@class SDProfileViewController;

@protocol SDProfileViewControllerDelegate <NSObject>

- (void)profileViewControllerSettingsDidLogout:(SDProfileViewController *)profileViewController;

@end

@interface SDProfileViewController : UIViewController <SDNavigationControllerDelegate>

@property (nonatomic, strong) id <SDProfileViewControllerDelegate> delegate;

@end
