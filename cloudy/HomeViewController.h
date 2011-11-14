//
//  HomeViewController.h
//  cloudy
//
//  Created by T. Binkowski on 11/11/11.
//  Copyright (c) 2011 Argonne National Laboratory. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>

@interface HomeViewController : UIViewController <UITextFieldDelegate,MFMessageComposeViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UITextField *userName;
@property (weak, nonatomic) IBOutlet UITextField *password;
@property (weak, nonatomic) IBOutlet UITextField *score;

- (IBAction)sendButton:(id)sender;
- (void)postData:(NSString*)username withScore:(NSString*)score;
- (void)getData;
@end
