//
//  SDPublishVideoTableViewController.m
//  SigningDay
//
//  Created by Vytautas Gudaitis on 8/2/12.
//
//

#import "SDPublishVideoTableViewController.h"
#import "Reachability.h"
#import "SDNavigationController.h"
#import "SDUploadService.h"

@interface SDPublishVideoTableViewController ()

@end

@implementation SDPublishVideoTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    SDNavigationController *navigationController = (SDNavigationController *)self.navigationController;
    self.delegate = (id <SDPublishVideoTableViewControllerDelegate>) navigationController.myDelegate;
}

- (IBAction)publishVideoPressed:(id)sender
{
    [self.titleTextView resignFirstResponder];
    [self.descriptionTextView resignFirstResponder];

    NSURL *videoURL = [self.delegate urlOfVideo];
    NSString *title = self.titleTextView.text;
    NSString *description = self.descriptionTextView.text;
    
    if ([title isEqualToString:@""]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Warning" message:@"Please enter the title" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
        [alert show];
    } else {
        [SDUploadService uploadVideoWithURL:videoURL
                                  withTitle:title
                                description:description
                                       tags:[self.tagsArray componentsJoinedByString:@","]
                            facebookSharing:self.facebookSwitch.on
                             twitterSharing:self.twitterSwitch.on
                            completionBlock:^{
                                [self cancelButtonPressed];
                            }];
    }
}

@end
