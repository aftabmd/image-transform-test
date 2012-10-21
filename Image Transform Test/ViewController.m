//
//  ViewController.m
//  Image Transform Test
//
//  Created by Ryan Detert on 10/7/12.
//  Copyright (c) 2012 iMantech. All rights reserved.
//

#import "ViewController.h"
#import "UIImage+Extensions.h"
#import "UIImage+Resize.h"
#import "UIImageView+ImageScale.h"


@interface ViewController ()

@end

@implementation ViewController

@synthesize importedImageView, previewImageView;
@synthesize finalImage, importedRawImage;
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
    
    self.importedImageView.transform = t;   // update the live preview from touchable area
    
    [self generateFinalImage];
}


-(UIImage *)createBlankImageWithSize:(CGSize)imageSize
{
    CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceRGB();
    
    unsigned long bufferLength = imageSize.width * imageSize.height * 4;
    unsigned char *bitmap = (unsigned char *) malloc(bufferLength);
    memset(bitmap, 255, bufferLength);
    
    CGDataProviderRef provider = CGDataProviderCreateWithData(NULL, 
                                                              bitmap, 
                                                              bufferLength, 
                                                              NULL);
    int bitsPerComponent = 8;
    int bitsPerPixel = 32;
    int bytesPerRow = 4 * imageSize.width;
    
    CGImageRef imageRef = CGImageCreate(imageSize.width, 
                                        imageSize.height, 
                                        bitsPerComponent, 
                                        bitsPerPixel, 
                                        bytesPerRow, 
                                        colorSpaceRef, 
                                        kCGBitmapByteOrderDefault | kCGImageAlphaLast, 
                                        provider, 
                                        NULL, 
                                        NO, 
                                        kCGRenderingIntentDefault);

    UIImage *blankImage = [UIImage imageWithCGImage:imageRef];

    free(bitmap);
    CGColorSpaceRelease(colorSpaceRef);
    CGDataProviderRelease(provider);
    CGImageRelease(imageRef);
    
    return blankImage;
}


-(UIImage *)makeUIImageFromCIImage:(CIImage*)ciImage
{
    CIContext *context = [CIContext contextWithOptions:nil];
    
    CGImageRef processedCGImage = [context createCGImage:ciImage 
                                                  fromRect:[ciImage extent]];
    
    UIImage *returnImage = [UIImage imageWithCGImage:processedCGImage];
    CGImageRelease(processedCGImage);
    
    return returnImage;
}


-(UIImage*) drawImage:(UIImage*) fgImage
              inImage:(UIImage*) bgImage
              atPoint:(CGPoint)  point
{
    UIGraphicsBeginImageContextWithOptions(bgImage.size, FALSE, 0.0);
    [bgImage drawInRect:CGRectMake( 0, 0, bgImage.size.width, bgImage.size.height)];
    [fgImage drawInRect:CGRectMake( point.x, point.y, fgImage.size.width, fgImage.size.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}


// final image size must be 640x480
-(void)generateFinalImage
{   
//    float rotatableCanvasWidth = 852.0f;        // iPhone 4 editable screen area
//    float rotatableCanvasHeight = 640.0f;
//    
//    float finalImageWidth = 640.0f;             // final image size
//    float finalImageHeight = 480.0f;
    
    UIImage *tmp = self.importedRawImage;
    
    tmp = [tmp imageRotatedByDegrees:90.0f];
    
    CIImage *ciImage = [[CIImage alloc] initWithImage:tmp];
    CGSize size = self.importedRawImage.size;

    CGAffineTransform t = CGAffineTransformIdentity;
    t = CGAffineTransformTranslate(t, +size.width/2.0, +size.height/2.0);
    
    t = CGAffineTransformScale(t, 1.0, -1.0);
        t = CGAffineTransformConcat(self.importTranslation, t);
    
    t = CGAffineTransformScale(t, 1.0, -1.0);
        t = CGAffineTransformConcat(self.importScale, t);
        
    t = CGAffineTransformScale(t, -1.0, 1.0);
        t = CGAffineTransformConcat(self.importRotation, t);
    
    //t = CGAffineTransformScale(t, -1.0, 1.0);
    //    t = CGAffineTransformTranslate(t, -size.width/2.0, -size.height/2.0);

    //ciImage = [ciImage imageByApplyingTransform:t];
    
    
    
    CIContext *context = [CIContext contextWithOptions:nil];
    CGRect rect = CGRectMake(0.0, 0.0, size.width, size.height);
    
    CIFilter *constantColorGenerator = [CIFilter filterWithName:@"CIConstantColorGenerator"];
    CIColor *backgroundColor = [CIColor colorWithRed:01.0 green:01.0 blue:01.0 alpha:1.0];
    [constantColorGenerator setValue:backgroundColor forKey:@"inputColor"];
    
    CIFilter *sourceOverComposite = [CIFilter filterWithName:@"CISourceOverCompositing"];
    [sourceOverComposite setValue:[constantColorGenerator valueForKey:@"outputImage"] forKey:@"inputBackgroundImage"];
    [sourceOverComposite setValue:ciImage forKey:@"inputImage"];
    CIImage *outImage = [sourceOverComposite valueForKey:@"outputImage"];
    
    //CGSize targetSize = CGSizeMake(640.0, 480.0);
    //rect = CGRectMake(0.0, 0.0, targetSize.width, targetSize.height);
    
    //CGAffineTransform scaleAndRotate = CGAffineTransformIdentity;
    //scaleAndRotate = CGAffineTransformRotate(scaleAndRotate, M_PI_2);

    //CIImage *finalImage = [outImage imageByApplyingTransform:scaleAndRotate];
    
    CGImageRef ref = [context createCGImage:ciImage fromRect:rect];
    self.finalImage = [UIImage imageWithCGImage:ref scale:1.0 orientation:UIImageOrientationUp];
    CGImageRelease(ref);
    
    NSLog(@"width = %f, height = %f", self.finalImage.size.width, self.finalImage.size.height);
    
    // just for preview window
    self.finalImage = [self.finalImage resizedImage:CGSizeMake(100.0f, 134.0f) interpolationQuality:kCGInterpolationHigh];
    
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
    
    image = [image fixOrientation];
    
    self.importedRawImage = image;
    
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
