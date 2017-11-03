//
//  GifCollectionCell.h
//  Emotifont
//
//  Created by Boris Esanu on 1/26/17.
//  Copyright © 2017 Emotifont. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <YYImage/YYImage.h>


@interface GifCollectionCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet YYAnimatedImageView *imageviewGif;
@property (weak, nonatomic) IBOutlet UIView *viewContainer;

@end
