//
//  SDProfileViewController.m
//  SigningDay
//
//  Created by Vytautas Gudaitis on 7/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SDProfileViewController.h"
#import "SDProfileService.h"
#import "Master.h"
#import "User.h"
#import "SDImageService.h"
#import "SDLoginService.h"
#import "SDSettingsViewController.h"
#import "SDTabBarController.h"
#import "MBProgressHUD.h"
#import "UIImage+Crop.h"

@interface SDProfileViewController () <SDSettingsViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UILabel *followersNumberLabel;
@property (weak, nonatomic) IBOutlet UILabel *followingNumberLabel;
@property (weak, nonatomic) IBOutlet UILabel *videosNumberLabel;
@property (weak, nonatomic) IBOutlet UILabel *photosNumberLabel;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UITextView *bioTextView;

@property BOOL firstLoad;

- (void)reload;

@end

@implementation SDProfileViewController
@synthesize avatarImageView = _avatarImageView;
@synthesize usernameLabel = _usernameLabel;
@synthesize followersNumberLabel = _followersNumberLabel;
@synthesize followingNumberLabel = _followingNumberLabel;
@synthesize videosNumberLabel = _videosNumberLabel;
@synthesize photosNumberLabel = _photosNumberLabel;
@synthesize nameLabel = _nameLabel;
@synthesize bioTextView = _bioTextView;
@synthesize delegate = _delegate;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.delegate = (SDTabBarController *)self.tabBarController;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userDidLogout) name:kSDLoginServiceUserDidLogoutNotification object:nil];
    
    UIImage *image = [UIImage imageNamed:@"settings_button.png"];
    CGRect frame = CGRectMake(0, 0, image.size.width, image.size.height);
    UIButton *button = [[UIButton alloc] initWithFrame:frame];
    [button setBackgroundImage:image forState:UIControlStateNormal];
    [button addTarget:self action:@selector(settingsPressed) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithCustomView:button];
    self.navigationItem.leftBarButtonItem = barButton;
    
    self.usernameLabel.text = @"";
    self.followersNumberLabel.text = @"";
    self.followingNumberLabel.text = @"";
    self.videosNumberLabel.text = @"";
    self.photosNumberLabel.text = @"";
    self.nameLabel.text = @"";
    self.bioTextView.text = @"";
    
    self.firstLoad = YES;
    
    [self reload];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    NSString *username = [[NSUserDefaults standardUserDefaults] valueForKey:@"username"];
    Master *master = [Master MR_findFirstByAttribute:@"username" withValue:username];
    
    if (self.firstLoad) {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        hud.labelText = @"Updating profile";
    }
    [SDProfileService getProfileInfoForUserIdentifier:master.identifier completionBlock:^{
        [MBProgressHUD hideAllHUDsForView:self.navigationController.view animated:YES];
        if (self.firstLoad)
            self.firstLoad = NO;
        [self reload];
    } failureBlock:^{
        [MBProgressHUD hideAllHUDsForView:self.navigationController.view animated:YES];
    }];
}

- (void)reload
{
    NSString *username = [[NSUserDefaults standardUserDefaults] valueForKey:@"username"];
    Master *master = [Master MR_findFirstByAttribute:@"username" withValue:username];
    User *user = [User MR_findFirstByAttribute:@"identifier" withValue:master.identifier];
    if (user) {
        self.usernameLabel.text = user.username;
        self.followersNumberLabel.text = [NSString stringWithFormat:@"%d", [user.numberOfFollowers integerValue]];
        self.followingNumberLabel.text = [NSString stringWithFormat:@"%d", [user.numberOfFollowing integerValue]];
        self.photosNumberLabel.text = [NSString stringWithFormat:@"%d", [user.numberOfPhotos integerValue]];
        self.videosNumberLabel.text = [NSString stringWithFormat:@"%d", [user.numberOfVideos integerValue]];
        self.nameLabel.text = user.name;
        self.bioTextView.text = user.bio;
        [[SDImageService sharedService] getImageWithURLString:user.avatarUrl success:^(UIImage *image) {
            if (image != self.avatarImageView.image) {
                self.avatarImageView.image = [image imageByScalingAndCroppingForSize:CGSizeMake(50 * [UIScreen mainScreen].scale, 50 * [UIScreen mainScreen].scale)];
            }
        }];
    }
}

- (void)settingsPressed
{
    SDNavigationController *settingsNavigationViewController = [[UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil] instantiateViewControllerWithIdentifier:@"SettingsNavigationViewController"];
    settingsNavigationViewController.myDelegate = self;
    [self presentModalViewController:settingsNavigationViewController animated:YES];
}

- (void)userDidLogout
{
    self.usernameLabel.text = nil;
    self.followersNumberLabel.text = nil;
    self.followingNumberLabel.text = nil;
    self.videosNumberLabel.text = nil;
    self.photosNumberLabel.text = nil;
    self.nameLabel.text = nil;
    self.bioTextView.text = nil;
    self.avatarImageView.image = nil;
    
    self.firstLoad = YES;
}

- (void)viewDidUnload
{
    [self setAvatarImageView:nil];
    [self setUsernameLabel:nil];
    [self setFollowersNumberLabel:nil];
    [self setFollowingNumberLabel:nil];
    [self setVideosNumberLabel:nil];
    [self setPhotosNumberLabel:nil];
    [self setNameLabel:nil];
    [self setBioTextView:nil];
    [super viewDidUnload];
}

- (void)didReceiveMemoryWarning
{
    self.avatarImageView.image = nil;
}

#pragma mark - SDNavigationController delegate methods

- (void)navigationControllerWantsToClose:(SDNavigationController *)navigationController
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - SDSettingsViewController delegate methods

- (void)settingsViewControllerDidLogOut:(SDSettingsViewController *)settingsViewController
{
    [self dismissViewControllerAnimated:YES completion:^{
        [self.delegate profileViewControllerSettingsDidLogout:self];
    }];
}

@end
