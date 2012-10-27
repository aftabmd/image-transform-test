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
@synthesize scaleAmount;


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


- (UIImage *)padImage:(UIImage *)img to:(CGSize)size
{
    size.width = MAX(size.width, img.size.width);
    size.height = MAX(size.height, img.size.height);
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(NULL, size.width, size.height, 8, 0, colorSpace, kCGImageAlphaPremultipliedLast);
    
    CGRect centeredRect = CGRectMake((size.width - img.size.width)/2.0, (size.height - img.size.height)/2.0, img.size.width, img.size.height);
    CGContextDrawImage(context, centeredRect, [img CGImage]);
    
    CGImageRef imageRef = CGBitmapContextCreateImage(context);
    
    CGColorSpaceRelease(colorSpace);
    CGContextRelease(context);
    
    UIImage *paddedImage = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    return paddedImage;
}

// final image size must be 640x480
- (void)generateFinalImage
{    
    float rotatableCanvasWidth = self.importedImageView.bounds.size.height;
    float rotatableCanvasHeight = self.importedImageView.bounds.size.width;
    UIImage *tmp = self.importedRawImage;
    
    CGSize size = self.importedRawImage.size;
    NSLog(NSStringFromCGSize(size));
    
    tmp = [self padImage:tmp to:CGSizeMake(rotatableCanvasWidth, rotatableCanvasHeight)];
    
    if (self.scaleAmount < 1.0)
    {
        tmp = [self padImage:tmp to:CGSizeMake(rotatableCanvasWidth / self.scaleAmount, rotatableCanvasHeight / self.scaleAmount)];
    }
    
    CIImage *ciImage = [[CIImage alloc] initWithImage:[tmp imageWithTransform:self.importedImageView.transform]];
    
    CGPoint center = CGPointMake(size.width / 2.0, size.height / 2.0);
    
    CIContext *context = [CIContext contextWithOptions:nil];
    CGRect r = ciImage.extent;
    r.origin.x = (r.size.width - rotatableCanvasHeight) / 2.0;
    r.origin.y = (r.size.height - rotatableCanvasWidth) / 2.0;
    
    r.size.width = rotatableCanvasHeight;
    r.size.height = rotatableCanvasWidth;
    
    self.finalImage = [UIImage imageWithCGImage:[context createCGImage:ciImage fromRect:r] 
                                          scale: 1.0
                                    orientation:UIImageOrientationUp];
    
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
    self.scaleAmount = 1.0f;
    
	UIImage *image = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
    
    image = [image fixOrientation];
    
    self.importedImageView.contentMode = UIViewContentModeScaleAspectFill;  // little bit of a hacky sacky
    self.importedImageView.image = image;
    
    CGSize scaling = [self.importedImageView imageScale];
    
    NSLog(NSStringFromCGSize(scaling));
    
    image = [image resizedImage:CGSizeMake(image.size.width * scaling.width, image.size.height * scaling.height) 
           interpolationQuality:kCGInterpolationHigh];
    
    self.importedImageView.contentMode = UIViewContentModeCenter;
    self.importedImageView.image = image;
    
    self.importedRawImage = image;
    
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
    NSLog(@"sender.scale = %f", sender.scale);
        
    self.scaleAmount *= sender.scale;
    NSLog(@"self.scaleAmount = %f", self.scaleAmount);
    
    if (self.scaleAmount < 0.15) 
    {
        self.scaleAmount = 0.15;
        NSLog(@"self.scaleAmount = %f", self.scaleAmount);
        return;
    }

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
