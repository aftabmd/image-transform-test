// UIImage+Resize.h
// Created by Trevor Harmon on 8/5/09.
// Free for personal or commercial use, with or without modification.
// No warranty is expressed or implied.
// Edited by Neema on 2/21/2012

#import <QuartzCore/QuartzCore.h>


// Extends the UIImage class to support resizing/cropping
@interface UIImage (Resize)

- (UIImage *)croppedImage:(CGRect)bounds;
- (UIImage *)paddedImage:(CGSize)size;
- (UIImage *)thumbnailImage:(NSInteger)thumbnailSize
          transparentBorder:(NSUInteger)borderSize
               cornerRadius:(NSUInteger)cornerRadius
       interpolationQuality:(CGInterpolationQuality)quality;
- (UIImage *)resizedImage:(CGSize)newSize
     interpolationQuality:(CGInterpolationQuality)quality;
- (UIImage *)resizedImageWithContentMode:(UIViewContentMode)contentMode
                                  bounds:(CGSize)bounds
                    interpolationQuality:(CGInterpolationQuality)quality;
- (UIImage *)imageWithTransform:(CGAffineTransform)t;
- (UIImage *)imageRotatedByDegrees:(CGFloat)degrees;

// from http://stackoverflow.com/a/7269020
- (UIImage *)flipHorizontally;
- (UIImage *) flipVertically;

// from http://stackoverflow.com/questions/2658738/the-simplest-way-to-resize-an-uiimage
// seems to be thread safe, whereas resizedImage has some wonkiness
+ (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize;
+ (UIImage *)imageWithImage:(UIImage *)image scaledWithLongestSideLength:(int)length;

- (UIImage *)scaledToSize:(CGSize)size;
- (UIImage *)scaledWithLongestSideLength:(int)maxLength;

// http://stackoverflow.com/questions/5427656/ios-uiimagepickercontroller-result-image-orientation-after-upload/5427890#5427890
- (UIImage *)fixOrientation;

@end
