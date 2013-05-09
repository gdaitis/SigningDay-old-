//
//  SDAddTagsViewController.m
//  SigningDay
//
//  Created by Vytautas Gudaitis on 8/30/12.
//
//

#import "SDAddTagsViewController.h"
#import "SDNavigationController.h"
#import "SDLoginService.h"
#import "Master.h"
#import "SDChatService.h"
#import "User.h"
#import "SDAddTagsCell.h"

@interface SDAddTagsViewController () <UISearchDisplayDelegate, UISearchBarDelegate>

@property (nonatomic, strong) NSArray *searchResults;
@property (nonatomic, strong) NSMutableArray *selectedTags;
@property (nonatomic, strong) UIBarButtonItem *doneButtonItem;

- (void)filterContentForSearchText:(NSString*)searchText;
- (void)checkDoneButton;

@end

@implementation SDAddTagsViewController

@synthesize searchResults = _searchResults;
@synthesize delegate = _delegate;
@synthesize selectedTags = _selectedTags;
@synthesize doneButtonItem = _doneButtonItem;

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
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userDidLogout) name:kSDLoginServiceUserDidLogoutNotification object:nil];
    
    SDNavigationController *navigationController = (SDNavigationController *)self.navigationController;
    self.delegate = (id <SDAddTagsViewControllerDelegate>)navigationController.myDelegate;
    
    UIImage *image = [UIImage imageNamed:@"x_button_yellow.png"];
    CGRect frame = CGRectMake(0, 0, image.size.width, image.size.height);
    UIButton *button = [[UIButton alloc] initWithFrame:frame];
    [button setBackgroundImage:image forState:UIControlStateNormal];
    [button addTarget:self action:@selector(cancelButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithCustomView:button];
    self.navigationItem.leftBarButtonItem = barButton;
    
    image = [UIImage imageNamed:@"done_button.png"];
    frame = CGRectMake(0, 0, image.size.width, image.size.height);
    button = [[UIButton alloc] initWithFrame:frame];
    [button setBackgroundImage:image forState:UIControlStateNormal];
    [button addTarget:self action:@selector(doneButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    self.doneButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    self.navigationItem.rightBarButtonItem = self.doneButtonItem;
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"chat_bg.png"]];
    [imageView setFrame:self.tableView.bounds];
    [self.tableView setBackgroundView:imageView];
    [self.tableView setBackgroundColor:[UIColor clearColor]];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [self filterContentForSearchText:@""];
    [SDChatService getListOfFollowingWithCompletionBlock:^{
        [self filterContentForSearchText:@""];
    }];
    
    self.selectedTags = [[NSMutableArray alloc] init];
    [self checkDoneButton];
}

- (void)userDidLogout
{
    self.searchResults = nil;
}

- (void)filterContentForSearchText:(NSString*)searchText
{
    self.searchResults = nil;
    NSString *username = [[NSUserDefaults standardUserDefaults] valueForKey:@"username"];
    NSPredicate *masterUsernamePredicate = [NSPredicate predicateWithFormat:@"followedBy.username like %@", username];
    if ([searchText isEqual:@""]) {
        self.searchResults = [User MR_findAllSortedBy:@"name" ascending:YES withPredicate:masterUsernamePredicate];
    } else {
        NSPredicate *usernameSearchPredicate = [NSPredicate predicateWithFormat:@"name contains[cd] %@", searchText];
        NSArray *predicatesArray = [NSArray arrayWithObjects:masterUsernamePredicate, usernameSearchPredicate, nil];
        NSPredicate *predicate = [NSCompoundPredicate andPredicateWithSubpredicates:predicatesArray];
        self.searchResults = [User MR_findAllSortedBy:@"name" ascending:YES withPredicate:predicate];
    }
    [self.tableView reloadData];
}

- (void)cancelButtonPressed
{
    [self dismissModalViewControllerAnimated:YES];
}

- (void)doneButtonPressed
{
    [self.delegate addTagsViewController:self didFinishPickingTags:self.selectedTags];
    
    [self dismissModalViewControllerAnimated:YES];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)checkDoneButton
{
    if ([self.selectedTags count] == 0 && [[self.delegate arrayOfAlreadySelectedTags] count] == 0)
        self.doneButtonItem.enabled = NO;
    else
        self.doneButtonItem.enabled = YES;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.searchResults count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SDAddTagsCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AddTagsCell"];
    if (cell == nil) {
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"SDAddTagsCell" owner:nil options:nil];
        for (id currentObject in topLevelObjects) {
            if ([currentObject isKindOfClass:[UITableViewCell class]]) {
                cell = (SDAddTagsCell *) currentObject;
                break;
            }
        }
    }
    
    cell.userImageView.image = nil;
    
    User *user = [self.searchResults objectAtIndex:indexPath.row];
    
    for (User *tagUser in [self.delegate arrayOfAlreadySelectedTags]) {
        if ([tagUser.identifier isEqualToNumber:user.identifier]) {
            cell.isChecked = YES;
        }
    }
    
    cell.userTitleLabel.text = user.name;
    cell.userAvatarUrlString = user.avatarUrl;
    
    [self checkDoneButton];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 48;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    
    User *user = [self.searchResults objectAtIndex:indexPath.row];
    
    SDAddTagsCell *cell = (SDAddTagsCell *)[tableView cellForRowAtIndexPath:indexPath];
    if (cell.isChecked) {
        cell.isChecked = NO;
        [self.selectedTags removeObject:user];
    } else {
        cell.isChecked = YES;
        [self.selectedTags addObject:user];
    }
    
    [self checkDoneButton];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - UISearchBar delegate methods

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    [self filterContentForSearchText:searchText];
}

@end
