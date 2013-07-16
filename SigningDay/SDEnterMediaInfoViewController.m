//
//  SDEnterMediaInfoViewController.m
//  SigningDay
//
//  Created by Vytautas Gudaitis on 7/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SDEnterMediaInfoViewController.h"
#import "SDNavigationController.h"
#import <QuartzCore/QuartzCore.h>
#import "Master.h"
#import "SDAppDelegate.h"
#import "SDAddTagsViewController.h"
#import "User.h"

@interface SDEnterMediaInfoViewController () <SDAddTagsViewControllerDelegate, SDNavigationControllerDelegate>

@property (weak, nonatomic) IBOutlet UILabel *tagsLabel;
@property (nonatomic, strong) NSArray *tagUsersArray;

- (CGFloat)getHeightOfTagsTextLabel;

@end

@implementation SDEnterMediaInfoViewController

@synthesize titleTextView = _titleTextView;
@synthesize descriptionTextView = _descriptionTextView;
@synthesize facebookSwitch = _facebookSwitch;
@synthesize twitterSwitch = _twitterSwitch;
@synthesize facebookConfigureLabel = _facebookConfigureLabel;
@synthesize twitterConfigureLabel = _twitterConfigureLabel;
@synthesize tagsLabel = _tagsLabel;
@synthesize tagsArray = _tagsArray;
@synthesize tagUsersArray = _tagUsersArray;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIImage *image = [UIImage imageNamed:@"x_button_yellow.png"];
    CGRect frame = CGRectMake(0, 0, image.size.width, image.size.height);
    UIButton *button = [[UIButton alloc] initWithFrame:frame];
    [button setBackgroundImage:image forState:UIControlStateNormal];
    [button addTarget:self action:@selector(cancelButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithCustomView:button];
    self.navigationItem.leftBarButtonItem = barButton;
    
    self.titleTextView.placeholder = @"Title";
    self.titleTextView.placeholderColor = [UIColor grayColor];
    
    self.descriptionTextView.placeholder = @"Description";
    self.descriptionTextView.placeholderColor = [UIColor grayColor];
    
    self.tableView.backgroundColor = [UIColor colorWithRed:140.0f/255.0f green:140.0f/255.0f blue:140.0f/255.0f alpha:1];
    
    self.tagsLabel.textColor = [UIColor grayColor];
}

- (void)cancelButtonPressed
{    
    SDNavigationController *navigationController = (SDNavigationController *)self.navigationController;
    [navigationController closePressed];
}

- (void)viewDidUnload
{
    [self setDescriptionTextView:nil];
    [self setTagsLabel:nil];
    [super viewDidUnload];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqual:@"presentAddTagsViewController"]) {
        SDNavigationController *navigationController = [segue destinationViewController];
        navigationController.myDelegate = self;
    }
}

- (CGFloat)getHeightOfTagsTextLabel
{
    NSString *text;
    if ([self.tagsArray count] == 0)
        text = @"Tags";
    else
        text = [self.tagsArray componentsJoinedByString:@", "];
    CGSize size = [text sizeWithFont:[UIFont systemFontOfSize:14] constrainedToSize:CGSizeMake(221, CGFLOAT_MAX) lineBreakMode:UILineBreakModeWordWrap];
    return size.height;
}

#pragma mark - UITableView delegate and data source methods

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    NSString *sectionTitle = [self tableView:tableView titleForHeaderInSection:section];
    if (sectionTitle == nil) {
        return nil;
    }
    
    // Create label with section title
    UILabel *label = [[UILabel alloc] init];
    label.frame = CGRectMake(20, 3, 300, 30);
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor colorWithRed:73.0/255.0 green:72.0/255.0 blue:72.0/255.0 alpha:1];
    label.shadowColor = [UIColor colorWithRed:169.0/255.0 green:169.0/255.0 blue:169.0/255.0 alpha:1];
    label.shadowOffset = CGSizeMake(0.0, 1.0);
    label.font = [UIFont boldSystemFontOfSize:16];
    label.text = sectionTitle;
    
    // Create header view and add label as a subview
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 30)];
    [view addSubview:label];
    
    return view;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 2) {
        SDAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
        
        NSManagedObjectContext *context = [NSManagedObjectContext MR_contextForCurrentThread];
        Master *master = [Master MR_findFirstByAttribute:@"username" withValue:[[NSUserDefaults standardUserDefaults] valueForKey:@"username"] inContext:context];
        
        if (indexPath.row == 0) {
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
                        
                        [self.tableView reloadData];
                    }
                    
                }];
            }
        } else if (indexPath.row == 1) {
            BOOL twitter = [master.twitterSharingOn boolValue];
            if (!twitter) {
                ACAccountStore *store = [[ACAccountStore alloc] init];
                ACAccountType *twitterAccountType = [store accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
                
                [store requestAccessToAccountsWithType:twitterAccountType
                                 withCompletionHandler:^(BOOL granted, NSError *error) {
                                     if (!granted) {
                                         NSLog(@"User rejected access to the account.");
                                     } else {
                                         master.twitterSharingOn = [NSNumber numberWithBool:YES];
                                         [context MR_save];
                                         
                                         NSArray *twitterAccounts = [store accountsWithAccountType:twitterAccountType];
                                         if ([twitterAccounts count] > 0) {
                                             
                                             ACAccount *account = [twitterAccounts objectAtIndex:0];
                                             appDelegate.twitterAccount = account;
                                         }
                                         dispatch_async(dispatch_get_main_queue(), ^{
                                             [self.tableView reloadData];
                                         });
                                     }
                                 }];
            }
        }
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    
    NSManagedObjectContext *context = [NSManagedObjectContext MR_contextForCurrentThread];
    Master *master = [Master MR_findFirstByAttribute:@"username" withValue:[[NSUserDefaults standardUserDefaults] valueForKey:@"username"] inContext:context];

    if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            NSString *text;
            if ([self.tagsArray count] == 0)
                text = @"Tags";
            else
                text = [self.tagsArray componentsJoinedByString:@", "];
            self.tagsLabel.text = text;
        }
    }
    if (indexPath.section == 2) {
        if (indexPath.row == 0) {
            self.facebookConfigureLabel = [[UILabel alloc] initWithFrame:CGRectMake(230, 11, 72, 21)];
            self.facebookConfigureLabel.text = @"enable";
            self.facebookConfigureLabel.textColor = [UIColor darkGrayColor];
            self.facebookConfigureLabel.backgroundColor = [UIColor clearColor];

            self.facebookSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
            
            cell.textLabel.text = @"Facebook";
            
            BOOL facebook = [master.facebookSharingOn boolValue];
            if (facebook) {
                cell.accessoryView = self.facebookSwitch;
            } else {
                [cell addSubview:self.facebookConfigureLabel];
            }
            
        } else if (indexPath.row == 1) {
            self.twitterConfigureLabel = [[UILabel alloc] initWithFrame:CGRectMake(230, 11, 72, 21)];
            self.twitterConfigureLabel.text = @"enable";
            self.twitterConfigureLabel.textColor = [UIColor darkGrayColor];
            self.twitterConfigureLabel.backgroundColor = [UIColor clearColor];
            
            self.twitterSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];

            cell.textLabel.text = @"Twitter";
            
            BOOL twitter = [master.twitterSharingOn boolValue];
            if (twitter) {
                cell.accessoryView = self.twitterSwitch;
            } else {
                [cell addSubview:self.twitterConfigureLabel];
            }
        }
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            return 45;
        }
        if (indexPath.row == 1) {
            return 118;
        }
    }
    if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            return [self getHeightOfTagsTextLabel] + 27;
        }
    }
    if (indexPath.section == 2) {
        if (indexPath.row == 0) {
            return 45;
        }
        if (indexPath.row == 1) {
            return 45;
        }
    }
    return 0;
}

#pragma mark - SDAddTagsViewController delegate methods

- (void)addTagsViewController:(SDAddTagsViewController *)addTagsViewController
         didFinishPickingTags:(NSArray *)tagUsersArray
{
    self.tagUsersArray = tagUsersArray;
    
    NSMutableArray *namesArray = [[NSMutableArray alloc] init];
    for (User *user in tagUsersArray) {
        [namesArray addObject:user.name];
    }
    self.tagsArray = namesArray;
    
    if ([tagUsersArray count] == 0)
        self.tagsLabel.textColor = [UIColor grayColor];
    else
        self.tagsLabel.textColor = [UIColor blackColor];
    
    float newHeight = [self getHeightOfTagsTextLabel];
    self.tagsLabel.frame = CGRectMake(self.tagsLabel.frame.origin.x,
                                      self.tagsLabel.frame.origin.y,
                                      self.tagsLabel.frame.size.width,
                                      newHeight);
    
    [self.tableView reloadData];
}

- (NSArray *)arrayOfAlreadySelectedTags
{
    if (!self.tagUsersArray)
        self.tagUsersArray = [[NSArray alloc] init];
    return self.tagUsersArray;
}

@end
