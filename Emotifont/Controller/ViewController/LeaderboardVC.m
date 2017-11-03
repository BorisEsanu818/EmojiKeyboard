//
//  LeaderboardVC.m
//  Emotifont
//
//  Created by Boris Esanu on 4/22/17.
//  Copyright © 2017 Emotifont. All rights reserved.
//

#import "LeaderboardVC.h"
#import "GlyphPackBundle.h"

@import Firebase;

@interface LeaderboardVC () <UITableViewDelegate, UITableViewDataSource>
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *collectBoardBtns;
@property (strong, nonatomic) IBOutletCollection(UIView) NSArray *collectBoardViews;
@property (weak, nonatomic) IBOutlet UITableView *tableviewTopEmotifonts;
@property (weak, nonatomic) IBOutlet UITableView *tableviewYourRank;
@property (weak, nonatomic) IBOutlet UILabel *labelYourRank;
@property (weak, nonatomic) IBOutlet UILabel *labelAwesome;
@property (weak, nonatomic) IBOutlet UILabel *labelUnit;
@property (weak, nonatomic) IBOutlet UILabel *labelYourTop10Emotifonts;


@property (strong, nonatomic) FIRDatabaseReference *ref;
@property (strong, nonatomic) NSMutableArray * dataYourRank;
@property (strong, nonatomic) NSMutableArray * dataTopEmotifonts;


@end

@implementation LeaderboardVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.dataYourRank = [NSMutableArray array];
    self.dataTopEmotifonts = [NSMutableArray array];

    [GlyphPack allGlyphPacks];
    [self updateUIWithTag:0];
    [self getCountsFromFireBase];
    
}

- (void) viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear: animated];
    if(self.ref){
        [self.ref removeAllObservers];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (IBAction)actionBoardBtns:(UIButton *)sender {
    [self updateUIWithTag:sender.tag];
}

- (void)updateUIWithTag:(NSInteger)tag{
    
    self.labelYourTop10Emotifonts.text = @"Please input your profile with Email";
    NSUserDefaults *defaults = [[NSUserDefaults alloc] initWithSuiteName:ID_GROUP_DIRECTVC];
    NSString * email = [defaults stringForKey:(KEY_EMAIL)];
    if (email!= nil){
        email = [email stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        if(![email isEqualToString:@""]){
            self.labelYourTop10Emotifonts.text = @"Your Top 10 Emotifonts";
        }
    }
    
    for(UIView * v in self.collectBoardViews){
        if(v.tag == tag){
            v.hidden = FALSE;
        }else{
            v.hidden = TRUE;
        }
    }
    
    for(UIButton * btn in self.collectBoardBtns){
        if(btn.tag == tag){
            [btn setBackgroundColor:UIColor.whiteColor];
            [btn setTitleColor:UIColor.grayColor forState:UIControlStateNormal];
            
        }else{
            [btn setBackgroundColor:UIColor.grayColor];
            [btn setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
        }
    }

}

#pragma mark - UITableView DataSource Delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (tableView == self.tableviewYourRank){
        return self.dataYourRank.count > 10 ? 10 : self.dataYourRank.count;
    }else if (tableView == self.tableviewTopEmotifonts){
        return self.dataTopEmotifonts.count;
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    GlyphPack *glyphPack = nil;
    
    if (tableView == self.tableviewYourRank){
        glyphPack = [self.dataYourRank[indexPath.row] objectForKey:KEY_FONT];
    }else if (tableView == self.tableviewTopEmotifonts){
        glyphPack = [self.dataTopEmotifonts[indexPath.row] objectForKey:KEY_FONT];
    }
    
    return glyphPack ? (glyphPack.nameplateImage.size.height + 2.0) : 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell * cell = nil;
    if (tableView == self.tableviewYourRank){
        cell = [tableView dequeueReusableCellWithIdentifier:@"FontCell" forIndexPath:indexPath];
        
        UILabel * labelIndex = [cell viewWithTag:1];
        labelIndex.text = [NSString stringWithFormat:@"%ld", indexPath.row + 1];
        UIImageView * imageView = [cell viewWithTag:3];
        imageView.image = [self.dataYourRank[indexPath.row][KEY_FONT] nameplateImage];
        
    }else if (tableView == self.tableviewTopEmotifonts){
        cell = [tableView dequeueReusableCellWithIdentifier:@"FontCell" forIndexPath:indexPath];

        UILabel * labelIndex = [cell viewWithTag:1];
        labelIndex.text = [NSString stringWithFormat:@"%ld", indexPath.row + 1];
        UIImageView * imageView = [cell viewWithTag:3];
        imageView.image = [self.dataTopEmotifonts[indexPath.row][KEY_FONT] nameplateImage];
        
        UILabel * labelCount = [cell viewWithTag:4];
        NSInteger totalCount = [self.dataTopEmotifonts[indexPath.row][KEY_COUNT] integerValue];
        NSString * stringUnit = @"";
        if (totalCount >= 1000000){
            stringUnit = @"M";
            totalCount = totalCount/1000000;
        }else if (totalCount >= 1000){
            stringUnit = @"K";
            totalCount = totalCount/1000;
        }
        labelCount.text = [NSString stringWithFormat:@"%ld%@", totalCount, stringUnit];

    }
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if(tableView == self.tableviewYourRank){
        [self updateYourRankLabel:indexPath.row];
    }
}

- (void) getCountsFromFireBase{
    
    self.ref = [[[FIRDatabase database] reference] child:KEY_FONT_USED];
    [self.ref observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot *snapshot){
        
        if(snapshot.value != [NSNull null]){
            
            NSDictionary * fontsUsed = snapshot.value;

            NSUserDefaults *defaults = [[NSUserDefaults alloc] initWithSuiteName:ID_GROUP_DIRECTVC];
            NSString * email = [defaults stringForKey:(KEY_EMAIL)];
            if (email == nil){
                email = @"";
            }
            email = [[email lowercaseString] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];

            NSMutableArray * originalData = [NSMutableArray array];
            
            for (NSString * keyFont in fontsUsed.allKeys){
                GlyphPack * font = [GlyphPackBundle fontWithName:keyFont];
                if (font){
                    NSDictionary * usedFont = fontsUsed[keyFont];
                    NSInteger totalCount = 0;
                    NSInteger userCount = 0;
                    NSMutableDictionary * fontdic = [NSMutableDictionary dictionaryWithDictionary:@{KEY_FONT : font,
                                                                                                    KEY_COUNT : @(totalCount),
                                                                                                    KEY_COUNT_USER : @(userCount)}];
                    
                    for (NSString * keyUserId in usedFont.allKeys){
                        NSDictionary * userInf = usedFont[keyUserId];
                        totalCount += [userInf[KEY_COUNT] integerValue];
                        
                        if (![email isEqualToString:@""] && [email isEqualToString:userInf[KEY_EMAIL]]){
                            userCount += [userInf[KEY_COUNT] integerValue];
                        }
                    }
                    fontdic[KEY_COUNT] = @(totalCount);
                    fontdic[KEY_COUNT_USER] = @(userCount);
                    [originalData addObject:fontdic];
                }
            }
            
            self.dataYourRank = [self sortBy:KEY_COUNT_USER origin:originalData];
            self.dataTopEmotifonts = [self sortBy:KEY_COUNT origin:originalData];
            [self refreshUI];
        }
    
    }];
}

- (NSMutableArray *)sortBy:(NSString *) key origin:(NSMutableArray *) data{
    NSMutableArray * sortedData = [NSMutableArray array];
    NSMutableArray * tempData = [NSMutableArray arrayWithArray:data];
    
    while(tempData.count > 0){
        NSMutableDictionary * fontdic = tempData[0];
        for (NSMutableDictionary * item in tempData){
            if([fontdic[key] integerValue] < [item[key] integerValue]){
                fontdic = item;
            }
        }
        if ([fontdic[key] integerValue] > 0){
            [sortedData addObject:fontdic];
        }
        [tempData removeObject:fontdic];
    }
    
    return sortedData;
}

- (void) refreshUI{
    
    [self.tableviewYourRank reloadData];
    [self.tableviewTopEmotifonts reloadData];
    
    NSIndexPath * indexYourRank = [self.tableviewYourRank indexPathForSelectedRow];
    NSIndexPath * indexTopEmotifonts = [self.tableviewYourRank indexPathForSelectedRow];
    indexYourRank = indexYourRank ? indexYourRank : [NSIndexPath indexPathForRow:0 inSection:0];
    indexTopEmotifonts = indexTopEmotifonts ? indexTopEmotifonts : [NSIndexPath indexPathForRow:0 inSection:0];
    
    [self.tableviewYourRank selectRowAtIndexPath:indexYourRank animated:NO scrollPosition:UITableViewScrollPositionNone];
    [self.tableviewYourRank selectRowAtIndexPath:indexTopEmotifonts animated:NO scrollPosition:UITableViewScrollPositionNone];
    [self updateYourRankLabel:indexYourRank.row];
}

- (void) updateYourRankLabel:(NSInteger) index {
    if (index < self.dataYourRank.count){
        NSDictionary * fontDic = self.dataYourRank[index];
        NSInteger totalCount = [fontDic[KEY_COUNT] integerValue];
        NSInteger userCount = [fontDic[KEY_COUNT_USER] integerValue];
        self.labelUnit.text = @"";
        if (totalCount >= 1000000){
            self.labelUnit.text = @"M";
            totalCount = totalCount/1000000;
        }else if (totalCount >= 1000){
            self.labelUnit.text = @"K";
            totalCount = totalCount/1000;
        }
        self.labelYourRank.text = [NSString stringWithFormat:@"%ld/%ld", userCount, totalCount];
    }
}

// test code
- (IBAction)actionConfigureFirebaseDB:(id)sender {
    
//    FIRStorage *storage = [FIRStorage storage];
    
    for (GlyphPackBundle *bundle in [GlyphPackBundle allBundles]) {
//        // File located on disk
//        NSURL *localFile = [NSURL URLWithString:@"path/to/image"];
//
//        // Create a reference to the file you want to upload
//        FIRStorageReference *riversRef = [storageRef child:@"images/rivers.jpg"];
//
//        // Upload the file to the path "images/rivers.jpg"
//        FIRStorageUploadTask *uploadTask = [riversRef putFile:localFile metadata:nil completion:^(FIRStorageMetadata *metadata, NSError *error) {
//            if (error != nil) {
//                // Uh-oh, an error occurred!
//            } else {
//                // Metadata contains file metadata such as size, content-type, and download URL.
//                NSURL *downloadURL = metadata.downloadURL;
//            }
//        }];
        
    }


}


@end
