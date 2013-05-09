//
//  SDSharingSettingsViewController.m
//  SigningDay
//
//  Created by Vytautas Gudaitis on 8/20/12.
//
//

#import "SDSharingSettingsViewController.h"
#import "SDAppDelegate.h"
#import <FacebookSDK/FacebookSDK.h>
#import "Master.h"
#import <Accounts/Accounts.h>
#import <Twitter/Twitter.h>

@interface SDSharingSettingsViewController ()

@end

@implementation SDSharingSettingsViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    self.tableView.backgroundColor = [UIColor colorWithRed:140.0f/255.0f green:140.0f/255.0f blue:140.0f/255.0f alpha:1];
    
    UIImage *image = [UIImage imageNamed:@"back_nav_button.png"];
    CGRect frame = CGRectMake(0, 0, image.size.width, image.size.height);
    UIButton *button = [[UIButton alloc] initWithFrame:frame];
    [button setBackgroundImage:image forState:UIControlStateNormal];
    [button addTarget:self.navigationController action:@selector(popViewControllerAnimated:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithCustomView:button];
    self.navigationItem.leftBarButtonItem = barButton;
}

#pragma mark - Table view delegate and data source methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    SDAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    
    if (indexPath.row == 0) { // Facebook
        
        NSManagedObjectContext *context = [NSManagedObjectContext MR_contextForCurrentThread];
        Master *master = [Master MR_findFirstByAttribute:@"username" withValue:[[NSUserDefaults standardUserDefaults] valueForKey:@"username"] inContext:context];
        BOOL facebook = [master.facebookSharingOn boolValue];
        
        if (!facebook) {
            if (appDelegate.fbSession.state != FBSessionStateCreated || !appDelegate.fbSession) {
                appDelegate.fbSession = [[FBSession alloc] initWithPermissions:[NSArray arrayWithObjects:@"email", @"publish_actions", nil]];
            }
            [appDelegate.fbSession openWithCompletionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
                NSLog(@"FB access token: %@", [appDelegate.fbSession accessToken]);
                if (status == FBSessionStateOpen) {
                    master.facebookSharingOn = [NSNumber numberWithBool:YES];
                    [context MR_save];
                    [tableView reloadData];
                }
            }];
        } else {
            [appDelegate.fbSession close];
            
            master.facebookSharingOn = [NSNumber numberWithBool:NO];
            [context MR_save];
            [tableView reloadData];
        }
    } else if (indexPath.row == 1) { // Twitter
        NSManagedObjectContext *context = [NSManagedObjectContext MR_contextForCurrentThread];
        Master *master = [Master MR_findFirstByAttribute:@"username" withValue:[[NSUserDefaults standardUserDefaults] valueForKey:@"username"] inContext:context];
        BOOL twitter = [master.twitterSharingOn boolValue];
        
        if (!twitter) {
            ACAccountStore *store = [[ACAccountStore alloc] init];
            ACAccountType *twitterAccountType = [store accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
            
            [store requestAccessToAccountsWithType:twitterAccountType
                             withCompletionHandler:^(BOOL granted, NSError *error) {
                                 if (!granted) {
                                      NSLog(@"User rejected access to the account.");
                                     
                                     master.twitterSharingOn = [NSNumber numberWithBool:NO];
                                     [context MR_save];
                                     
                                     dispatch_async(dispatch_get_main_queue(), ^{
                                         [tableView reloadData];
                                     });
                                 } else {
                                     master.twitterSharingOn = [NSNumber numberWithBool:YES];
                                     [context MR_save];
                                     
                                      NSArray *twitterAccounts = [store accountsWithAccountType:twitterAccountType];
                                     if ([twitterAccounts count] > 0) {
                                         
                                         ACAccount *account = [twitterAccounts objectAtIndex:0];
                                         appDelegate.twitterAccount = account;                                         
                                     }
                                     dispatch_async(dispatch_get_main_queue(), ^{
                                         [tableView reloadData];
                                     });
                                 }
                             }];
        } else {
            master.twitterSharingOn = [NSNumber numberWithBool:NO];
            [context MR_save];
            [tableView reloadData];
        }
    }
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"SharingSettingsCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:CellIdentifier];
    }
    
    NSManagedObjectContext *context = [NSManagedObjectContext MR_contextForCurrentThread];
    Master *master = [Master MR_findFirstByAttribute:@"username" withValue:[[NSUserDefaults standardUserDefaults] valueForKey:@"username"] inContext:context];
    
    if (indexPath.row == 0) { // Facebook
        cell.textLabel.text = @"Facebook";
        
        BOOL facebook = [master.facebookSharingOn boolValue];
        if (facebook)
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        else
            cell.accessoryType = UITableViewCellAccessoryNone;
    } else if (indexPath.row == 1) { // Twitter
        cell.textLabel.text = @"Twitter";

        BOOL twitter = [master.twitterSharingOn boolValue];
        if (twitter)
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        else
            cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}

@end
