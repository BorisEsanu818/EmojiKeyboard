//
//  FontCell.h
//  Emotifont
//
//  Created by Steve Madsen on 6/27/13.
//  Copyright (c) 2013 Emotifont, LLC. All rights reserved.
//
//
//  Modified by Category3 Studios 2017
//  Copyright (c) 2017 Emotifont

#import <UIKit/UIKit.h>

@interface FontCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *nameplateImageView;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (weak, nonatomic) IBOutlet UIImageView *purchasedBadgeImageView;
@property (weak, nonatomic) IBOutlet UIView *viewSeperator;

@end
