//
//  SDLoginViewController.m
//  SigningDay
//
//  Created by Vytautas Gudaitis on 7/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SDLoginViewController.h"
#import "SDLoginService.h"
#import "SDAppDelegate.h"
#import "MBProgressHUD.h"

@interface SDLoginViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;

@end

@implementation SDLoginViewController

@synthesize usernameTextField = _usernameTextField;
@synthesize passwordTextField = _passwordTextField;
@synthesize backgroundImageView = _backgroundImageView;
@synthesize delegate = _delegate;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userDidLogout) name:kSDLoginServiceUserDidLogoutNotification object:nil];
    
    UIGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeKeyboard)];
    [self.backgroundImageView addGestureRecognizer:recognizer];
    
    UIImage *bgImage;
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
    if (screenSize.height == 480) {
        bgImage = [UIImage imageNamed:@"login_bg.png"];
    }
    if (screenSize.height == 568) {
        bgImage = [UIImage imageNamed:@"login_bg-568h@2x.png"];
    }
    self.backgroundImageView.image = bgImage;
}

- (void)closeKeyboard
{
    [self.usernameTextField resignFirstResponder];
    [self.passwordTextField resignFirstResponder];
}

- (void)userDidLogout
{
    self.usernameTextField.text = @"";
    self.passwordTextField.text = @"";
}

- (IBAction)loginButtonPressed:(id)sender 
{
    [self.usernameTextField resignFirstResponder];
    [self.passwordTextField resignFirstResponder];
    
    NSString *username = self.usernameTextField.text;
    NSString *password = self.passwordTextField.text;
    [SDLoginService loginWithUsername:username password:password facebookToken:nil successBlock:^{
        [self.delegate loginViewControllerDidFinishLoggingIn:self];
    }];
}

- (IBAction)connectWithFacebookPressed:(id)sender
{
    SDAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    
    if (appDelegate.fbSession.state != FBSessionStateCreated || !appDelegate.fbSession) {
        appDelegate.fbSession = [[FBSession alloc] initWithPermissions:[NSArray arrayWithObjects:@"email", @"publish_actions", nil]];
    }
    
    [appDelegate.fbSession openWithCompletionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
        NSLog(@"FB access token: %@", [appDelegate.fbSession accessToken]);
        if (status == FBSessionStateOpen) {
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:appDelegate.window animated:YES];
            hud.labelText = @"Logging in";
            [SDLoginService loginWithUsername:nil password:nil facebookToken:[appDelegate.fbSession accessToken] successBlock:^{
                [MBProgressHUD hideAllHUDsForView:appDelegate.window animated:YES];
                [self.delegate loginViewControllerDidFinishLoggingIn:self];
            }];
        }
    }];
}

- (IBAction)connectWithTwitterPressed:(id)sender
{
    
}

- (void)viewDidUnload 
{
    [self setUsernameTextField:nil];
    [self setPasswordTextField:nil];
    [self setBackgroundImageView:nil];
    [super viewDidUnload];
}

#pragma mark - UITextField delegate methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == self.usernameTextField)
        [self.passwordTextField becomeFirstResponder];
    else
        [textField resignFirstResponder];
    
    return YES;
}

@end
