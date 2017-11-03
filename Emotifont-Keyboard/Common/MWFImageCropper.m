//
//  MWFImageCropper.m
//
//  Created by Matthew Frederick on 3/19/12.
//  Copyright (c) 2012 Matthew Frederick. All rights reserved.
//
//
//  Modified by Category3 Studios 2017
//  Copyright (c) 2017 Emotifont

#import "MWFImageCropper.h"

@implementation MWFImageCropper

+ (UIImage *)cropImage:(UIImage *)image
           withPadding:(CGFloat)padMargin
      andMinimumHeight:(CGFloat)minHeight
forMinimumWidthTrigger:(CGFloat)minWidthTrigger {
    // Crop the image
    // Determine the crop area
    // Move image into a data buffer
    CGImageRef imageRef = [image CGImage];
    NSUInteger imageWidth = CGImageGetWidth(imageRef);
    NSUInteger imageHeight = CGImageGetHeight(imageRef);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    unsigned char *rawData = (unsigned char*) calloc(imageHeight * imageWidth * 4, sizeof(unsigned char));
    NSUInteger bytesPerPixel = 4;
    NSUInteger bytesPerRow = bytesPerPixel * imageWidth;
    NSUInteger bitsPerComponent = 8;
    CGContextRef context = CGBitmapContextCreate(rawData, imageWidth, imageHeight, bitsPerComponent, bytesPerRow, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    CGColorSpaceRelease(colorSpace);
    CGContextDrawImage(context, CGRectMake(0, 0, imageWidth, imageHeight), imageRef);
    CGContextRelease(context);
    
    NSInteger byteIndex;
    CGFloat red, green, blue;
    BOOL nonCroppedPixelsFound = NO;
    BOOL isImageAllMatching = NO;
    
    // Check pixels moving down from the top and up from the bottom, looking for non-white color
    NSInteger topCrop = 0;
    NSInteger bottomCrop = imageHeight - 1;
    NSInteger topRow, bottomRow;
    BOOL isTopFound = NO, isBottomFound = NO;
    for (topRow = 0; topRow < imageHeight; topRow++) {
        bottomRow = imageHeight - 1 - topRow;
        // Ensure we're not checking pixels that have already been checked (one row overlap if odd height)
        if (!isTopFound && !isBottomFound && topRow > bottomRow) {
            isTopFound = YES;
            isBottomFound = YES;
            isImageAllMatching = YES;
            break;
        }
        // Check for non-matching pixels
        for (NSInteger column = 0; column < imageWidth; column++) {
            if (!isTopFound) {
                byteIndex = (bytesPerRow * topRow) + column * bytesPerPixel;
                red = (rawData[byteIndex] * 1.0);
                green = (rawData[byteIndex + 1] * 1.0);
                blue = (rawData[byteIndex + 2] * 1.0);
                if (red < 255.0 || green < 255.0 || blue < 255.0) {
                    topCrop = topRow;
                    isTopFound = YES;
                    nonCroppedPixelsFound = YES;
                    if (isBottomFound) break;
                }
            }
            if (!isBottomFound) {
                byteIndex = (bytesPerRow * bottomRow) + column * bytesPerPixel;
                red = (rawData[byteIndex] * 1.0);
                green = (rawData[byteIndex + 1] * 1.0);
                blue = (rawData[byteIndex + 2] * 1.0);
                if (red < 255.0 || green < 255.0 || blue < 255.0) {
                    bottomCrop = bottomRow;
                    isBottomFound = YES;
                    nonCroppedPixelsFound = YES;
                }
            }
            if (isTopFound && isBottomFound) break;
        }
        if (isTopFound && isBottomFound) break;
    }
    
    // Check pixels moving in from the left and right within the top and bottom crop, looking for non-white color
    NSInteger leftCrop = 0;
    NSInteger rightCrop = imageWidth - 1;
    if (nonCroppedPixelsFound) {
        NSInteger leftColumn, rightColumn;
        BOOL isLeftFound = NO, isRightFound = NO;
        for (leftColumn = 0; leftColumn < imageWidth; leftColumn++) {
            rightColumn = imageWidth - 1 - leftColumn;
            // Check for non-matching pixels
            for (NSInteger row = topCrop; row < bottomCrop; row++) {
                if (!isLeftFound) {
                    byteIndex = (bytesPerRow * row) + leftColumn * bytesPerPixel;
                    red = (rawData[byteIndex] * 1.0);
                    green = (rawData[byteIndex + 1] * 1.0);
                    blue = (rawData[byteIndex + 2] * 1.0);
                    if (red < 255.0 || green < 255.0 || blue < 255.0) {
                        leftCrop = leftColumn;
                        isLeftFound = YES;
                        if (isRightFound) break;
                    }
                }
                if (!isRightFound) {
                    byteIndex = (bytesPerRow * row) + rightColumn * bytesPerPixel;
                    red = (rawData[byteIndex] * 1.0);
                    green = (rawData[byteIndex + 1] * 1.0);
                    blue = (rawData[byteIndex + 2] * 1.0);
                    if (red < 255.0 || green < 255.0 || blue < 255.0) {
                        rightCrop = rightColumn;
                        isRightFound = YES;
                    }
                }
                if (isLeftFound && isRightFound) break;
            }
            if (isLeftFound && isRightFound) break;
        }
    }
    
    free(rawData);
    
    if (nonCroppedPixelsFound) {
        // Determine crop rect without padding
        NSInteger cropWidth = rightCrop - leftCrop + 1;
        NSInteger cropHeight = bottomCrop - topCrop + 1;
        CGRect cropRect = CGRectMake(leftCrop, topCrop, cropWidth, cropHeight);
        
        // Modify crop rect to add in padding
        CGFloat resMultiplier = 1.0;
        if (imageWidth > 320) resMultiplier = 2.0;
        
        cropRect.origin.x = 0;
        cropRect.origin.y = 0;
        cropRect.size.width = minWidthTrigger * resMultiplier + padMargin * 2;
        cropRect.size.height = minHeight * resMultiplier + padMargin * 2;
        
        // Modify crop rect to expand to minimum height if it's especially wide
        // This is needed to keep MMS-pasted images from having a black area at
        //		the bottom of the image in the Messages app
        if (cropRect.size.height < minHeight * resMultiplier && cropRect.size.width > minWidthTrigger * resMultiplier) {
            CGFloat heightDifference = minHeight * resMultiplier - cropRect.size.height;
            CGFloat splitHeightDifference = floorf(heightDifference / 2.0);
            CGFloat spaceTop = cropRect.origin.y - 0;
            CGFloat spaceBottom = imageHeight - 1 - cropRect.size.height - cropRect.origin.y;
            if (spaceTop > spaceBottom) {
                if (spaceBottom >= splitHeightDifference) {
                    // There's enough room on both sides so add evenly
                    cropRect.origin.y = cropRect.origin.y - splitHeightDifference;
                    cropRect.size.height = cropRect.size.height + heightDifference;
                } else {
                    // Add the maximum available on the smaller side and the rest on the other side
                    CGFloat addBottom = imageHeight - cropRect.size.height - cropRect.origin.y;
                    cropRect.size.height = cropRect.size.height + heightDifference;
                    cropRect.origin.y = cropRect.origin.y - heightDifference + addBottom;
                }
            } else {
                if (spaceTop >= splitHeightDifference) {
                    // There's enough room on both sides so add evenly
                    cropRect.origin.y = cropRect.origin.y - splitHeightDifference;
                    cropRect.size.height = cropRect.size.height + heightDifference;
                } else {
                    // Add the maximum available on the smaller side and the rest on the other side
                    cropRect.origin.y = 0;
                    cropRect.size.height = cropRect.size.height + heightDifference;
                }
            }
        }
        
        // Crop the image and return it
        CGImageRef imageRef = CGImageCreateWithImageInRect([image CGImage], cropRect);
        return [UIImage imageWithCGImage:imageRef];
    } else {
        if (isImageAllMatching) {
            return nil;
        } else {
            return image;
        }
    }
}

+ (UIImage*) getSubImageFromImage:(UIImage *)image rectFrom:(CGRect) drawRect
{
    // Create Image Ref on Image
    CGImageRef imageRef = CGImageCreateWithImageInRect([image CGImage], drawRect);
    // Get Cropped Image
    UIImage *img = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    return img;
}


@end
