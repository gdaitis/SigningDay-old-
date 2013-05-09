//
//  SDSettingsViewController.m
//  SigningDay
//
//  Created by Vytautas Gudaitis on 7/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SDSettingsViewController.h"
#import "SDNavigationController.h"
#import "SDAppDelegate.h"
#import "SDSimplifiedCameraOverlayView.h"
#import "SDProfileService.h"
#import "Master.h"
#import "User.h"
#import "SDAPIClient.h"
#import "SDLoginService.h"
#import "MBProgressHUD.h"

@interface SDSettingsViewController () <UITableViewDelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, SDCameraOverlayViewDelegate>

@property (nonatomic, strong) UIImagePickerController *imagePicker;
@property (nonatomic, strong) UIImage *capturedImage;

@end

@implementation SDSettingsViewController

@synthesize imagePicker = _imagePicker;
@synthesize capturedImage = _capturedImage;
@synthesize delegate = _delegate;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    SDNavigationController *navigationController = (SDNavigationController *)self.navigationController;
    self.delegate = (id <SDSettingsViewControllerDelegate>)navigationController.myDelegate;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userDidLogout) name:kSDLoginServiceUserDidLogoutNotification object:nil];
    
    UIImage *image = [UIImage imageNamed:@"x_button_yellow.png"];
    CGRect frame = CGRectMake(0, 0, image.size.width, image.size.height);
    UIButton *button = [[UIButton alloc] initWithFrame:frame];
    [button setBackgroundImage:image forState:UIControlStateNormal];
    [button addTarget:self action:@selector(cancelButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithCustomView:button];
    self.navigationItem.leftBarButtonItem = barButton;
    
    UIImage *signOutImage = [UIImage imageNamed:@"sign_out_button.png"];
    frame = CGRectMake(53, 153, signOutImage.size.width, signOutImage.size.height);
    UIButton *abutton = [[UIButton alloc] initWithFrame:frame];
    [abutton setBackgroundImage:signOutImage forState:UIControlStateNormal];
    [abutton addTarget:self action:@selector(signOutButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.tableView addSubview:abutton];
    
    self.tableView.backgroundColor = [UIColor colorWithRed:140.0f/255.0f green:140.0f/255.0f blue:140.0f/255.0f alpha:1];
}

- (void)cancelButtonPressed
{
    SDNavigationController *navigationController = (SDNavigationController *)self.navigationController;
    [navigationController closePressed];
}

- (void)signOutButtonPressed
{
    [SDLoginService logout];
}

- (void)userDidLogout
{
    [self.delegate settingsViewControllerDidLogOut:self];
}

#pragma mark UITableView delegate mothods

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    NSString *sectionTitle = [self tableView:tableView titleForHeaderInSection:section];
    if (sectionTitle == nil) {
        return nil;
    }
    
    // Create label with section title
    UILabel *label = [[UILabel alloc] init];
    label.frame = CGRectMake(20, 3, 300, 30);
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor colorWithRed:73.0/255.0 green:72.0/255.0 blue:72.0/255.0 alpha:1];
    label.shadowColor = [UIColor colorWithRed:169.0/255.0 green:169.0/255.0 blue:169.0/255.0 alpha:1];
    label.shadowOffset = CGSizeMake(0.0, 1.0);
    label.font = [UIFont boldSystemFontOfSize:16];
    label.text = sectionTitle;
    
    // Create header view and add label as a subview
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 30)];
    [view addSubview:label];
    
    return view;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
//    if (indexPath.section == 0 && indexPath.row == 1) {
//        UIActionSheet *actionSheet;
//        
//        NSManagedObjectContext *context = [NSManagedObjectContext MR_contextForCurrentThread];
//        NSString *username = [[NSUserDefaults standardUserDefaults] valueForKey:@"username"];
//        Master *master = [Master MR_findFirstByAttribute:@"username" withValue:username inContext:context];
//        
//        if (master.facebookSharingOn) {
//            actionSheet = [[UIActionSheet alloc] initWithTitle:@"Change profile picture"
//                                                      delegate:self
//                                             cancelButtonTitle:@"Cancel"
//                                        destructiveButtonTitle:@"Remove current picture"
//                                             otherButtonTitles:@"Choose picture", @"Import from Facebook", nil];
//            actionSheet.tag = 101;
//        } else {
//            actionSheet = [[UIActionSheet alloc] initWithTitle:@"Change profile picture"
//                                                      delegate:self
//                                             cancelButtonTitle:@"Cancel"
//                                        destructiveButtonTitle:@"Remove current picture"
//                                             otherButtonTitles:@"Choose picture", nil];
//            actionSheet.tag = 102;
//        }
//        [actionSheet showInView:self.view];
//    }
}

#pragma mark - UIActionSheet delegate methods

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet.tag == 101 || actionSheet.tag == 102) {
        if (buttonIndex == 0) {
            // remove pic
            [SDProfileService deleteAvatar];
        } else if (buttonIndex == 1) {
            // take pic
            UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Choose source"
                                                                     delegate:self
                                                            cancelButtonTitle:@"Cancel"
                                                       destructiveButtonTitle:nil
                                                            otherButtonTitles:@"Camera", @"Library", nil];
            actionSheet.tag = 103;
            [actionSheet showInView:self.view];
        } else if (actionSheet.tag == 101) {
            if (buttonIndex == 2) {
                // facebook
                NSManagedObjectContext *context = [NSManagedObjectContext MR_contextForCurrentThread];
                
                NSString *username = [[NSUserDefaults standardUserDefaults] valueForKey:@"username"];
                Master *master = [Master MR_findFirstByAttribute:@"username" withValue:username inContext:context];
                
                SDAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
                if (appDelegate.fbSession.state != FBSessionStateCreated || !appDelegate.fbSession) {
                    appDelegate.fbSession = [[FBSession alloc] initWithPermissions:[NSArray arrayWithObjects:@"email", @"publish_actions", nil]];
                }
                [appDelegate.fbSession openWithCompletionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
                    NSLog(@"FB access token: %@", [appDelegate.fbSession accessToken]);
                    if (status == FBSessionStateOpen) {
                        master.facebookSharingOn = [NSNumber numberWithBool:YES];
                        [context MR_save];
                    }
                }];
                
                [SDProfileService getAvatarImageFromFacebookAndSendItToServerForUserIdentifier:master.identifier completionHandler:^{
                    NSLog(@"Avatar from Facebook uploaded sucessfully");
                }];
            }
        }
    } else if (actionSheet.tag == 103) {
        self.imagePicker = [[UIImagePickerController alloc] init];
        self.imagePicker.delegate = self;
        self.imagePicker.wantsFullScreenLayout = YES;
        if (buttonIndex == 0) {
            // Camera
//            self.isFromLibrary = NO;
            self.imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
            self.imagePicker.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType: UIImagePickerControllerSourceTypeCamera];
            self.imagePicker.cameraViewTransform = CGAffineTransformMakeScale(1.23, 1.23);
            self.imagePicker.cameraFlashMode = UIImagePickerControllerCameraFlashModeAuto;
            self.imagePicker.showsCameraControls = NO;
            SDSimplifiedCameraOverlayView *cameraOverlayView = [[SDSimplifiedCameraOverlayView alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
            cameraOverlayView.delegate = self;
            self.imagePicker.cameraOverlayView = cameraOverlayView;
        } else if (buttonIndex == 1) {
            // Library
//            self.isFromLibrary = YES;
            self.imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            self.imagePicker.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType: UIImagePickerControllerSourceTypePhotoLibrary];
        }
        if (buttonIndex != 2)
            [self presentModalViewController:self.imagePicker animated:YES];
    } else if (actionSheet.tag == 104) {
        if (buttonIndex == 0) {
            // send image to server
            NSString *username = [[NSUserDefaults standardUserDefaults] valueForKey:@"username"];
            Master *master = [Master MR_findFirstByAttribute:@"username" withValue:username];
            
            [SDProfileService uploadAvatar:self.capturedImage forUserIdentifier:master.identifier completionBlock:^{
                NSLog(@"Avatar updates successfully");
            }];
        }
        [self dismissModalViewControllerAnimated:YES];
    }
}

#pragma mark - UIImagePickerController delegate methods

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image = [info valueForKey:UIImagePickerControllerOriginalImage];
    self.capturedImage = image;
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Choose an action" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Send", nil];
    actionSheet.tag = 104;
    [actionSheet showInView:self.imagePicker.view];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark - SDCameraOverlayView delegate methods

- (void)cameraOverlayViewDidChangeFlash:(SDCameraOverlayView *)view
{
    switch (self.imagePicker.cameraFlashMode) {
        case UIImagePickerControllerCameraFlashModeAuto:
            [view.flashButton setBackgroundImage:[UIImage imageNamed:@"flash_on_button.png"] forState:UIControlStateNormal];
            self.imagePicker.cameraFlashMode = UIImagePickerControllerCameraFlashModeOn;
            break;
            
        case UIImagePickerControllerCameraFlashModeOn:
            [view.flashButton setBackgroundImage:[UIImage imageNamed:@"flash_off_button.png"] forState:UIControlStateNormal];
            self.imagePicker.cameraFlashMode = UIImagePickerControllerCameraFlashModeOff;
            break;
            
        case UIImagePickerControllerCameraFlashModeOff:
            [view.flashButton setBackgroundImage:[UIImage imageNamed:@"flash_auto_button.png"] forState:UIControlStateNormal];
            self.imagePicker.cameraFlashMode = UIImagePickerControllerCameraFlashModeAuto;
            break;
    }
}

- (void)cameraOverlayViewDidTakePicture:(SDCameraOverlayView *)view
{
    [self.imagePicker takePicture];
}

- (void)cameraOverlayView:(SDCameraOverlayView *)view didChangeCamera:(BOOL)toPortrait
{
    if (toPortrait)
        self.imagePicker.cameraDevice = UIImagePickerControllerCameraDeviceFront;
    else
        self.imagePicker.cameraDevice = UIImagePickerControllerCameraDeviceRear;
}

- (void)cameraOverlayViewDidCancel:(SDCameraOverlayView *)view
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end









