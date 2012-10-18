//
//  UIImageView+ImageScale.m
//  Image Transform Test
//
//  Created by Ryan Detert on 10/14/12.
//  Copyright (c) 2012 iMantech. All rights reserved.
//

#import "UIImageView+ImageScale.h"

@implementation UIImageView (ImageScale)

- (CGSize)imageScale 
{
    CGFloat sx = self.frame.size.width / self.image.size.width;
    CGFloat sy = self.frame.size.height / self.image.size.height;
    CGFloat s = 1.0;
    switch (self.contentMode) {
        case UIViewContentModeScaleAspectFit:
            s = fminf(sx, sy);
            return CGSizeMake(s, s);
            break;
            
        case UIViewContentModeScaleAspectFill:
            s = fmaxf(sx, sy);
            return CGSizeMake(s, s);
            break;
            
        case UIViewContentModeScaleToFill:
            return CGSizeMake(sx, sy);
            
        default:
            return CGSizeMake(s, s);
    }
}

@end
