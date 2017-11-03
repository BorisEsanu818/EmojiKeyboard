//
//  MWFImageCropper.h
//
//  Created by Matthew Frederick on 3/19/12.
//  Copyright (c) 2012 Matthew Frederick. All rights reserved.
//
//
//  Modified by Category3 Studios 2017
//  Copyright (c) 2017 Emotifont

#import <Foundation/Foundation.h>

@interface MWFImageCropper : NSObject

+ (UIImage *)cropImage:(UIImage *)image
           withPadding:(CGFloat)padMargin
      andMinimumHeight:(CGFloat)minHeight
forMinimumWidthTrigger:(CGFloat)minWidthTrigger;

+ (UIImage*) getSubImageFromImage:(UIImage *)image
                         rectFrom:(CGRect) drawRect;

@end
