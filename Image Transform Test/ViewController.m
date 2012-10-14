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

@synthesize importedImageView, previewImageView;
@synthesize finalImage;
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
    return NO; //(interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (void) viewWillAppear:(BOOL)animated 
{
    self.importTranslation = CGAffineTransformIdentity;
    self.importRotation = CGAffineTransformMakeRotation(M_PI_2);
    self.importScale = CGAffineTransformIdentity;
    
    self.importedImageView.transform = CGAffineTransformIdentity;
    
    self.importedImageView.hidden = NO;
        
    self.importedImageView.transform = CGAffineTransformMakeRotation(M_PI_2);
    
    [self generateFinalImage];
}


#pragma mark Image Manipulation Methods

- (void)updateImagePreview
{
    CGAffineTransform t = CGAffineTransformIdentity;
    CGSize size = self.importedImageView.image.size;
    t = CGAffineTransformTranslate(t, -size.width/2.0, -size.height/2.0);
    t = CGAffineTransformConcat(t, self.importRotation);
    t = CGAffineTransformConcat(t, self.importScale);
    t = CGAffineTransformConcat(t, self.importTranslation);
    t = CGAffineTransformTranslate(t, +size.width/2.0, +size.height/2.0);
    
    self.importedImageView.transform = t;
    
    [self generateFinalImage];
}

-(void)generateFinalImage
{    
    self.finalImage = self.importedImageView.image;
    
    // self.finalImage = [self.finalImage imageRotatedByDegrees:90.0f];
    
    CIImage *ciImage = [[CIImage alloc] initWithImage:self.finalImage];
    CGSize size = self.finalImage.size;
    CGRect rect = CGRectMake(0.0, 0.0, size.width, size.height);
    
    CGAffineTransform t = CGAffineTransformIdentity;

    float heightRatio = 640.0/480.0;
    float widthRatio  = 852.0/640.0;
    
    t = CGAffineTransformTranslate(t, +size.width/2.0, +size.height/2.0);
    
    t = CGAffineTransformScale(t, 1.0, -1.0);
        t = CGAffineTransformConcat(self.importTranslation, t);
    t = CGAffineTransformScale(t, 1.0, -1.0);
    
    t = CGAffineTransformConcat(self.importScale, t);
    
    t = CGAffineTransformScale(t, -1.0, 1.0);
        t = CGAffineTransformConcat(self.importRotation, t);
    t = CGAffineTransformScale(t, -1.0, 1.0);
    
    t = CGAffineTransformTranslate(t, -size.width/2.0, -size.height/2.0);
    
    ciImage = [ciImage imageByApplyingTransform:t];
    
    CIContext *context = [CIContext contextWithOptions:nil];
    
    CIFilter *constantColorGenerator = [CIFilter filterWithName:@"CIConstantColorGenerator"];
    CIColor *backgroundColor = [CIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:1.0];
    [constantColorGenerator setValue:backgroundColor forKey:@"inputColor"];
    
    // CGSize targetSize = CGSizeMake(852.0, 640.0);
    //CGSize targetSize = CGSizeMake(640.0, 852.0);
    //
    //rect = CGRectMake(0.0, 0.0, targetSize.width, targetSize.height);    

    CGSize targetSize = CGSizeMake(640.0, 480.0);
    rect = CGRectMake(0.0, 0.0, targetSize.width, targetSize.height);
    CGAffineTransform scaleAndRotate = CGAffineTransformIdentity;
    scaleAndRotate = CGAffineTransformTranslate(scaleAndRotate, +size.width/2.0, +size.height/2.0);
    scaleAndRotate = CGAffineTransformScale(scaleAndRotate, 3.0/4.0, 3.0/4.0);
    scaleAndRotate = CGAffineTransformRotate(scaleAndRotate, M_PI_2);
    scaleAndRotate = CGAffineTransformTranslate(scaleAndRotate, -size.width/2.0, -size.height/2.0);

    CIImage *finalCIImage = [ciImage imageByApplyingTransform:scaleAndRotate];

    CGImageRef ref = [context createCGImage:finalCIImage fromRect:rect];
    
    //CGImageRef ref = [context createCGImage:ciImage fromRect:rect];
    
    UIImage *transformedImage = [UIImage imageWithCGImage:ref scale:1.0 orientation:UIImageOrientationUp];
    CGImageRelease(ref);
    
    self.finalImage = transformedImage;
    
    self.finalImage = [self.finalImage imageRotatedByDegrees:90.0f];
    
    self.previewImageView.image = self.finalImage;
}


#pragma mark Image Picker Methods

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissModalViewControllerAnimated:YES];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    
	UIImage *image = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
    
    self.importedImageView.image = image;
    
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
    // NSLog(@"handlePanGesture");
    
    CGPoint translation = [sender translationInView:sender.view];
    self.importTranslation = CGAffineTransformTranslate(self.importTranslation, translation.x, translation.y);
    [sender setTranslation:CGPointZero inView:sender.view];
        
    [self updateImagePreview];
}

- (IBAction)handlePinchGesture:(UIPinchGestureRecognizer *)sender
{
    // NSLog(@"handlePinchGesture");

    self.importScale = CGAffineTransformScale(self.importScale, sender.scale, sender.scale);
    [sender setScale:1.0];
    
    [self updateImagePreview];
}

- (IBAction)handleRotationGesture:(UIRotationGestureRecognizer *)sender
{
    // NSLog(@"handleRotationGesture");
    
    self.importRotation = CGAffineTransformRotate(self.importRotation, sender.rotation);
    [sender setRotation:0.0];
    
    [self updateImagePreview];
}

@end
