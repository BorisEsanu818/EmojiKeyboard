//
//  FontPickerView.h
//  Emotifont
//
//  Created by Kevin Macaulay on 10/24/14.
//  Copyright (c) 2014 Emotifont. All rights reserved.
//
//
//  Modified by Category3 Studios 2017
//  Copyright (c) 2017 Emotifont

#import <UIKit/UIKit.h>

typedef enum : NSUInteger
{
    EFMoodIndex,
    EFHolidayIndex,
    EFSportsIndex,
    EFBizIndex,
    EFCharityIndex,
} EFSegmentIndex;

@class GlyphPack, GlyphPackBundle;

@protocol GlyphPackPickerDelegate <NSObject>
- (void)glyphPackSelected:(GlyphPack*)glyphPack;
@end

@interface FontPickerView : UIView<UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) IBOutlet UISegmentedControl *segmentedControl;
@property (nonatomic, strong) IBOutlet UILabel *selectFontLabel;
@property (strong, nonatomic) IBOutlet UIScrollView *selectionView;
@property (strong, nonatomic) IBOutlet UIImageView *categoryChosenImage;
@property (weak, nonatomic) IBOutlet UIView *viewMessageBox;
@property (weak, nonatomic) IBOutlet UIButton *btnCategoryHeader;
@property (weak, nonatomic) IBOutlet UIView *viewCategoryCost;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintHeightCategoryCost;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintHeightFontTableView;
@property (weak, nonatomic) IBOutlet UILabel *labelAllFonts;
@property (weak, nonatomic) IBOutlet UILabel *labelMessage;

@property (nonatomic, strong) GlyphPackBundle *glyphPackBundle;
@property (nonatomic, strong) GlyphPack *selectedGlyphPack;
@property (nonatomic, assign) id<GlyphPackPickerDelegate> delegate;

@property (nonatomic, weak) NSString *fontCat; 

@end
