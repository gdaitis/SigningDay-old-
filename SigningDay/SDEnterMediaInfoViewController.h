//
//  SDEnterMediaInfoViewController.h
//  SigningDay
//
//  Created by Vytautas Gudaitis on 7/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIPlaceHolderTextView.h"

@interface SDEnterMediaInfoViewController : UITableViewController

@property (nonatomic, weak) IBOutlet UIPlaceHolderTextView *titleTextView;
@property (nonatomic, weak) IBOutlet UIPlaceHolderTextView *descriptionTextView;

@property (nonatomic, strong) UISwitch *facebookSwitch;
@property (nonatomic, strong) UISwitch *twitterSwitch;
@property (nonatomic, strong) UILabel *facebookConfigureLabel;
@property (nonatomic, strong) UILabel *twitterConfigureLabel;

@property (nonatomic, strong) NSArray *tagsArray;

- (void)cancelButtonPressed;

@end