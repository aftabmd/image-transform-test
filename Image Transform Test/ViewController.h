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

@property (nonatomic, retain) UIImage *myimage;
@property (retain, nonatomic) IBOutlet UIImageView *importedImageView;

@property (nonatomic) CGAffineTransform importTranslation, importRotation, importScale;


- (IBAction)selectExistingPhoto:(id)sender;

- (IBAction)handlePanGesture:(UIPanGestureRecognizer *)sender;
- (IBAction)handlePinchGesture:(UIPinchGestureRecognizer *)sender;
- (IBAction)handleRotationGesture:(UIRotationGestureRecognizer *)sender;


@end
