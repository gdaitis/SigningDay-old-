//
//  SDCameraOverlayView.h
//  SigningDay
//
//  Created by Vytautas Gudaitis on 7/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UICustomSwitch.h"

@class SDCameraOverlayView;

@protocol SDCameraOverlayViewDelegate <NSObject>

@optional

- (void)cameraOverlayView:(SDCameraOverlayView *)view didSwitchTo:(BOOL)state;
- (void)cameraOverlayViewDidChangeFlash:(SDCameraOverlayView *)view;
- (void)cameraOverlayViewDidTakePicture:(SDCameraOverlayView *)view;
- (void)cameraOverlayViewDidStartCapturing:(SDCameraOverlayView *)view;
- (void)cameraOverlayViewDidStopCapturing:(SDCameraOverlayView *)view;
- (void)cameraOverlayView:(SDCameraOverlayView *)view didChangeCamera:(BOOL)toPortrait;
- (void)cameraOverlayViewDidCancel:(SDCameraOverlayView *)view;

@end

@interface SDCameraOverlayView : UIView

@property (nonatomic, strong) id <SDCameraOverlayViewDelegate> delegate;
@property (nonatomic, strong) UIButton *flashButton;

@property (nonatomic, strong) UIButton *takePictureButton;
@property (nonatomic, strong) UICustomSwitch *cameraSwitch;
@property BOOL isCapturing;
@property (nonatomic, strong) UIButton *captureButton;
@property (nonatomic, strong) UIButton *changeCameraButton;
@property BOOL isPortrait;
@property (nonatomic, strong) UIButton *cancelButton;
@property (nonatomic, strong) UIImageView *bottomBackgroundImageView;

@property (nonatomic, strong) UIImage *flashImageOn;
@property (nonatomic, strong) UIImage *flashImageOff;
@property (nonatomic, strong) UIImage *flashImageAuto;

- (void)hideControls;
- (void)showControls;

@end
