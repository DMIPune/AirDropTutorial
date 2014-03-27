//
//  SendFileViewController.m
//  AirDropSenderApp
//
//  Created by Pranay on 3/25/14.
//  Copyright (c) 2014 DMI. All rights reserved.
//

#import "SendFileViewController.h"
#import "APLProfile.h"

@interface SendFileViewController () <UINavigationControllerDelegate, UIImagePickerControllerDelegate>
{
    UIImage *selectedImage;
    APLProfile *profile;
}

@property (weak, nonatomic) IBOutlet UIButton *imageButton;
@property (weak, nonatomic) IBOutlet UITextField *fileNameTextField;

- (IBAction)selectImageButtonAction:(id)sender;
- (IBAction)sendFileButtonAction:(id)sender;

@end

@implementation SendFileViewController

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
}

- (void)dismissKeyboard
{
    [self.fileNameTextField resignFirstResponder];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)selectImageButtonAction:(id)sender
{
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc]init];
    imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.delegate = self;
    imagePickerController.sourceType =  UIImagePickerControllerSourceTypePhotoLibrary;
    
    [self.navigationController presentViewController:imagePickerController animated:YES completion:Nil];
}

- (IBAction)sendFileButtonAction:(id)sender
{
    if (!selectedImage) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Alert" message:@"Please select Image!" delegate:Nil cancelButtonTitle:Nil otherButtonTitles:@"Ok", nil];
        [alert show];
    } else if (self.fileNameTextField.text.length <= 0){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Alert" message:@"Please select File Name!" delegate:Nil cancelButtonTitle:Nil otherButtonTitles:@"Ok", nil];
        [alert show];
    } else {
        profile = [[APLProfile alloc] initWithName:self.fileNameTextField.text image:selectedImage];
        [self.fileNameTextField resignFirstResponder];
        [self openActivitySheet];
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker
        didFinishPickingImage:(UIImage *)image
                  editingInfo:(NSDictionary *)editingInfo
{
    selectedImage = image;
    [self.imageButton setImage:selectedImage forState:UIControlStateNormal];
    [picker dismissModalViewControllerAnimated:YES];
}

- (void)openActivitySheet
{
    UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:@[profile] applicationActivities:nil];
    [self presentViewController:activityViewController animated:YES completion:nil];
}

@end
