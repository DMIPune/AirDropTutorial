//
//  AppDelegate.m
//  AirDropReceiverApp
//
//  Created by Pranay on 3/25/14.
//  Copyright (c) 2014 DMI. All rights reserved.
//

#import "AppDelegate.h"
#import "APLProfile.h"
#import "APLUtilities.h"
#import "ReceivedProfileViewController.h"
#import "Constant.h"

NSString * const kCustomScheme = @"adcs";
NSString * const kDocumentsInboxFolder = @"Inbox";

@interface AppDelegate ()

@property (strong, nonatomic) NSMutableArray *receivedProfileQueue;

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

//- (void)applicationDidBecomeActive:(UIApplication *)application
//{
//    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
//}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    //Check for orphaned files in the inbox
    [self handleDocumentsInbox];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    if (url) {
        if (url.scheme && [url.scheme isEqualToString:kCustomScheme]) {
            
            NSString *commentString = [self stringFromURLWithoutScheme:url];
            commentString = [self stringFromURLWithoutFormatin:commentString];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Alert" message:commentString delegate:Nil cancelButtonTitle:Nil otherButtonTitles:@"Ok", nil];
            [alert show];
        }
        else
        {
            APLProfile *profile = [APLUtilities securelyUnarchiveProfileWithFile:[url path]];
            
            if (profile) {
                [self enqueueProfile:profile];
            }
            [self removeInboxItem:url];
        }
    }
    return YES;
}

#pragma mark - Document Inbox Handling

- (void)handleDocumentsInbox
{
    //All incoming files are stored in Documents/Inbox/
    NSString *inboxPath = [[APLUtilities documentsDirectory] stringByAppendingPathComponent:kDocumentsInboxFolder];
    
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    NSArray *inboxFiles = [fileManager contentsOfDirectoryAtPath:inboxPath error:nil];
    
    for (NSString *path in inboxFiles) {
        
        //Append file name to path and create URL
        NSURL *url = [NSURL fileURLWithPath:[inboxPath stringByAppendingPathComponent:path]];
        [self application:[UIApplication sharedApplication] openURL:url sourceApplication:@"" annotation:nil];
    }
}

- (void)removeInboxItem:(NSURL *)itemURL
{
    //Clean up the inbox once the file has been processed
    NSError *error = nil;
    [[NSFileManager defaultManager] removeItemAtPath:[itemURL path] error:&error];
    
    if (error) {
        NSLog(@"ERROR: Inbox file could not be deleted");
    }
}


#pragma mark - AirDropped Profile Receiving

/****************************************************
 Handling Incoming Profiles
 
 When the app receives a profile it displays it own view to give a chance to look at the profile and decide if they want it.
 
 There are two considerations when displaying a save view for the user.
 
 First the user could be doing an important task that this save view is going to interrupt. To account for this the app displays the save view in its own window, which will not disturb the main window's contents.
 
 Second while the user is deciding if they want to keep the profile, another one could arrive. Because of this possibility, this app keeps a queue of arriving profiles.
 
 When the first profile arrives a navigation controller is created to display that profile in a APLProfileViewController.
 
 When each subsequent profile arrives they are enqueued. Once the user decides whether or not to save the displayed profile, the next profile is pushed onto the navigation controller's stack.
 
 ******************************************************/

- (void)enqueueProfile:(APLProfile *)profile
{
    if (!_receivedProfileQueue) {
        _receivedProfileQueue = [NSMutableArray array];
    }
    
    @synchronized(self.receivedProfileQueue)
    {
        [self.receivedProfileQueue addObject:profile];
        
        [self presentFirstProfile];
    }
}

- (APLProfile *)dequeueProfile
{
    @synchronized(self.receivedProfileQueue) {
        APLProfile *profile = nil;
        if (self.receivedProfileQueue.count > 0) {
            profile = [self.receivedProfileQueue firstObject];
            [self.receivedProfileQueue removeObject:profile];
        }
        return profile;
    }
}

- (void)presentFirstProfile
{
    APLProfile *profile = [self.receivedProfileQueue firstObject];
    
    if (profile) {
        
        //Notify observers that the save window will appear
        //[[NSNotificationCenter defaultCenter] postNotificationName:DisplayingSaveWindowNotification object:nil];
        
        //Create Window
        self.saveReceivedWindow = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
        [self.saveReceivedWindow setWindowLevel:UIWindowLevelNormal];
        
        //Create profileViewController to display received profile
        //APLProfileViewController *profileViewController = [self createProfileViewControllerForProfile:profile];
        
        UIStoryboard *sb = [UIStoryboard storyboardWithName:kMainStoryboardName bundle:nil];
        ReceivedProfileViewController *profileViewController = [sb instantiateViewControllerWithIdentifier:@"ReceivedProfileViewController"];
        profileViewController.profile = profile;
        
        //Create a navigation controller to handle displaying multiple incoming profiles
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:profileViewController];
        [self.saveReceivedWindow setRootViewController:nav];
        
        //Set frame below the screen
        CGRect originalFrame = self.saveReceivedWindow.frame;
        CGRect newFrame = self.saveReceivedWindow.frame;
        newFrame.origin.y = newFrame.origin.y + newFrame.size.height;
        self.saveReceivedWindow.frame = newFrame;
        
        //Create animation to have window slide up from bottom of the screen
        [self.saveReceivedWindow makeKeyAndVisible];
        [UIView animateWithDuration:0.4f
                              delay:0.0f
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             self.saveReceivedWindow.frame = originalFrame;
                         }
                         completion:nil];
    }
}

#pragma mark - Convenience Methods

- (NSString *)stringFromURLWithoutScheme:(NSURL *)url
{
    NSString *scheme = [[url scheme] stringByAppendingString:@"://"];
    return [[url absoluteString] substringFromIndex:[scheme length]];
}

- (NSString *)stringFromURLWithoutFormatin:(NSString *)urlString
{
    return [urlString stringByReplacingOccurrencesOfString:@"_" withString:@" "];
}



@end
