//
//  SDNavigationController.h
//  SigningDay
//
//  Created by Vytautas Gudaitis on 7/30/12.
//
//

#import <UIKit/UIKit.h>

@class SDNavigationController;

@protocol SDNavigationControllerDelegate <NSObject>

@optional

- (void)navigationControllerWantsToClose:(SDNavigationController *)navigationController;

@end

@interface SDNavigationController : UINavigationController

@property (nonatomic, strong) id <SDNavigationControllerDelegate> myDelegate;

- (void)closePressed;
+ (void)moveFromView:(UIView *)currentView toView:(UIView *)newView inTransition:(NSString *)kCATransitionType;

@end
