//
//  SDCameraOverlayView.m
//  SigningDay
//
//  Created by Vytautas Gudaitis on 7/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SDCameraOverlayView.h"
#import "PSYBlockTimer.h"

@interface SDCameraOverlayView ()

@end

@implementation SDCameraOverlayView

@synthesize delegate = _delegate;
@synthesize flashButton = _flashButton;
@synthesize cameraSwitch = _cameraSwitch;
@synthesize takePictureButton = _takePictureButton;
@synthesize isCapturing = _isCapturing;
@synthesize captureButton = _captureButton;
@synthesize changeCameraButton = _changeCameraButton;
@synthesize isPortrait = _isPortrait;
@synthesize cancelButton = _cancelButton;
@synthesize bottomBackgroundImageView = _bottomBackgroundImageView;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.bottomBackgroundImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, self.bounds.size.height-60, 320, 60)];
        self.bottomBackgroundImageView.image = [UIImage imageNamed:@"camera_bottom_bg.png"];
        self.bottomBackgroundImageView.userInteractionEnabled = YES;
        [self addSubview:self.bottomBackgroundImageView];
        
        UIImage *image;
        
        if ([UIImagePickerController isCameraDeviceAvailable: UIImagePickerControllerCameraFlashModeAuto] &&
            [UIImagePickerController isCameraDeviceAvailable: UIImagePickerControllerCameraFlashModeOn] &&
            [UIImagePickerController isCameraDeviceAvailable: UIImagePickerControllerCameraFlashModeOff]) {
            
            image = [UIImage imageNamed:@"flash_auto_button.png"];
            self.flashButton = [[UIButton alloc] initWithFrame:CGRectMake(8, 15, image.size.width, image.size.height)];
            [self.flashButton setBackgroundImage:image forState:UIControlStateNormal];
            [self.flashButton addTarget:self action:@selector(setFlash:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:self.flashButton];
        }
        
        self.cameraSwitch = [UICustomSwitch switchWithLeftText:nil andRight:nil];
        self.cameraSwitch.frame = CGRectMake(250, 13, 60, 16);
        [self.cameraSwitch addTarget:self action:@selector(switchCamera:) forControlEvents:UIControlEventValueChanged];
        self.cameraSwitch.on = NO;
        [self.bottomBackgroundImageView addSubview:self.cameraSwitch];
        
        image = [UIImage imageNamed:@"capture_image_button.png"];
        self.takePictureButton = [[UIButton alloc] initWithFrame:CGRectMake(118, 11, image.size.width, image.size.height)];
        [self.takePictureButton setBackgroundImage:image forState:UIControlStateNormal];
        [self.takePictureButton addTarget:self action:@selector(takePicture:) forControlEvents:UIControlEventTouchUpInside];
        [self.bottomBackgroundImageView addSubview:self.takePictureButton];
        
        image = [UIImage imageNamed:@"capture_video_button_inactive.png"];
        self.captureButton = [[UIButton alloc] initWithFrame:CGRectMake(118, 11, image.size.width, image.size.height)];
        [self.captureButton setBackgroundImage:image forState:UIControlStateNormal];
        [self.captureButton setBackgroundImage:[UIImage imageNamed:@"capture_video_button_active.png"] forState:UIControlStateSelected];
        [self.captureButton addTarget:self action:@selector(captureButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [self.bottomBackgroundImageView addSubview:self.captureButton];
        self.captureButton.alpha = 0;
        
        if ([UIImagePickerController isCameraDeviceAvailable: UIImagePickerControllerCameraDeviceFront]) {
            image = [UIImage imageNamed:@"change_camera_button.png"];
            self.changeCameraButton = [[UIButton alloc] initWithFrame:CGRectMake(242, 15, image.size.width, image.size.height)];
            [self.changeCameraButton setBackgroundImage:image forState:UIControlStateNormal];
            [self.changeCameraButton addTarget:self action:@selector(cameraChangePressed:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:self.changeCameraButton];
        }
        
        image = [UIImage imageNamed:@"x_button_gray.png"];
        self.cancelButton = [[UIButton alloc] initWithFrame:CGRectMake(10, 13, image.size.width, image.size.height)];
        [self.cancelButton setBackgroundImage:image forState:UIControlStateNormal];
        [self.cancelButton addTarget:self action:@selector(cancelButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [self.bottomBackgroundImageView addSubview:self.cancelButton];
    }
    return self;
}

- (void)takePicture:(UIButton *)sender
{
    [self hideControls];
    [self.delegate cameraOverlayViewDidTakePicture:self];
}

- (void)setFlash:(id)sender
{
    [self.delegate cameraOverlayViewDidChangeFlash:self];
}

- (void)switchCamera:(UICustomSwitch *)sender
{
    [self.delegate cameraOverlayView:self didSwitchTo:sender.on];
    
    [self hideControls];
    
    [NSTimer scheduledTimerWithTimeInterval:1.5 repeats:NO usingBlock:^(NSTimer *timer) {
        [self showControls];
    }];
}

- (void)captureButtonPressed:(UIButton *)sender
{
    if (self.isCapturing) {
        self.isCapturing = NO;
        self.captureButton.selected = NO;
        [self.delegate cameraOverlayViewDidStopCapturing:self];
        [self hideControls];
    } else {
        self.isCapturing = YES;
        self.captureButton.selected = YES;
        self.captureButton.userInteractionEnabled = NO;
        [NSTimer scheduledTimerWithTimeInterval:1.5 repeats:NO usingBlock:^(NSTimer *timer) {
            self.captureButton.userInteractionEnabled = YES;
        }];
        [self.delegate cameraOverlayViewDidStartCapturing:self];
    }
}

- (void)cameraChangePressed:(UIButton *)sender
{
    if ([UIImagePickerController isCameraDeviceAvailable: UIImagePickerControllerCameraDeviceFront]) {
        if (self.isPortrait) {
            self.isPortrait = NO;
            self.flashButton.alpha = 1;
        } else {
            self.isPortrait = YES;
            self.flashButton.alpha = 0;
        }
        [self.delegate cameraOverlayView:self didChangeCamera:self.isPortrait];
    }
}

- (void)cancelButtonPressed:(UIButton *)sender
{
    [self.delegate cameraOverlayViewDidCancel:self];
}

- (void)hideControls
{
    [UIView beginAnimations:nil context:nil];
    self.flashButton.alpha = 0;
    self.takePictureButton.alpha = 0;
    self.captureButton.alpha = 0;
    self.changeCameraButton.alpha = 0;
    self.bottomBackgroundImageView.alpha = 0;
    [UIView commitAnimations];
}

- (void)showControls
{
    [UIView beginAnimations:nil context:nil];
    
    if (!self.cameraSwitch.on) {
        self.takePictureButton.alpha = 1;
        self.captureButton.alpha = 0;
    } else {
        self.isCapturing = NO;
        self.takePictureButton.alpha = 0;
        self.captureButton.alpha = 1;
    }
    
    if (self.isPortrait) {
        self.flashButton.alpha = 0;
    } else {
        self.flashButton.alpha = 1;
    }
    
    self.changeCameraButton.alpha = 1;
    self.bottomBackgroundImageView.alpha = 1;
    
    [UIView commitAnimations];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
