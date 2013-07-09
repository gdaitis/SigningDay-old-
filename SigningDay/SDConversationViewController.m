//
//  SDConversationViewController.m
//  SigningDay
//
//  Created by Vytautas Gudaitis on 7/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SDConversationViewController.h"
#import "SDAppDelegate.h"
#import "Message.h"
#import "User.h"
#import "SDChatService.h"
#import "NSString+Additions.h"
#import "SDMessageCell.h"
#import "ShadowedTableView.h"
#import "MBProgressHUD.h"
#import "SDImageService.h"
#import "PSYBlockTimer.h"
#import "UIImage+Crop.h"
#import "SDTabBarController.h"
#import "AFNetworking.h"
#import "SDNewConversationViewController.h"

#define VIEW_WIDTH    self.containerView.frame.size.width
#define VIEW_HEIGHT    self.containerView.frame.size.height

#define RESET_CHAT_BAR_HEIGHT    SET_CHAT_BAR_HEIGHT(kChatBarHeight1)
#define EXPAND_CHAT_BAR_HEIGHT    SET_CHAT_BAR_HEIGHT(kChatBarHeight4)
#define    SET_CHAT_BAR_HEIGHT(HEIGHT)\
CGRect chatContentFrame = self.tableView.frame;\
chatContentFrame.size.height = VIEW_HEIGHT - HEIGHT;\
[UIView beginAnimations:nil context:NULL];\
[UIView setAnimationDuration:0.1f];\
self.tableView.frame = chatContentFrame;\
self.chatBar.frame = CGRectMake(self.chatBar.frame.origin.x, chatContentFrame.size.height,\
VIEW_WIDTH, HEIGHT);\
[UIView commitAnimations]

#define BAR_BUTTON(TITLE, SELECTOR) [[UIBarButtonItem alloc] initWithTitle:TITLE\
style:UIBarButtonItemStylePlain target:self action:SELECTOR]

#define ClearConversationButtonIndex 0

static CGFloat const kMessageFontSize   = 14.0f;
static CGFloat const kMessageTextWidth  = 242.0f;
static CGFloat const kContentHeightMax  = 104.0f;
static CGFloat const kChatBarHeight1    = 59.0f;
static CGFloat const kChatBarHeight4    = 104.0f;

@interface SDConversationViewController ()

@property (nonatomic, weak) IBOutlet ShadowedTableView *tableView;
@property (nonatomic, weak) IBOutlet UIImageView *chatBar;
@property (nonatomic, weak) IBOutlet UIButton *sendButton;
@property (nonatomic, weak) IBOutlet UITextView *enterMessageTextView;
@property (weak, nonatomic) IBOutlet UIImageView *textViewBackgroundImageView;
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (nonatomic, strong) NSArray *messages;
@property (nonatomic, assign) CGFloat previousContentHeight;
@property BOOL firstLoad;

@property (nonatomic, assign) int totalMessages;
@property (nonatomic, assign) int currentMessagesPage;

- (void)checkServer;
- (void)reload;
- (void)clearChatInput;
- (void)scrollToBottomAnimated:(BOOL)animated;
- (void)resizeViewWithOptions:(NSDictionary *)options;
- (void)enableSendButton;
- (void)disableSendButton;
- (void)resetSendButton;

@end

@implementation SDConversationViewController

@synthesize tableView = _tableView;
@synthesize enterMessageTextView = _enterMessageTextView;
@synthesize textViewBackgroundImageView = _textViewBackgroundImageView;
@synthesize conversation = _conversation;
@synthesize messages = _messages;
@synthesize chatBar = _chatBar;
@synthesize previousContentHeight = _previousContentHeight;
@synthesize sendButton = _sendButton;
@synthesize firstLoad = _firstLoad;
@synthesize containerView = _containerView;
@synthesize isNewConversation = _isNewConversation;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    NSMutableArray *viewControllers = [NSMutableArray arrayWithArray:self.navigationController.viewControllers];
    for (UIViewController *viewController in self.navigationController.viewControllers) {
        if ([viewController isKindOfClass:[SDNewConversationViewController class]]) {
            [viewControllers removeObject:viewController];
            break;
        }
    }
    
    self.navigationController.viewControllers = [NSArray arrayWithArray:viewControllers];
    
    self.firstLoad = YES;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkServer) name:kSDPushNotificationReceivedWhileInBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkServer) name:kSDPushNotificationReceivedWhileInForegroundNotification object:nil];
    
    UIImage *image = [UIImage imageNamed:@"back_nav_button.png"];
    CGRect frame = CGRectMake(0, 0, image.size.width, image.size.height);
    UIButton *button = [[UIButton alloc] initWithFrame:frame];
    [button setBackgroundImage:image forState:UIControlStateNormal];
    [button addTarget:self.navigationController action:@selector(popViewControllerAnimated:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithCustomView:button];
    self.navigationItem.leftBarButtonItem = barButton;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification object:nil];
    
    
    self.tableView.clearsContextBeforeDrawing = NO;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    UIGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeKeyboard)];
    [self.tableView addGestureRecognizer:recognizer];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"chat_bg.png"]];
    [imageView setFrame:self.tableView.bounds];
    [self.tableView setBackgroundView:imageView];
    [self.tableView setBackgroundColor:[UIColor clearColor]];
    
    self.chatBar.frame = CGRectMake(0.0f, self.containerView.frame.size.height-kChatBarHeight1, self.containerView.frame.size.width, kChatBarHeight1);
    self.chatBar.clearsContextBeforeDrawing = NO;
    self.chatBar.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth;
    self.chatBar.userInteractionEnabled = YES;
    
    self.enterMessageTextView.frame = CGRectMake(9, 13, 217, 32);
    
    self.textViewBackgroundImageView.image = [[UIImage imageNamed:@"conversation_text_view_bg.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(8, 6, 8, 6)];
    self.textViewBackgroundImageView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    self.textViewBackgroundImageView.frame = self.enterMessageTextView.frame;
    
    self.enterMessageTextView.delegate = self;
    self.enterMessageTextView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    self.enterMessageTextView.scrollEnabled = NO; // not initially
    self.enterMessageTextView.clearsContextBeforeDrawing = NO;
    self.enterMessageTextView.font = [UIFont systemFontOfSize:kMessageFontSize];
    self.enterMessageTextView.dataDetectorTypes = UIDataDetectorTypeAll;
    self.enterMessageTextView.backgroundColor = [UIColor clearColor];
    self.previousContentHeight = self.enterMessageTextView.contentSize.height;
    
    [self.chatBar addSubview:self.textViewBackgroundImageView];
    [self.chatBar addSubview:self.enterMessageTextView];
    
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 1)];
    line.backgroundColor = [UIColor blackColor];
    line.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin;
    line.clearsContextBeforeDrawing = NO;
    [self.chatBar addSubview:line];
    
    self.sendButton.clearsContextBeforeDrawing = NO;
    self.sendButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    [self.sendButton addTarget:self action:@selector(sendMessage) forControlEvents:UIControlEventTouchUpInside];
    self.sendButton.frame = CGRectMake(self.sendButton.frame.origin.x, 15, self.sendButton.frame.size.width, self.sendButton.frame.size.height);
    [self resetSendButton]; // disable initially
    [self.chatBar addSubview:self.sendButton];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] postNotificationName:kSDTabBarShouldHideNotification object:nil];
    [self scrollToBottomAnimated:NO];
    
    //reset messages
    _currentMessagesPage = _totalMessages = 0;
    [self checkServer];
    if (self.firstLoad) {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        hud.labelText = @"Updating chat";
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (!self.isNewConversation && ![self.conversation.isRead boolValue]) {
        [SDChatService setConversationToRead:self.conversation completionBlock:^{
        }];
    }
    if (self.isNewConversation)
        [self.enterMessageTextView becomeFirstResponder];
}

- (void)loadMoreData
{
    _currentMessagesPage++;
    [self checkServer];
}

- (void)checkServer
{
    if (self.conversation.identifier) {
        
        [SDChatService getMessagesWithPageNumber:_currentMessagesPage fromConversation:self.conversation success:^(int totalMessagesCount) {

            _totalMessages = totalMessagesCount;
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
                [SDChatService deleteMarkedMessagesForConversation:self.conversation];
                [self reload];
                [MBProgressHUD hideAllHUDsForView:self.navigationController.view animated:YES];
                [self scrollToBottomAnimated:YES];
            }
            
        } failure:^{
            [MBProgressHUD hideAllHUDsForView:self.navigationController.view animated:YES];
        }];
    } else {
        self.firstLoad = NO;
    }
}

- (void)reload
{
    NSArray *unsortedMessages = [self.conversation.messages allObjects];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"date" ascending:YES];
    self.messages = [unsortedMessages sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    
    [self.tableView reloadData];
}

- (void)sendMessage
{
    NSString *rightTrimmedMessage = [self.enterMessageTextView.text stringByTrimmingTrailingWhitespaceAndNewlineCharacters];
    
    if (rightTrimmedMessage.length == 0) {
        [self clearChatInput];
        return;
    }
    
    [self clearChatInput];
    
    if (!self.conversation.identifier) {
        NSString *username = [(User *)[[self.conversation.users allObjects] objectAtIndex:0] username];
        [SDChatService startNewConversationWithUsername:username text:rightTrimmedMessage completionBlock:^(NSString *identifier) {
            self.conversation.identifier = identifier;
            [[NSManagedObjectContext MR_contextForCurrentThread] MR_save];
            
            [self checkServer];
        }];
    } else {
        [SDChatService sendMessage:rightTrimmedMessage forConversation:self.conversation completionBlock:^{
            [self checkServer];
        }];
    }
    
    [self scrollToBottomAnimated:YES];
}

- (void)clearChatInput
{
    self.enterMessageTextView.text = @"";
    if (self.previousContentHeight > 22.0f) {
        RESET_CHAT_BAR_HEIGHT;
        [self scrollToBottomAnimated:YES];
    }
}

- (void)scrollToBottomAnimated:(BOOL)animated
{
    NSInteger bottomRow = [self.messages count] - 1;
    if (bottomRow >= 0) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:bottomRow inSection:0];
        [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:animated];
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [self.enterMessageTextView resignFirstResponder];
    [super viewDidDisappear:animated];
}

- (void)viewDidUnload
{
    [self setTableView:nil];
    [self setEnterMessageTextView:nil];
    [self setChatBar:nil];
    [self setSendButton:nil];
    [self setTextViewBackgroundImageView:nil];
    [self setContainerView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillShowNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
}

- (void)didReceiveMemoryWarning
{
    int count = [self.tableView numberOfRowsInSection:0];
    for (int i = 0; i < count; i++) {
        SDMessageCell *cell = (SDMessageCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
        cell.userImageView.image = nil;
    }
}

- (void)setConversation:(Conversation *)conversation
{
    _conversation = conversation;
    
    NSArray *users = [conversation.users allObjects];
    NSMutableArray *usernames = [[NSMutableArray alloc] init];
    NSString *masterUsername = [[NSUserDefaults standardUserDefaults] valueForKey:@"username"];
    for (User *user in users) {
        if (![user.username isEqual:masterUsername])
            [usernames addObject:user.name];
    }
    NSArray *sortedUsernames = [usernames sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    self.title = [sortedUsernames componentsJoinedByString:@", "];
}

#pragma mark - Keyboard methods

- (void)keyboardWillShow:(NSNotification *)notification
{
    [self resizeViewWithOptions:[notification userInfo]];
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    [self resizeViewWithOptions:[notification userInfo]];
}

- (void)resizeViewWithOptions:(NSDictionary *)options
{
    NSTimeInterval animationDuration;
    UIViewAnimationCurve animationCurve;
    CGRect keyboardEndFrame;
    [[options objectForKey:UIKeyboardAnimationCurveUserInfoKey] getValue:&animationCurve];
    [[options objectForKey:UIKeyboardAnimationDurationUserInfoKey] getValue:&animationDuration];
    [[options objectForKey:UIKeyboardFrameEndUserInfoKey] getValue:&keyboardEndFrame];
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationCurve:animationCurve];
    [UIView setAnimationDuration:animationDuration];
    CGRect viewFrame = self.containerView.frame;
    
    CGRect keyboardFrameEndRelative = [self.view convertRect:keyboardEndFrame fromView:nil];
    
    viewFrame.size.height =  keyboardFrameEndRelative.origin.y;
    self.containerView.frame = viewFrame;
    [UIView commitAnimations];
    
    [self scrollToBottomAnimated:YES];
}

- (void)closeKeyboard
{
    [self.enterMessageTextView resignFirstResponder];
}

#pragma mark ChatViewController

- (void)enableSendButton
{
    if (self.sendButton.enabled == NO) {
        self.sendButton.enabled = YES;
    }
}

- (void)disableSendButton
{
    if (self.sendButton.enabled == YES) {
        [self resetSendButton];
    }
}

- (void)resetSendButton
{
    self.sendButton.enabled = NO;
}

#pragma mark - UITableView data source and delegate methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.messages count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"MessageCell";
    
    SDMessageCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[SDMessageCell alloc]
                initWithStyle:UITableViewCellStyleDefault
                reuseIdentifier:CellIdentifier];
    } else {
        [cell.userImageView cancelImageRequestOperation];
    }
    
    Message *message = [self.messages objectAtIndex:indexPath.row];
    cell.message = message;
    cell.usernameLabel.text = message.user.name;
    cell.messageTextLabel.text = message.text;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    NSDateComponents *otherDay = [[NSCalendar currentCalendar] components:NSEraCalendarUnit|NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:message.date];
    NSDateComponents *today = [[NSCalendar currentCalendar] components:NSEraCalendarUnit|NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:[NSDate date]];
    if ([today day] == [otherDay day] &&
        [today month] == [otherDay month] &&
        [today year] == [otherDay year] &&
        [today era] == [otherDay era]) {
        dateFormatter.dateFormat = @"hh:mm a";
    } else {
        dateFormatter.dateFormat = @"MMM dd";
    }
    
    cell.dateLabel.text = [dateFormatter stringFromDate:message.date];
    
    NSString *myUsername = [[NSUserDefaults standardUserDefaults] valueForKey:@"username"];
    if ([message.user.username isEqual:myUsername]) {
        cell.backgroundView.backgroundColor = [UIColor colorWithRed:223.0f/255.0f green:223.0f/255.0f blue:223.0f/255.0f alpha:1];
    } else {
        cell.backgroundView.backgroundColor = [UIColor whiteColor];
    }
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:message.user.avatarUrl]];
    [cell.userImageView setImageWithURLRequest:request
                              placeholderImage:nil
                                       success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                           SDMessageCell *myCell = (SDMessageCell *)[self.tableView cellForRowAtIndexPath:indexPath];
                                           myCell.userImageView.image = image;
                                       } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                           //
                                       }];
    
    [cell setNeedsLayout];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Message *message = [self.messages objectAtIndex:indexPath.row];
    
    CGSize size = [message.text sizeWithFont:[UIFont fontWithName:@"Arial" size:13]
                           constrainedToSize:CGSizeMake(kMessageTextWidth, CGFLOAT_MAX)
                               lineBreakMode:UILineBreakModeWordWrap];
    CGFloat height = size.height + 30 + 13;
    if (height < 68) {
        height = 68;
    }
    return height;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark UITextViewDelegate

- (void)textViewDidChange:(UITextView *)textView
{
    CGFloat contentHeight = textView.contentSize.height;
    NSString *rightTrimmedText = @"";
    
    if ([textView hasText]) {
        rightTrimmedText = [textView.text stringByTrimmingTrailingWhitespaceAndNewlineCharacters];
        
        if (contentHeight != self.previousContentHeight) {
            if (contentHeight <= kContentHeightMax) {
                if (contentHeight == 32) {
                    RESET_CHAT_BAR_HEIGHT;
                } else {
                    CGFloat chatBarHeight = contentHeight + 16;
                    SET_CHAT_BAR_HEIGHT(chatBarHeight);
                }
                if (self.previousContentHeight > kContentHeightMax) {
                    textView.scrollEnabled = NO;
                }
                textView.contentOffset = CGPointMake(0.0f, 6.0f);
                [self scrollToBottomAnimated:YES];
            } else if (self.previousContentHeight <= kContentHeightMax) {
                textView.scrollEnabled = YES;
                textView.contentOffset = CGPointMake(0.0f, contentHeight-63.0f);
                if (self.previousContentHeight < kContentHeightMax) {
                    EXPAND_CHAT_BAR_HEIGHT;
                    [self scrollToBottomAnimated:YES];
                }
            }
        }
    } else {
        if (self.previousContentHeight > 22.0f) {
            RESET_CHAT_BAR_HEIGHT;
            if (self.previousContentHeight > kContentHeightMax) {
                textView.scrollEnabled = NO;
            }
        }
    }
    
    if (rightTrimmedText.length > 0) {
        [self enableSendButton];
    } else {
        [self disableSendButton];
    }
    
    self.previousContentHeight = contentHeight;
}


@end
