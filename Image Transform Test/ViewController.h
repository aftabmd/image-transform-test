//
//  ViewController.h
//  Image Transform Test
//
//  Created by Ryan Detert on 10/7/12.
//  Copyright (c) 2012 iMantech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <MobileCoreServices/MobileCoreServices.h>

@interface ViewController : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIGestureRecognizerDelegate>

@property (retain, nonatomic) IBOutlet UIImageView *previewImageView;
@property (retain, nonatomic) IBOutlet UIImageView *importedImageView;

@property (retain, nonatomic) UIImage *importedRawImage;
@property (retain, nonatomic) UIImage *finalImage;

@property (nonatomic) CGAffineTransform importTranslation, importRotation, importScale;

- (void)updateImagePreview;
- (void)generateFinalImage;

- (IBAction)selectExistingPhoto:(id)sender;

- (IBAction)handlePanGesture:(UIPanGestureRecognizer *)sender;
- (IBAction)handlePinchGesture:(UIPinchGestureRecognizer *)sender;
- (IBAction)handleRotationGesture:(UIRotationGestureRecognizer *)sender;


@end
