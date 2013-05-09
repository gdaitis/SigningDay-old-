//
//  SDForgotPasswordViewController.m
//  SigningDay
//
//  Created by Vytautas Gudaitis on 8/21/12.
//
//

#import "SDForgotPasswordViewController.h"
#import "SDAPIClient.h"

@implementation SDForgotPasswordViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    NSString *urlString = [NSString stringWithFormat:@"%@/user/emailforgottenpassword.aspx", kSDBaseSigningDayURLString];
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [self.webView loadRequest:request];
    
    UIImage *image = [UIImage imageNamed:@"x_button_yellow.png"];
    CGRect frame = CGRectMake(0, 0, image.size.width, image.size.height);
    UIButton *button = [[UIButton alloc] initWithFrame:frame];
    [button setBackgroundImage:image forState:UIControlStateNormal];
    [button addTarget:self action:@selector(dismissModalViewControllerAnimated:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithCustomView:button];
    self.navigationItem.leftBarButtonItem = barButton;
}

- (void)viewDidUnload
{
    [self setWebView:nil];
    [super viewDidUnload];
}
@end
