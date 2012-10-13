//
//  ViewController.m
//  Image Transform Test
//
//  Created by Ryan Detert on 10/7/12.
//  Copyright (c) 2012 iMantech. All rights reserved.
//

#import "ViewController.h"
#import "UIImage+Extensions.h"


@interface ViewController ()

@end

@implementation ViewController

@synthesize myimage;
@synthesize importedImageView;
@synthesize importTranslation, importRotation, importScale;



- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}


#pragma mark Image Picker Methods

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissModalViewControllerAnimated:YES];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    
	UIImage *image = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
    
    self.myimage = image;

    self.myimage = [self.myimage imageRotatedByDegrees:90.0f];
    
    self.importedImageView.image = self.myimage;
    
    NSLog(@"Done picking imagePickerController");
    
    [picker dismissModalViewControllerAnimated:YES];
}

- (IBAction)selectExistingPhoto:(id)sender
{        
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    [imagePickerController setDelegate:self];
    [imagePickerController setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    [imagePickerController setMediaTypes:[NSArray arrayWithObject:(NSString *)kUTTypeImage]];
    [imagePickerController setAllowsEditing:NO];
    [self presentViewController:imagePickerController animated:YES completion:^{
        NSLog(@"Presented image picker controller.");
    }];
}


#pragma mark Gesture Recognizers

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

- (IBAction)handlePanGesture:(UIPanGestureRecognizer *)sender
{
    CGPoint translation = [sender translationInView:sender.view];
    self.importTranslation = CGAffineTransformTranslate(self.importTranslation, translation.x, translation.y);
    [sender setTranslation:CGPointZero inView:sender.view];
    
    NSLog(@"asdfasdfsd");
    
    //[self updateImportPreview];
}

- (IBAction)handlePinchGesture:(UIPinchGestureRecognizer *)sender
{
    //    CGPoint location = [sender locationInView:sender.view];//self.importPreviewBackImageView
    //    self.importScale = CGAffineTransformTranslate(self.importScale, -location.x/2.0, -location.y/2.0);
    self.importScale = CGAffineTransformScale(self.importScale, sender.scale, sender.scale);
    //    self.importScale = CGAffineTransformTranslate(self.importScale, +location.x/2.0, +location.y/2.0);
    [sender setScale:1.0];
    
    //[self updateImportPreview];
}

- (IBAction)handleRotationGesture:(UIRotationGestureRecognizer *)sender
{
    self.importRotation = CGAffineTransformRotate(self.importRotation, sender.rotation);
    [sender setRotation:0.0];
    
    //[self updateImportPreview];
}

@end
