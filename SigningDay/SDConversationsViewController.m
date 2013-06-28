//
//  SDConversationsViewController.m
//  SigningDay
//
//  Created by Vytautas Gudaitis on 7/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SDAppDelegate.h"
#import "Conversation.h"
#import "Message.h"
#import "User.h"
#import "SDChatService.h"
#import "SDConversationsViewController.h"
#import "PSYBlockTimer.h"
#import "SDConversationCell.h"
#import "AFNetworking.h"
#import "SDConversationViewController.h"
#import "SDSettingsViewController.h"
#import "SDTabBarController.h"
#import "ShadowedTableView.h"
#import "SDLoginService.h"
#import "MBProgressHUD.h"
#import "SDImageService.h"
#import "UIImage+Crop.h"
#import "SDFollowingService.h"

@interface SDConversationsViewController () <SDSettingsViewControllerDelegate>

@property (weak, nonatomic) IBOutlet ShadowedTableView *tableView;

@property (strong, nonatomic) NSArray *conversations;
@property BOOL firstLoad;
@property (nonatomic, assign) int totalMessages;
@property (nonatomic, assign) int currentMessagesPage;


- (void)reload;
- (void)checkServer;

@end

@implementation SDConversationsViewController

@synthesize tableView = _tableView;
@synthesize delegate = _delegate;
@synthesize conversations = _conversations;
@synthesize firstLoad = _firstLoad;
@synthesize totalMessages = _totalMessages;
@synthesize currentMessagesPage = _currentMessagesPage;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"Conversations";
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkServer) name:kSDPushNotificationReceivedWhileInBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkServer) name:kSDPushNotificationReceivedWhileInForegroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userDidLogout) name:kSDLoginServiceUserDidLogoutNotification object:nil];
    
    UIImage *image = [UIImage imageNamed:@"settings_button.png"];
    CGRect frame = CGRectMake(0, 0, image.size.width, image.size.height);
    UIButton *button = [[UIButton alloc] initWithFrame:frame];
    [button setBackgroundImage:image forState:UIControlStateNormal];
    [button addTarget:self action:@selector(settingsPressed) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithCustomView:button];
    self.navigationItem.leftBarButtonItem = barButton;
    
    image = [UIImage imageNamed:@"new_message_button.png"];
    frame = CGRectMake(0, 0, image.size.width, image.size.height);
    button = [[UIButton alloc] initWithFrame:frame];
    [button setBackgroundImage:image forState:UIControlStateNormal];
    [button addTarget:self action:@selector(newMessagePressed) forControlEvents:UIControlEventTouchUpInside];
    barButton = [[UIBarButtonItem alloc] initWithCustomView:button];
    self.navigationItem.rightBarButtonItem = barButton;
    
    UIImage *bgImage;
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
    if (screenSize.height == 480) {
        bgImage = [UIImage imageNamed:@"conversations_bg.png"];
    }
    if (screenSize.height == 568) {
        bgImage = [UIImage imageNamed:@"conversations_bg-568h@2x.png"];
    }
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:bgImage];
    [imageView setFrame:self.tableView.bounds];
    [self.tableView setBackgroundView:imageView];
    [self.tableView setBackgroundColor:[UIColor clearColor]];
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.firstLoad = YES;
    self.delegate = (SDTabBarController *)self.tabBarController;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillAppear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kSDTabBarShouldShowNotification object:nil];
    [SDFollowingService removeFollowing:YES andFollowed:YES];
    
    _currentMessagesPage = _totalMessages = 0;
    if (self.firstLoad) {
        [MBProgressHUD hideAllHUDsForView:self.navigationController.view animated:YES];
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        hud.labelText = @"Updating conversations";
    }
    [self checkServer];
}

- (void)loadMoreData
{
    _currentMessagesPage++;
    [self checkServer];
}

- (void)checkServer
{
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"loggedIn"]) {
        
        [SDChatService getConversationsForPage:_currentMessagesPage withSuccessBlock:^(int totalConversationCount) {
            _totalMessages = totalConversationCount;
            
            //if there are more conversations, we need to download them
            if ((_currentMessagesPage+1)*kMaxItemsPerPage < _totalMessages )
            {
                [self loadMoreData];
            }
            else {
                if (self.firstLoad) {
                    self.firstLoad = NO;
                }
                //delete old messages
                [SDChatService deleteMarkedConversations];
                
                [self reload];
                [MBProgressHUD hideAllHUDsForView:self.navigationController.view animated:YES];
            }
         
        } failureBlock:^{
            [MBProgressHUD hideAllHUDsForView:self.navigationController.view animated:YES];
        }];
    }
}

- (void)reload
{
    NSString *string = @"";
    if ([[NSUserDefaults standardUserDefaults] valueForKey:@"username"])
        string = [[NSUserDefaults standardUserDefaults] valueForKey:@"username"];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"master.username like %@", string];
    self.conversations = [Conversation MR_findAllSortedBy:@"lastMessageDate" ascending:NO withPredicate:predicate inContext:[NSManagedObjectContext MR_contextForCurrentThread]];
    [self.tableView reloadData];
}

- (void)settingsPressed
{
    SDNavigationController *settingsNavigationViewController = [[UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil] instantiateViewControllerWithIdentifier:@"SettingsNavigationViewController"];
    settingsNavigationViewController.myDelegate = self;
    [self presentModalViewController:settingsNavigationViewController animated:YES];
}

- (void)newMessagePressed
{
    SDNavigationController *newConversationNavigationController = [[UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil] instantiateViewControllerWithIdentifier:@"NewConversationNavigationController"];
    newConversationNavigationController.myDelegate = self;
    [self presentModalViewController:newConversationNavigationController animated:YES];
}

- (void)viewDidUnload
{
    [self setTableView:nil];
    [super viewDidUnload];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqual:@"PushConversationViewController"]) {
        SDConversationViewController *conversationViewController = (SDConversationViewController *)[segue destinationViewController];
        Conversation *conversation = [self.conversations objectAtIndex:[[self.tableView indexPathForSelectedRow] row]];
        conversationViewController.conversation = conversation;
    }
}

- (void)userDidLogout
{
    self.conversations = nil;
    self.firstLoad = YES;
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    int count = [self.tableView numberOfRowsInSection:0];
    for (int i = 0; i < count; i++) {
        SDConversationCell *cell = (SDConversationCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
        cell.userImageView.image = nil;
    }
}

#pragma mark - UITableView data source and delegate methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    int result = [self.conversations count];
    return result;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 68;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"ConversationCell";
    
    SDConversationCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[SDConversationCell alloc]
                initWithStyle:UITableViewCellStyleDefault
                reuseIdentifier:CellIdentifier];
    } else {
        [cell.userImageView cancelImageRequestOperation];
    }
    
    Conversation *conversation = [self.conversations objectAtIndex:indexPath.row];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    NSDateComponents *otherDay = [[NSCalendar currentCalendar] components:NSEraCalendarUnit|NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:conversation.lastMessageDate];
    NSDateComponents *today = [[NSCalendar currentCalendar] components:NSEraCalendarUnit|NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:[NSDate date]];
    if ([today day] == [otherDay day] &&
        [today month] == [otherDay month] &&
        [today year] == [otherDay year] &&
        [today era] == [otherDay era]) {
        dateFormatter.dateFormat = @"hh:mm a";
    } else {
        dateFormatter.dateFormat = @"MMM dd";
    }
    
    cell.dateLabel.text = [dateFormatter stringFromDate:conversation.lastMessageDate];
    cell.messageTextLabel.text = conversation.lastMessageText;
    
    NSArray *users = [conversation.users allObjects];
    NSMutableArray *usernames = [[NSMutableArray alloc] init];
    NSString *masterUsername = [[NSUserDefaults standardUserDefaults] valueForKey:@"username"];
    for (User *user in users) {
        if (![user.username isEqual:masterUsername])
            [usernames addObject:user.name];
    }
    
    NSArray *sortedUsernames = [usernames sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    cell.usernameLabel.text = [sortedUsernames componentsJoinedByString:@", "];
    
    User *conversationUser;
    if ([users count] == 1)
        conversationUser = [users objectAtIndex:0];
    else
        conversationUser = conversation.author;
    
    
    cell.userImageView.image = nil;
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:conversationUser.avatarUrl]];
    [cell.userImageView setImageWithURLRequest:request
                              placeholderImage:nil
                                       success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                           dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                                               UIImage *anImage = [image imageByScalingAndCroppingForSize:CGSizeMake(50 * [UIScreen mainScreen].scale, 50 * [UIScreen mainScreen].scale)];
                                               dispatch_async(dispatch_get_main_queue(), ^{
                                                   SDConversationCell *myCell = (SDConversationCell *)[self.tableView cellForRowAtIndexPath:indexPath];
                                                   myCell.userImageView.image = anImage;
                                               });
                                           });
                                       } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                           //
                                       }];
    
    BOOL isRead = [conversation.isRead boolValue];
    if (!isRead)
        cell.backgroundView.backgroundColor = [UIColor colorWithRed:236.0f/255.0f green:232.0f/255.0f blue:208.0f/255.0f alpha:1];
    else
        cell.backgroundView.backgroundColor = [UIColor whiteColor];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
//    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - SDNavigationController delegate methods

- (void)navigationControllerWantsToClose:(SDNavigationController *)navigationController
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - SDNewConversationViewController delegate methods

- (void)newConversationViewController:(SDNewConversationViewController *)newConversationViewController didFinishPickingUser:(User *)user
{
    [self dismissModalViewControllerAnimated:YES];
    
    NSManagedObjectContext *context = [NSManagedObjectContext MR_contextForCurrentThread];
    Conversation *conversation = [Conversation MR_createInContext:context];
    [conversation addUsersObject:user];
    [context MR_save];
    
    SDConversationViewController *conversationViewController = [[UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil] instantiateViewControllerWithIdentifier:@"ConversationViewController"];
    conversationViewController.conversation = conversation;
    conversationViewController.isNewConversation = YES;
    
    [self.navigationController pushViewController:conversationViewController animated:YES];
    [[NSNotificationCenter defaultCenter] postNotificationName:kSDTabBarShouldHideNotification object:nil];
}

#pragma mark - SDSettingsViewController delegate methods

- (void)settingsViewControllerDidLogOut:(SDSettingsViewController *)settingsViewController
{
    [self dismissViewControllerAnimated:YES completion:^{
        [self.delegate conversationsViewControllerSettingsDidLogout:self];
    }];
}


@end















