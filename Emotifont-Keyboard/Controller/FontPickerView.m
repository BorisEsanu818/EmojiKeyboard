//
//  FontPickerView.m
//  Emotifont
//
//  Created by Kevin Macaulay on 10/24/14.
//  Copyright (c) 2014 Emotifont. All rights reserved.
//
//
//  Modified by Category3 Studios 2017
//  Copyright (c) 2017 Emotifont

#import "FontPickerView.h"
#import "FontCell.h"
#import "GlyphPackBundle.h"
#import "PurchaseController.h"
#import "KeyboardInputview.h"
#import "GifCollectionCell.h"
#import <YYImage/YYImage.h>

@import YYImage;


@implementation FontPickerView
{
    NSArray *_fontListItems;
    CGSize _sizeCell;
    CGFloat _nColumnCount;
    NSMutableArray  *_gifPaths;
    NSMutableArray  *_gifDatas;
    NSMutableDictionary *_dicFontlist;
    NSArray *_bundleNames;
    NSArray *_categoryNames;
    NSArray *_categoryImageNames;
   
 }

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [self initialize];
    
}
- (void)initialize{

    // purchased IAPs
    LoadPurchasedIAPs();

    _bundleNames = @[@"Trending", @"Unclassified", @"ASU", @"University of Illinois", @"Ohio State", @"Syracuse",  @"Holiday"];
    _categoryNames = @[@"TRENDING", @"MOOD", @"ARIZONA STATE UNIVERSITY", @"UNIVERSITY OF ILLINOIS", @"THE OHIO STATE UNIVERSITY", @"SYRACUSE",  @"HOLIDAY", @"GIF"];
    _categoryImageNames = @[@"Trending-button(w)", @"Mood_Category_Button(w)", @"ASU-button", @"Illinois-button", @"OSU-button", @"Syracuse-button",  @"Holiday_Category_Button(w)", @"GIF_Category_Button"];


    // selection Scroll
    _selectionView.delegate = self;

    // category header
    [self setCateoryHeader:0];

    // font table view
    [[self tableView] registerNib:[UINib nibWithNibName:@"FontCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"FontCell"];
    [GlyphPack allGlyphPacks];
    _fontListItems = [[NSArray alloc]init];
    _dicFontlist = [[NSMutableDictionary alloc] init];
    [self setGlyphPackAllBundle];
    [[self segmentedControl] setSelectedSegmentIndex:EFSportsIndex];
    [[self segmentedControl] addTarget:self action:@selector(segmentedControlChanged:) forControlEvents:UIControlEventValueChanged];

    
    // Gif collection view
    [self.collectionView setNeedsLayout];
    [self.collectionView layoutIfNeeded];
    _nColumnCount = 2.0f;
    _sizeCell = [self calculateCellSize];
    [self.collectionView setDataSource:self];
    [self.collectionView setDelegate:self];
    [self.collectionView registerNib:[UINib nibWithNibName:@"GifCollectionCell" bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:@"GifCollectionCell"];
    
    NSArray * sortedPaths = [[[NSBundle mainBundle] pathsForResourcesOfType:@"gif" inDirectory:@"."] sortedArrayUsingSelector:@selector(localizedStandardCompare:)];
    _gifPaths = [[NSMutableArray alloc] initWithArray:sortedPaths];

    _gifDatas = [NSMutableArray array];
    for(NSString * path in _gifPaths){
        [_gifDatas addObject:[NSData dataWithContentsOfFile:path]];
    }
    [[PurchaseController sharedInstance] preloadProducts];
}

- (void)layoutSubviews{
    [super layoutSubviews];
    if (self.collectionView){
        _sizeCell = [self calculateCellSize];
        [self.collectionView reloadData];
    }
}

- (CGSize)calculateCellSize{
    
    CGSize sizeCell = CGSizeMake(0, 0);
    UICollectionViewFlowLayout  * layout = (UICollectionViewFlowLayout*)[self.collectionView collectionViewLayout];
    sizeCell.width = ([UIScreen mainScreen].bounds.size.width - 59 - (layout.minimumInteritemSpacing * (_nColumnCount - 1))) / _nColumnCount ;
    sizeCell.height = sizeCell.width * 250 / 305.f;
    
    return sizeCell;
}



- (void)setGlyphPackBundle:(GlyphPackBundle *)glyphPackBundle
{
    _glyphPackBundle = glyphPackBundle;
    
    if (glyphPackBundle == nil)
    {
        // Collect all glyph packs that are not part of a bundle, as well as all of the bundles.
        NSPredicate *unbundledPacks = [NSPredicate predicateWithFormat:@"bundle == NULL && name != %@", @"Text Hug"];
        NSMutableArray *items = [[[GlyphPack allGlyphPacks] filteredArrayUsingPredicate:unbundledPacks] mutableCopy];
        _fontListItems = SortedGlyphPacks(items);
    }
    else
    {
        _fontListItems = glyphPackBundle.glyphPacks;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
        
    });
}

- (void)setGlyphPackAllBundle
{
    NSMutableArray *arrAll = [[NSMutableArray alloc] init];

    for (NSString *bundleName in _bundleNames) {
        GlyphPackBundle *glyphPackBundle = [GlyphPackBundle bundleWithName:bundleName];
        
        if (glyphPackBundle == nil)
        {
            // Collect all glyph packs that are not part of a bundle, as well as all of the bundles.
            NSPredicate *unbundledPacks = [NSPredicate predicateWithFormat:@"bundle == NULL && name != %@", @"Text Hug"];
            NSMutableArray *items = [[[GlyphPack allGlyphPacks] filteredArrayUsingPredicate:unbundledPacks] mutableCopy];
            [_dicFontlist setObject:SortedGlyphPacks(items) forKey:bundleName];
            [arrAll addObjectsFromArray: SortedGlyphPacks(items)];
        }
        else
        {
            if ([bundleName isEqualToString:@"Trending"]){
                NSMutableArray * temp = [[NSMutableArray alloc] initWithArray:glyphPackBundle.glyphPacks];
                NSMutableArray * sortedArray = [[NSMutableArray alloc] init];
                
                for (GlyphPack * pack in temp){
                    if ([pack.name isEqualToString:@"Trump"]){
                        [sortedArray addObject:pack];
                        [temp removeObject:pack];
                        break;
                    }
                }
                for (GlyphPack * pack in temp){
                    if ([pack.name isEqualToString:@"White Castle"]){
                        [sortedArray addObject:pack];
                        [temp removeObject:pack];
                        break;
                    }
                }
                for (GlyphPack * pack in temp){
                    if ([pack.name isEqualToString:@"Medical Marijuana"]){
                        [sortedArray addObject:pack];
                        [temp removeObject:pack];
                        break;
                    }
                }
                [sortedArray addObjectsFromArray: temp];
                [_dicFontlist setObject:sortedArray forKey:bundleName];
                [arrAll addObjectsFromArray: sortedArray];
                
            }else{
                [_dicFontlist setObject:glyphPackBundle.glyphPacks forKey:bundleName];
                [arrAll addObjectsFromArray: glyphPackBundle.glyphPacks];
            }
        }
    }
    
    _fontListItems = arrAll;
    self.constraintHeightFontTableView.constant = [self heightCategory:_bundleNames.count - 1];
    [self.tableView reloadData];

}


// Font Selection Categories go here -JPM
// Currently only Holiday and Sports coded
// Not implementing segmented controls

- (void)segmentedControlChanged:(UISegmentedControl *)sender
{
    switch ([sender selectedSegmentIndex]) {
        case EFHolidayIndex:
        {
            [self setGlyphPackBundle:[GlyphPackBundle bundleWithName:@"Holiday"]];
            break;
        }
            
        case EFSportsIndex:
        {
            [self setGlyphPackBundle:[GlyphPackBundle bundleWithName:@"Ohio State"]];
            break;
        }
            
        default:
            [self setGlyphPackBundle:nil];
    }
}

#pragma mark - UITableView Data Source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_fontListItems count];
}

- (NSNumberFormatter *)currencyFormatterForLocale:(NSLocale *)locale
{
    static NSMutableDictionary *formatters;
    NSNumberFormatter *formatter;
    
    if (locale == nil)
    {
        locale = [NSLocale localeWithLocaleIdentifier:@"en-US"];
    }
    
    @synchronized (self)
    {
        if (formatters == nil)
        {
            formatters = [NSMutableDictionary dictionary];
        }
        
        formatter = formatters[locale];
        if (formatter == nil)
        {
            formatter = [[NSNumberFormatter alloc] init];
            formatter.numberStyle = NSNumberFormatterCurrencyStyle;
            formatter.locale = locale;
            formatters[locale] = formatter;
        }
    }
    
    return formatter;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    FontCell *cell = (FontCell *)[tableView dequeueReusableCellWithIdentifier:@"FontCell" forIndexPath:indexPath];
    if (!cell)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"FontCell" owner:self options:nil];
        
        cell = [nib lastObject];
    }
    
    id<FontListItem> item = _fontListItems[indexPath.row];
    
    cell.nameplateImageView.image = item.nameplateImage;
    cell.purchasedBadgeImageView.hidden = YES;
    cell.priceLabel.hidden = YES;
    cell.viewSeperator.hidden = YES;
    for (int i = 0 ; i < _bundleNames.count ; i ++){
        if (indexPath.row == [self countCellWithCategory:i] - 1){
            cell.viewSeperator.hidden = NO;
            break;
        }
    }
    
    if (item == [self selectedGlyphPack]) {
        [tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
    }
    
    BOOL purchased = NO;
    if ([item isKindOfClass:[GlyphPack class]])
    {
        GlyphPack *glyphPack = (GlyphPack *)item;
        purchased = (glyphPack.productID == nil && glyphPack.bundle == nil) ||  // no productID and not in a bundle
        ![glyphPack.productID hasPrefix:@"kb."] ||                           // productID contains "kb."
        [purchasedIAP containsObject:glyphPack.productID] ||                // productID has been purchased
        [purchasedIAP containsObject:glyphPack.bundle.productID];           // bundle has been purchased
        
    }
    else
    {
        purchased = [purchasedIAP containsObject:item.productID];
    }
    
    if (purchased)
    {
        cell.purchasedBadgeImageView.hidden = NO;
        cell.purchasedBadgeImageView.image = item.purchasedImage;
    }
    else
    {
        GlyphPack *glyphPack = (GlyphPack *)item;
        if (![glyphPack.bundle.name isEqualToString:@"Holiday"]){
            cell.priceLabel.hidden = NO;
            cell.priceLabel.text = @"99¢";
        }

    }
    
    return cell;
}

#pragma mark - Scroll View Buttons
- (IBAction)cateoryButtons:(UIButton*)sender {

    [self setCateoryHeader:sender.tag];
    
    CGFloat height = 0.f;
    if (sender.tag < _bundleNames.count){
        height = [self heightCategory:(sender.tag - 1)];
    }else{
        height = _tableView.frame.size.height;
    }
    
    [_selectionView setContentOffset:CGPointMake(0, height)];
}

- (NSInteger)countCellWithCategory:(NSInteger)tag{
    NSInteger count = 0;
    for (int i = 0 ; i <= tag ; i ++){
        count += ((NSArray*)[_dicFontlist objectForKey:_bundleNames[i]]).count;
    }
    return count;
}

- (CGFloat)heightCategory:(NSInteger)tag{
    CGFloat height = 0.f;
    NSInteger count = [self countCellWithCategory:tag];
    for (NSInteger i = 0 ; i < count ; i ++){
        GlyphPack *glyphPack = _fontListItems[i];
        height += glyphPack.nameplateImage.size.height + 2.0;
    }
    return height;
}

-(void) setCateoryHeader:(NSInteger) tag {
    _selectFontLabel.text = _categoryNames[tag];
    _categoryChosenImage.image = [UIImage imageNamed:_categoryImageNames[tag]];
    self.btnCategoryHeader.tag = tag;
    
    if (tag < _bundleNames.count){
        if ([_bundleNames[tag] isEqualToString:@"Holiday"]){
            self.labelAllFonts.text = @"All Fonts 0.99";
        }else{
            self.labelAllFonts.text = @"All Fonts 2.99";
        }
    }

    if ([self isPurchasedCateory:tag]){
        self.viewCategoryCost.hidden = YES;
        self.constraintHeightCategoryCost.constant = 0.f;
        
    }else{
        self.viewCategoryCost.hidden = NO;
        self.constraintHeightCategoryCost.constant = 20.f;
    }
    
    
}

#pragma mark - Font category hearder button
- (IBAction)categoryHeaderButton:(UIButton *)sender {
    if (![self isPurchasedCateory:sender.tag]){
        
        GlyphPackBundle *glyphPackBundle = [GlyphPackBundle bundleWithName:_bundleNames[sender.tag]];
        UIResponder *responder = self;
        while ((responder = [responder nextResponder]) != nil)
        {
            NSLog(@"responder = %@", responder);
            if([responder respondsToSelector:@selector(openURL:)] == YES)
            {
                NSUserDefaults *defaults = [[NSUserDefaults alloc] initWithSuiteName:ID_GROUP_DIRECTVC];
                [defaults setObject:@"purchase_vc" forKey:@"redirect"];
                [defaults setObject:STRING_FONT_PACKS forKey:KEY_PURCHASE_TYPE];
                [defaults setObject:glyphPackBundle.productID forKey:KEY_PRODUCT_ID];
                [responder performSelector:@selector(openURL:) withObject:[NSURL URLWithString:@"Emotifont://"]];
            }
        }
        
    }
    
}


- (BOOL) isPurchasedCateory:(NSInteger)tag{
    BOOL result = YES;
    if(tag > _bundleNames.count - 1)
        return result;

    GlyphPackBundle *glyphPackBundle = [GlyphPackBundle bundleWithName:_bundleNames[tag]];
    
    if (glyphPackBundle == nil)
        return result;
    
    if ([glyphPackBundle.name isEqualToString:@"Trending"])
        return result;
    
    BOOL purchased = NO;
    purchased = (glyphPackBundle.productID == nil) ||           // no productID
    ![glyphPackBundle.productID hasPrefix:@"kb."] ||            // productID contains "kb."
    [purchasedIAP containsObject:glyphPackBundle.productID];    // productID has been purchased
    
    if (purchased == NO)
    {
        purchased = YES;
        for (GlyphPack * pack in glyphPackBundle.glyphPacks) {
            if (![purchasedIAP containsObject:pack.productID]){
                purchased = NO;
                break;
            }
        }
    }
    result = purchased;

    return result;
}


#pragma mark - UITableView Delegate

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 52.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    GlyphPack *glyphPack = _fontListItems[indexPath.row];
    return glyphPack.nameplateImage.size.height + 2.0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    id<FontListItem> item = _fontListItems[indexPath.row];
    [self setSelectedGlyphPack:item];
    
    BOOL purchased = NO;
    if ([item isKindOfClass:[GlyphPack class]])
    {
        GlyphPack *glyphPack = (GlyphPack *)item;
        purchased = (glyphPack.productID == nil && glyphPack.bundle == nil) ||  // no productID and not in a bundle
        ![glyphPack.productID hasPrefix:@"kb."] ||                           // productID contains "kb."
        [purchasedIAP containsObject:glyphPack.productID] ||                // productID has been purchased
        [purchasedIAP containsObject:glyphPack.bundle.productID];           // bundle has been purchased
        
    }
    else
    {
        purchased = [purchasedIAP containsObject:item.productID];
    }
    
    if (purchased)
    {
        if ([[self delegate] respondsToSelector:@selector(glyphPackSelected:)]) {
            [[self delegate] glyphPackSelected:item];
        }
    }
    else
    {
        UIResponder *responder = self;
        while ((responder = [responder nextResponder]) != nil)
        {
            NSLog(@"responder = %@", responder);
            if([responder respondsToSelector:@selector(openURL:)] == YES)
            {
                GlyphPack *glyphPack = (GlyphPack *)item;
                
                NSUserDefaults *defaults = [[NSUserDefaults alloc] initWithSuiteName:ID_GROUP_DIRECTVC];
                [defaults setObject:@"purchase_vc" forKey:@"redirect"];
                if ([glyphPack.bundle.name isEqualToString:@"Holiday"]){
                    [defaults setObject:STRING_FONT_PACKS forKey:KEY_PURCHASE_TYPE];
                    [defaults setObject:glyphPack.bundle.productID forKey:KEY_PRODUCT_ID];
                }else{
                    [defaults setObject:STRING_SINGLE_FONT forKey:KEY_PURCHASE_TYPE];
                    [defaults setObject:glyphPack.productID forKey:KEY_PRODUCT_ID];
                }

                [responder performSelector:@selector(openURL:) withObject:[NSURL URLWithString:@"Emotifont://"]];
            }
        }
    }
    
}


- (void)scrollViewDidScroll:(UIScrollView *)sender{
   
    CGFloat yOffset = _selectionView.contentOffset.y;
    BOOL isGif = YES;
    for (int i = 0 ; i < _bundleNames.count ; i ++){
        if (yOffset < [self heightCategory:i]) {
            isGif = NO;
            [self setCateoryHeader:i];
            break;
        }
    }
    
    if(isGif == YES) {
        [self setCateoryHeader:_bundleNames.count];
    }
}

#pragma mark
#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _gifDatas.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath*)indexPath
{
    
    GifCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"GifCollectionCell" forIndexPath:indexPath];
    
    if(collectionView == self.collectionView){
        [cell.imageviewGif setRunloopMode:NSDefaultRunLoopMode];
    }
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    GifCollectionCell *cellGif = (GifCollectionCell *)cell;
    if (cellGif && [cellGif isKindOfClass:[GifCollectionCell class]]){
        if ([cellGif.imageviewGif isAnimating] == false){
            NSData * data = _gifDatas[indexPath.row];
            YYImage * gif = [YYImage imageWithData:data];
            [cellGif.imageviewGif setImage:gif];
            [cellGif.imageviewGif startAnimating];
        }

    }
}
- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath{
    GifCollectionCell *cellGif = (GifCollectionCell *)cell;
    if (cellGif && [cellGif isKindOfClass:[GifCollectionCell class]]){
        [cellGif.imageviewGif stopAnimating];
        [cellGif.imageviewGif setImage:nil];
    }
    
}


- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return _sizeCell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    [self animateZoomforCell:[collectionView cellForItemAtIndexPath:indexPath] index:indexPath];
}

- (void) pastGif:(NSIndexPath*) indexPath{

    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    NSData * data = _gifDatas[indexPath.row];
    NSString * message = STRING_EMOTIGIF_NOT_CORRECT;
    if (pasteboard && data){
        if ([self validateKeyboardHasFullAccess]){
            [pasteboard setData:data forPasteboardType:@"com.compuserve.gif"];
            message = STRING_NOW_PASTE_EMOTIGIF;
        }else{
            message = STRING_FULL_ACCESS_DENIED;
        }
    }
    
    [self showMessageView: message];
}

-(void)animateZoomforCell:(UICollectionViewCell*)zoomCell index:(NSIndexPath*) indexPath{
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        
        zoomCell.transform = CGAffineTransformMakeScale(1.2,1.2);
    } completion:^(BOOL finished){
        [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            
            zoomCell.transform = CGAffineTransformMakeScale(1,1);
        } completion:^(BOOL finished){
            [NSThread detachNewThreadSelector:@selector(pastGif:) toTarget:self withObject:indexPath];
        }];

    }];
}

- (void)showMessageView:(NSString*) message{
    if (message && [message stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length > 0){
        self.labelMessage.text = message;
    }else{
        self.labelMessage.text = STRING_NOW_PASTE_EMOTIGIF;
    }
    
    [UIView animateWithDuration:0.3 animations:^{
        [[self viewMessageBox] setAlpha:0.75];
        
    }];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self hideMessageView];
    });
}

- (void)hideMessageView
{
    [UIView animateWithDuration:0.3 animations:^{
        [[self viewMessageBox] setAlpha:0.0];
    }];
}

- (BOOL)validateKeyboardHasFullAccess {
    BOOL hasFullAccess = NO;
    NSString * originalString = [UIPasteboard generalPasteboard].string;
    [UIPasteboard generalPasteboard].string = @"TEST";
    if ([[UIPasteboard generalPasteboard] hasStrings])
    {
        if (originalString){
            [UIPasteboard generalPasteboard].string = originalString;
        }
        hasFullAccess = YES;
    }
    else
    {
        hasFullAccess = NO;
    }
    return hasFullAccess;
}


@end
