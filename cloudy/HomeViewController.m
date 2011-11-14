//
//  HomeViewController.m
//  cloudy
//
//  Created by T. Binkowski on 11/11/11.
//  Copyright (c) 2011 Argonne National Laboratory. All rights reserved.
//

#import "HomeViewController.h"
#import <MessageUI/MessageUI.h>

@implementation HomeViewController
@synthesize password;
@synthesize score;
@synthesize userName;

/*******************************************************************************
 * @method      initWithNibName:bundle:
 * @abstract    <# abstract #>
 * @description <# description #>
 *******************************************************************************/
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"Sign In";
        UIBarButtonItem *item = [[UIBarButtonItem alloc]   
                                 initWithBarButtonSystemItem:UIBarButtonSystemItemAction  
                                 target:self   
                                 action:@selector(displayComposerSheet)];  
        self.navigationItem.rightBarButtonItem = item;  
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(theKeyboardAppeared:)
                                                 name:UIKeyboardDidShowNotification 
                                               object:self.view.window];
}

- (void)viewDidUnload
{
    [self setUserName:nil];
    [self setPassword:nil];
    [self setScore:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - UITextFieldDelegates
/*******************************************************************************
 * @method      theKeyboardAppeared:
 * @abstract    <# abstract #>
 * @description <# description #>
 *******************************************************************************/
- (void)theKeyboardAppeared:(id)sender
{ 
    NSLog(@"Keyboard Appeared");
}

/*******************************************************************************
 * @method      textFieldShouldReturn:
 * @abstract    Return button is hit
 * @description <# description #>
 *******************************************************************************/
-(BOOL)textFieldShouldReturn:(UITextField*)sender
{
    [sender resignFirstResponder];
    return YES;
}
/*******************************************************************************
 * @method      textFieldDidEndEditing
 * @abstract    <# abstract #>
 * @description <# description #>
 *******************************************************************************/
- (void)textFieldDidEndEditing:(UITextField *)sender
{
    if (sender == userName) {
        NSLog(@"UserName");
        [[NSUserDefaults standardUserDefaults] setObject:sender.text forKey:@"Username"];
    } else if (sender == password) {
        NSLog(@"Password");
        [[NSUserDefaults standardUserDefaults] setObject:sender.text forKey:@"Password"];
    } else if (sender == score) {
        NSLog(@"Score");
        NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
        [self postData:[userDefault objectForKey:@"Username"] withScore:sender.text];
    }
    NSLog(@"String:%@",sender.text);
    NSLog(@"Done being first responder");
} 

#pragma mark - Get/Post Data to Server
/*******************************************************************************
 * @method      getData
 * @abstract    <# abstract #>
 * @description <# description #>
 *******************************************************************************/
- (void)getData
{
    NSURL *gae = [NSURL URLWithString:@"http://localhost:8080/getscores/"];
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        NSError *error;
        NSData* data = [NSData dataWithContentsOfURL:gae];
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
        NSLog(@"Data:%@",json);
    });
}

/*******************************************************************************
 * @method      postData
 * @abstract    <# abstract #>
 * @description <# description #>
 *******************************************************************************/
- (void)postData:(NSString*)theUsername withScore:(NSString*)theScore
{
    NSString *udid = [[UIDevice currentDevice] uniqueIdentifier];
    NSString *params = [NSString stringWithFormat:@"username=%@&udid=%@&score=%@",theUsername,udid,theScore];
    
    NSMutableURLRequest* post = [NSMutableURLRequest requestWithURL: [NSURL URLWithString:@"http://localhost:8080/postscores/"]];

    [post setHTTPMethod: @"POST"];
    [post setHTTPBody: [[[NSString alloc] initWithString:params] dataUsingEncoding: NSASCIIStringEncoding]];
    [NSURLConnection connectionWithRequest:post delegate:self];
}
/*******************************************************************************
 * @method      sendButton:
 * @abstract    Send a request to the server for the players
 * @description <# description #>
 *******************************************************************************/
- (IBAction)sendButton:(id)sender {
    NSLog(@"Send Button");
    [self getData];
}

#pragma mark - Send SMS Message
/*******************************************************************************
 * @method          displayComposerSheet
 * @abstract        This will not work in the simulator
 * @description     <# Description #>
 ******************************************************************************/
-(void)displayComposerSheet 
{
    NSLog(@"SMS fired");
    // This doesn't work in the simulator
    /*
    MFMessageComposeViewController *picker = [[MFMessageComposeViewController alloc] init];
    picker.messageComposeDelegate = self;
    picker.recipients = [NSArray arrayWithObject:@"123456789"];   // Phone numbers
    picker.body = @"A message";
    [self presentModalViewController:picker animated:YES];
     */
}

/*******************************************************************************
 * @method          messageComposeViewController
 * @abstract        <# Abstract #>
 * @description     <# Description #>
 ******************************************************************************/
- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result {
    switch (result) {
        case MessageComposeResultCancelled:
            NSLog(@"Result: canceled");
            break;
        case MessageComposeResultSent:
            NSLog(@"Result: sent");
            break;
        case MessageComposeResultFailed:
            NSLog(@"Result: failed");
            break;
        default:
            NSLog(@"Result: not sent");
            break;
    }
    [self dismissModalViewControllerAnimated:YES];
}
@end
