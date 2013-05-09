//
//  SDSimplifiedCameraOverlayView.m
//  SigningDay
//
//  Created by Vytautas Gudaitis on 8/13/12.
//
//

#import "SDSimplifiedCameraOverlayView.h"

@implementation SDSimplifiedCameraOverlayView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.cameraSwitch.hidden = YES;
        self.captureButton.hidden = YES;
        self.bottomBackgroundImageView.image = [UIImage imageNamed:@"camera_bottom_bg_simplified.png"];
    }
    return self;
}

@end
