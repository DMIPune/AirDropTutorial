//
//  SendTextViewController.m
//  AirDropSenderApp
//
//  Created by Pranay on 3/25/14.
//  Copyright (c) 2014 DMI. All rights reserved.
//

#import "SendTextViewController.h"
#import "APLCustomURLContainer.h"
#import "APLUtilities.h"

#define kDemoText   @"Hi this is demo Text"

@interface SendTextViewController ()

@property (strong, nonatomic) APLCustomURLContainer *customURLContainer;
@property (weak, nonatomic) IBOutlet UITextView *commentTextView;

- (IBAction)sendButtonAction:(id)sender;

@end

@implementation SendTextViewController

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

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                          action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tap];
    
    //Load custom url
    NSURL *customURL = [APLUtilities loadCustomURL];
    if (!customURL) {
        customURL = [[NSURL alloc] initWithString:kDemoText];
    }
    
    self.commentTextView.text = kDemoText;
    self.customURLContainer = [[APLCustomURLContainer alloc] initWithURL:customURL];
}

- (void)dismissKeyboard
{
    [self.commentTextView resignFirstResponder];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)sendButtonAction:(id)sender
{
    if (self.commentTextView.text.length <= 0){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Alert" message:@"Please add some text!" delegate:Nil cancelButtonTitle:Nil otherButtonTitles:@"Ok", nil];
        [alert show];
    } else {
        [self.commentTextView resignFirstResponder];
        //NSString *commentStr = [self.commentTextView.text stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSString *commentStr = [self.commentTextView.text stringByReplacingOccurrencesOfString:@" " withString:@"_"];
        commentStr = [commentStr stringByReplacingOccurrencesOfString:@"\n" withString:@"_"];
        self.customURLContainer.url = [NSURL URLWithString:[NSString stringWithFormat:@"adcs://%@", commentStr]];
        [self openActivitySheet];
    }
}

- (void)openActivitySheet
{
    UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:@[self.customURLContainer] applicationActivities:nil];
    
    [self presentViewController:activityViewController animated:YES completion:nil];
}

@end
