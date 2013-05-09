//
//  SDNavigationController.m
//  SigningDay
//
//  Created by Vytautas Gudaitis on 7/30/12.
//
//

#import "SDNavigationController.h"
#import <QuartzCore/QuartzCore.h>
#import <CoreGraphics/CoreGraphics.h>

@interface SDNavigationController ()

@end

@implementation SDNavigationController

@synthesize myDelegate = _myDelegate;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    NSDictionary *textTitleAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                         [UIColor colorWithRed:48.0/255.0 green:42.0/255.0 blue:6.0/255.0 alpha:1.0], UITextAttributeTextColor,
                                         [UIColor colorWithRed:253.0/255.0 green:221.0/255.0 blue:30.0/255.0 alpha:1.0], UITextAttributeTextShadowColor,
                                         [NSValue valueWithUIOffset:UIOffsetMake(1, 1)], UITextAttributeTextShadowOffset,
                                         [UIFont fontWithName:@"BebasNeue" size:26.0], UITextAttributeFont,
                                         nil];
    self.navigationBar.titleTextAttributes = textTitleAttributes;
    [self.navigationBar setBackgroundImage:[UIImage imageNamed:@"navigation_bar_bg.png"] forBarMetrics:UIBarMetricsDefault];
    
    CGColorRef darkColor = [[UIColor blackColor] colorWithAlphaComponent:.33f].CGColor;
    CGColorRef lightColor = [UIColor clearColor].CGColor;
    
    CGFloat navigationBarBottom;
    navigationBarBottom = self.navigationBar.frame.origin.y + self.navigationBar.frame.size.height;
    
    CAGradientLayer *newShadow = [[CAGradientLayer alloc] init];
    newShadow.frame = CGRectMake(0,navigationBarBottom, self.view.frame.size.width, 3);
    newShadow.colors = [NSArray arrayWithObjects:(__bridge id)darkColor, (__bridge id)lightColor, nil];
    
    [self.view.layer addSublayer:newShadow];
}

+ (void)moveFromView:(UIView *)currentView toView:(UIView *)newView inTransition:(NSString *)kCATransitionType
{
    UIView *theWindow = [currentView superview];
    [currentView removeFromSuperview];
    [theWindow addSubview:newView];
    CATransition *animation = [CATransition animation];
    [animation setDuration:0.5];
    [animation setType:kCATransitionPush];
    [animation setSubtype:kCATransitionType];
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    [[theWindow layer] addAnimation:animation forKey:@"SwitchToView1"];
}

- (void)closePressed
{
    [self.myDelegate navigationControllerWantsToClose:self];
}

@end
