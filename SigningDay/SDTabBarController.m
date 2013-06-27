//
//  SDTabBarController.m
//  SigningDay
//
//  Created by Vytautas Gudaitis on 7/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SDTabBarController.h"
#import "SDAPIClient.h"
#import "SDEnterMediaInfoViewController.h"
#import "SDPublishPhotoTableViewController.h"
#import "SDPublishVideoTableViewController.h"
#import "SDCameraOverlayView.h"
#import "SDLoginViewController.h"
#import "SDNavigationController.h"
#import <QuartzCore/QuartzCore.h>
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "SDSettingsViewController.h"
#import "Reachability.h"

NSString * const kSDTabBarShouldHideNotification = @"SDTabBarShouldHideNotificationName";
NSString * const kSDTabBarShouldShowNotification = @"SDTabBarShouldShowNotificationName";

@interface SDTabBarController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIActionSheetDelegate, SDCameraOverlayViewDelegate, SDLoginViewControllerDelegate, NSFetchedResultsControllerDelegate, SDNavigationControllerDelegate, SDPublishVideoTableViewControllerDelegate, SDPublishPhotoTableViewControllerDelegate>

@property (nonatomic, strong) UIImage *capturedImage;
@property (nonatomic, strong) NSURL *capturedVideoURL;
@property (nonatomic, strong) NSString *mediaType;
@property (nonatomic, strong) UIImagePickerController *imagePicker;
@property (nonatomic, strong) SDLoginViewController *loginViewController;
@property BOOL isFromLibrary;

- (void)showLoginScreen;
- (void)showActionSheet;

@end

@implementation SDTabBarController

@synthesize capturedImage = _capturedImage;
@synthesize capturedVideoURL = _capturedVideoURL;
@synthesize mediaType = _mediaType;
@synthesize imagePicker = _imagePicker;
@synthesize loginViewController = _loginViewController;
@synthesize isFromLibrary = _isFromLibrary;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showLoginScreen) name:kSDAPICLientNoApiKeyNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hideNewTabBar) name:kSDTabBarShouldHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showNewTabBar) name:kSDTabBarShouldShowNotification object:nil];
    
    [self.btn2 addTarget:self action:@selector(centerButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)showLoginScreen
{
    if (!self.loginViewController) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
        self.loginViewController = [storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
        [self.loginViewController setModalPresentationStyle:UIModalPresentationFullScreen];
        self.loginViewController.delegate = self;
        [self presentModalViewController:self.loginViewController animated:YES];
    } else if (!(self.loginViewController.isViewLoaded && self.loginViewController.view.window)) {
        [self presentModalViewController:self.loginViewController animated:YES];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"loggedIn"])
        [self showLoginScreen];
}

- (void)centerButtonPressed:(UIButton *)sender
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Choose source" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Camera", @"Library", nil];
    actionSheet.tag = 101;
    [actionSheet showFromTabBar:self.tabBar];
}

- (void)viewWillUnload
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - SDLoginViewController delegate methods

- (void)loginViewControllerDidFinishLoggingIn:(SDLoginViewController *)loginViewController
{
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark - UIActionSheet delegate methods

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet.tag == 101) {
        if (buttonIndex == 2)
            return;
        
        self.imagePicker = [[UIImagePickerController alloc] init];
        self.imagePicker.delegate = self;
        self.imagePicker.wantsFullScreenLayout = YES;
        if (buttonIndex == 0) {
            self.isFromLibrary = NO;
            self.imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
            self.imagePicker.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType: UIImagePickerControllerSourceTypeCamera];
            self.imagePicker.cameraViewTransform = CGAffineTransformMakeScale(1.23, 1.23);
            self.imagePicker.cameraFlashMode = UIImagePickerControllerCameraFlashModeAuto;
            self.imagePicker.showsCameraControls = NO;
            
            [[Reachability reachabilityForInternetConnection] startNotifier];
            NetworkStatus internetStatus = [[Reachability reachabilityForInternetConnection] currentReachabilityStatus];
            if (internetStatus == ReachableViaWiFi) {
                self.imagePicker.videoQuality = UIImagePickerControllerQualityTypeHigh;
            } else {
                self.imagePicker.videoQuality = UIImagePickerControllerQualityTypeLow;
            }
            
            SDCameraOverlayView *cameraOverlayView = [[SDCameraOverlayView alloc] initWithFrame:CGRectMake(0, 0, 320, self.view.bounds.size.height)];
            cameraOverlayView.delegate = self;
            self.imagePicker.cameraOverlayView = cameraOverlayView;
        } else if (buttonIndex == 1) {
            self.isFromLibrary = YES;
            self.imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            self.imagePicker.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType: UIImagePickerControllerSourceTypePhotoLibrary];
        }
        [self presentModalViewController:self.imagePicker animated:YES];
    } else if (actionSheet.tag == 102) {
        if (buttonIndex == 0) {
            SDNavigationController *navigationController;
            if ([self.mediaType isEqual:@"public.image"]) {
                SDNavigationController *publishVideoNavigationViewController = [[UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil] instantiateViewControllerWithIdentifier:@"PublishPhotoNavigationViewController"];
                navigationController = publishVideoNavigationViewController;
            } else if ([self.mediaType isEqual:@"public.movie"]) {
                SDNavigationController *publishPhotoNavigationViewController = [[UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil] instantiateViewControllerWithIdentifier:@"PublishVideoNavigationViewController"];
                navigationController = publishPhotoNavigationViewController;
            }
            navigationController.myDelegate = self;
            [self dismissViewControllerAnimated:YES completion:^{
                [self presentViewController:navigationController animated:YES completion:nil];
            }];

        } else if (buttonIndex == 1 && !self.isFromLibrary) {
            if ([self.mediaType isEqual:@"public.movie"])
                UISaveVideoAtPathToSavedPhotosAlbum([self.capturedVideoURL path], nil, nil, nil);
            else if ([self.mediaType isEqual:@"public.image"])
                UIImageWriteToSavedPhotosAlbum(self.capturedImage, nil, nil, nil);
            
            [self dismissModalViewControllerAnimated:YES];
        } else if (buttonIndex == 2 && !self.isFromLibrary) {
            SDCameraOverlayView *cameraOverlayView = [[SDCameraOverlayView alloc] initWithFrame:CGRectMake(0, 0, 320, self.view.bounds.size.height)];
            cameraOverlayView.delegate = self;
            self.imagePicker.cameraOverlayView = cameraOverlayView;
        }
    } else if (actionSheet.tag == 103) {
        if (buttonIndex == 0 && !self.isFromLibrary) {
            if ([self.mediaType isEqual:@"public.movie"])
                UISaveVideoAtPathToSavedPhotosAlbum([self.capturedVideoURL path], nil, nil, nil);
            else if ([self.mediaType isEqual:@"public.image"])
                UIImageWriteToSavedPhotosAlbum(self.capturedImage, nil, nil, nil);
        }
        [self dismissModalViewControllerAnimated:YES];
    }
}

#pragma mark - UIImagePickerController delegate methods

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *snapshotImage = nil;
    self.mediaType = [info valueForKey:UIImagePickerControllerMediaType];
    if ([self.mediaType isEqual:@"public.movie"]) {
        
        NSURL *videoURL= [info objectForKey:UIImagePickerControllerMediaURL];
        self.capturedVideoURL = videoURL;
        
        AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:videoURL options:nil];
        AVAssetImageGenerator *gen = [[AVAssetImageGenerator alloc] initWithAsset:asset];
        gen.appliesPreferredTrackTransform = YES;
        CMTime time = CMTimeMakeWithSeconds(0.0, 600);
        NSError *error = nil;
        CMTime actualTime;
        
        CGImageRef image = [gen copyCGImageAtTime:time actualTime:&actualTime error:&error];
        snapshotImage = [[UIImage alloc] initWithCGImage:image];
        
        CGImageRelease(image);

        
        [self showActionSheet];
        

    } else if ([self.mediaType isEqual:@"public.image"]) {
        snapshotImage = [info valueForKey:UIImagePickerControllerOriginalImage];
        self.capturedImage = snapshotImage;
        
        [self showActionSheet];
    }
    
    if (snapshotImage && picker.sourceType == UIImagePickerControllerSourceTypeCamera) {
        UIImageView *snapshot = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 420)];
        snapshot.image = snapshotImage;
        snapshot.transform = picker.cameraViewTransform;
        picker.cameraOverlayView = snapshot;
    }
}

- (void)showActionSheet
{
    UIActionSheet *actionSheet;
    if (!self.isFromLibrary) {
        [[Reachability reachabilityForInternetConnection] startNotifier];
        NetworkStatus internetStatus = [[Reachability reachabilityForInternetConnection] currentReachabilityStatus];
        if (internetStatus == ReachableViaWiFi) {
            actionSheet = [[UIActionSheet alloc] initWithTitle:@"Choose an action" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Send", @"Save to Library", nil];
            actionSheet.tag = 102;
        } else {
            actionSheet = [[UIActionSheet alloc] initWithTitle:@"Choose an action" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Save to Library", nil];
            actionSheet.tag = 103;
        }
    } else {
        actionSheet = [[UIActionSheet alloc] initWithTitle:@"Choose an action" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Send", nil];
        actionSheet.tag = 102;
    }
    
    [actionSheet showFromTabBar:self.tabBar];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark - SDCameraOverlayView delegate methods

- (void)cameraOverlayView:(SDCameraOverlayView *)view didSwitchTo:(BOOL)state
{
    if (!state)
        [self.imagePicker setCameraCaptureMode:UIImagePickerControllerCameraCaptureModePhoto];
    else
        [self.imagePicker setCameraCaptureMode:UIImagePickerControllerCameraCaptureModeVideo];
}

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

- (void)cameraOverlayViewDidStartCapturing:(SDCameraOverlayView *)view
{
    [self.imagePicker startVideoCapture];
}

- (void)cameraOverlayViewDidStopCapturing:(SDCameraOverlayView *)view
{
    [self.imagePicker stopVideoCapture];
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

#pragma mark - SDNavigationController delegate mothods

- (void)navigationControllerWantsToClose:(SDNavigationController *)navigationController
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - SDPublishVideoTableViewControllerDelegate delegate methods

- (NSURL *)urlOfVideo
{
    return self.capturedVideoURL;
}

#pragma mark - SDPublishPhotoTableViewControllerDelegate delegate methods

- (UIImage *)capturedImageFromDelegate
{
    return self.capturedImage;
}

#pragma mark - SDConversationsViewController delegate methods

- (void)conversationsViewControllerSettingsDidLogout:(SDConversationsViewController *)conversationsViewController
{
    [self showLoginScreen];
}

#pragma mark - SDProfileViewController delegate methods

- (void)profileViewControllerSettingsDidLogout:(SDProfileViewController *)profileViewController
{
    [self showLoginScreen];
    [self selectTab:0];
}

@end
