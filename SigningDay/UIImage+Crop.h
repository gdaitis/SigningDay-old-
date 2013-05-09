//
//  UIImage+Crop.h
//  SigningDay
//
//  Created by Vytautas Gudaitis on 8/24/12.
//
//

#import <UIKit/UIKit.h>

@interface UIImage (Crop)

- (UIImage *)imageByScalingAndCroppingForSize:(CGSize)targetSize;

@end
