//
//  ReceivedProfileViewController.m
//  AirDropReceiverApp
//
//  Created by Pranay on 3/26/14.
//  Copyright (c) 2014 DMI. All rights reserved.
//

#import "ReceivedProfileViewController.h"
#import "ReceivedProfileListViewController.h"
#import "APLUtilities.h"
#import "AppDelegate.h"
#import "Constant.h"

@interface ReceivedProfileViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@end

@implementation ReceivedProfileViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (self.profile)
        [self.profileImageView setImage:self.profile.image];
    
	// Do any additional setup after loading the view.
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"Discard"
                                                                     style:UIBarButtonItemStylePlain
                                                                    target:self
                                                                    action:@selector(discardProfile:)];
    
    UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave
                                                                                target:self
                                                                                action:@selector(saveProfile:)];
    
    self.navigationItem.leftBarButtonItem = cancelButton;
    self.navigationItem.rightBarButtonItem = saveButton;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)saveProfile:(id)sender
{
    AppDelegate *appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    
    APLProfile *profile = [appDelegate dequeueProfile];
    
    if (profile) {
        [APLUtilities saveProfile:profile];
    }
    [self launchProfileListViewController];
}

- (void)discardProfile:(id)sender
{
    AppDelegate *appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    [appDelegate dequeueProfile];
    
    [self launchProfileListViewController];
}

- (void)launchProfileListViewController
{
    AppDelegate *appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    UIStoryboard *sb = [UIStoryboard storyboardWithName:kMainStoryboardName bundle:nil];
    ReceivedProfileListViewController *profileListViewController = [sb instantiateViewControllerWithIdentifier:@"ReceivedProfileListViewController"];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:profileListViewController];
    [appDelegate.saveReceivedWindow setRootViewController:nav];
    [appDelegate.saveReceivedWindow makeKeyAndVisible];
}

@end
