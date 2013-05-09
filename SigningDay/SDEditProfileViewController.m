//
//  SDEditProfileViewController.m
//  SigningDay
//
//  Created by Vytautas Gudaitis on 8/9/12.
//
//

#import "SDEditProfileViewController.h"
#import "Master.h"
#import "User.h"
#import "SDProfileService.h"
#import "MBProgressHUD.h"

@interface SDEditProfileViewController ()

@property (weak, nonatomic) IBOutlet UITextView *nameTextView;
@property (weak, nonatomic) IBOutlet UITextView *bioTextView;

- (void)loadData;
- (void)saveData;
- (void)checkServer;
- (void)backButtonPressed;
- (IBAction)submitButtonPressed;

@end

@implementation SDEditProfileViewController
@synthesize nameTextView;
@synthesize bioTextView;

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
    
    self.nameTextView.text = nil;
    self.bioTextView.text = nil;
    
    self.tableView.backgroundColor = [UIColor colorWithRed:140.0f/255.0f green:140.0f/255.0f blue:140.0f/255.0f alpha:1];
    
    UIImage *image = [UIImage imageNamed:@"back_nav_button.png"];
    CGRect frame = CGRectMake(0, 0, image.size.width, image.size.height);
    UIButton *button = [[UIButton alloc] initWithFrame:frame];
    [button setBackgroundImage:image forState:UIControlStateNormal];
    [button addTarget:self action:@selector(backButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithCustomView:button];
    self.navigationItem.leftBarButtonItem = barButton;
    
    [self loadData];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self loadData];
    [self checkServer];
}

- (void)backButtonPressed
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)submitButtonPressed
{
    [self.nameTextView resignFirstResponder];
    [self.bioTextView resignFirstResponder];
    
    NSString *username = [[NSUserDefaults standardUserDefaults] valueForKey:@"username"];
    Master *master = [Master MR_findFirstByAttribute:@"username" withValue:username];
    User *user = [User MR_findFirstByAttribute:@"identifier" withValue:master.identifier];
    if (![self.nameTextView.text isEqualToString:user.name] || ![self.bioTextView.text isEqualToString:user.bio]) {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        hud.labelText = @"Saving";
        
        [self saveData];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)checkServer
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    hud.labelText = @"Loading";
    
    NSString *username = [[NSUserDefaults standardUserDefaults] valueForKey:@"username"];
    Master *master = [Master MR_findFirstByAttribute:@"username" withValue:username];
    [SDProfileService getProfileInfoForUserIdentifier:master.identifier completionBlock:^{
        [MBProgressHUD hideAllHUDsForView:self.navigationController.view animated:YES];
        [self loadData];
    } failureBlock:^{
        [MBProgressHUD hideAllHUDsForView:self.navigationController.view animated:YES];
    }];
}

- (void)loadData
{
    NSString *username = [[NSUserDefaults standardUserDefaults] valueForKey:@"username"];
    Master *master = [Master MR_findFirstByAttribute:@"username" withValue:username];
    User *user = [User MR_findFirstByAttribute:@"identifier" withValue:master.identifier];
    if (user) {
        self.nameTextView.text = user.name;
        self.bioTextView.text = user.bio;
    }
}

- (void)saveData
{
    NSString *username = [[NSUserDefaults standardUserDefaults] valueForKey:@"username"];
    Master *master = [Master MR_findFirstByAttribute:@"username" withValue:username];
    if (master) {
        [SDProfileService postNewProfileFieldsForUserWithIdentifier:master.identifier name:self.nameTextView.text bio:self.bioTextView.text completionBlock:^{
            [MBProgressHUD hideAllHUDsForView:self.navigationController.view animated:YES];
            [self.navigationController popViewControllerAnimated:YES];
        } failureBlock:^{
            [MBProgressHUD hideAllHUDsForView:self.navigationController.view animated:YES];
        }];
    }
}

- (void)viewDidUnload
{
    [self setNameTextView:nil];
    [self setBioTextView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

#pragma mark - Table view delegate

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

@end
