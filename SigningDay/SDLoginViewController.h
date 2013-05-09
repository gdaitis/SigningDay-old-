//
//  SDLoginViewController.h
//  SigningDay
//
//  Created by Vytautas Gudaitis on 7/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SDLoginViewController;

@protocol SDLoginViewControllerDelegate <NSObject>

@optional

- (void)loginViewControllerDidFinishLoggingIn:(SDLoginViewController *)loginViewController;

@end

@interface SDLoginViewController : UIViewController

- (IBAction)loginButtonPressed:(id)sender;

@property (nonatomic, strong) id <SDLoginViewControllerDelegate> delegate;

@end
