//
//  SDCommonWebViewController.m
//  SigningDay
//
//  Created by Vytautas Gudaitis on 8/29/12.
//
//

#import "SDCommonWebViewController.h"
#import "SDAppDelegate.h"
#import "MBProgressHUD.h"

@implementation SDCommonWebViewController

@synthesize webView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark UIWebView delegate methods

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    SDAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:appDelegate.window animated:YES];
    hud.labelText = @"Loading";
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    SDAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    [MBProgressHUD hideAllHUDsForView:appDelegate.window animated:YES];
}

@end
