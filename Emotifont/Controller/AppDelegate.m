//
//  AppDelegate.m
//  Emotifont
//
//  Created by Boris Esanu on 10/12/17.
//  Copyright © 2017 Ricardo. All rights reserved.
//

#import "Emotifont-Swift.h"
#import "AppDelegate.h"
#import "GlyphPack.h"
#import "GlyphPackBundle.h"
#import "PurchaseController.h"
#import "MainNaviController.h"
#import "PurchaseConfirmVC.h"
#import "LeaderboardVC.h"

@interface AppDelegate ()
    
    @end

@implementation AppDelegate
    
- (id)init
    {
        if (self = [super init])
        {
            if ([FIRApp defaultApp] == nil) {
                
                [FIRApp configure];
                
            }
            
        }
        return self;
    }
    
    
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch
    
#if defined(DEBUG) && 1
    
    
#endif
    
    LoadPurchasedIAPs();
    [self redirectPage];
    [self synchronizeFireBase];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // Load the packs and bundles on the default background queue.
        NSArray *bundles = [GlyphPackBundle allBundles];
        NSArray *packs = [GlyphPack allGlyphPacks];
        NSLog(@"available packs %@", packs);
        NSLog(@"available bundles %@", bundles);
        
        NSMutableArray *assets = [NSMutableArray arrayWithArray:packs];
        [assets addObjectsFromArray:bundles];
        NSMutableArray *productIDs = [NSMutableArray array];
        for (id<FontListItem> item in assets)
        {
            NSString *productID = [item productID];
            if (productID)
            {
                [productIDs addObject:productID];
            }
        }
        // add a productID for Remove branding.
        [productIDs addObject:ID_REMOVE_BRANDING];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [PurchaseController sharedInstance].glyphPackBundleProductIDs = productIDs;
            [[PurchaseController sharedInstance] preloadProducts];
        });
    });
    
    return YES;
}
    
- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}
    
- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}
    
- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    [self redirectPage];
    [self synchronizeFireBase];
}
    
- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}
    
- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}
    
- (void) redirectPage{
    NSUserDefaults *defaults = [[NSUserDefaults alloc] initWithSuiteName:ID_GROUP_DIRECTVC];
    NSString *redirectPage = [defaults objectForKey:@"redirect"];
    
    if (redirectPage && redirectPage.length > 0){
        [defaults setObject:@"" forKey:@"redirect"];
        
        NSString * destVCName = nil;
        id className = nil;
        if ([redirectPage isEqualToString:@"purchase_vc"]) {
            destVCName = @"PurchaseConfirmVC";
            className = [PurchaseConfirmVC class];
        }
        else if ([redirectPage isEqualToString:@"profile_vc"]) {
            destVCName = @"ProfileVC";
            className = [ProfileVC class];
        }
        else if ([redirectPage isEqualToString:@"about_vc"]) {
            destVCName = @"AboutVC";
            className = [AboutVC class];
        }
        else if ([redirectPage isEqualToString:@"leaderboard_vc"]){
            destVCName = @"LeaderboardVC";
            className = [LeaderboardVC class];
        }
        if (className && destVCName){
            if(self.mainNavi){
                BOOL isExist = NO;
                for (UIViewController * vc in self.mainNavi.viewControllers){
                    if ([vc isKindOfClass:className]){
                        isExist = YES;
                        [self.mainNavi popToViewController:vc animated:NO];
                        break;
                    }
                }
                if(isExist == NO){
                    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
                    UIViewController* destVC = [mainStoryboard instantiateViewControllerWithIdentifier:destVCName];
                    if (destVCName){
                        [self.mainNavi popToRootViewControllerAnimated:NO];
                        [self.mainNavi pushViewController:destVC animated:NO];
                    }
                }
            }else{
                UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
                UINavigationController *main = [mainStoryboard instantiateViewControllerWithIdentifier:@"MainNaviController"];
                self.window.rootViewController = main;
                UIViewController *destVC = [mainStoryboard instantiateViewControllerWithIdentifier:destVCName];
                [main pushViewController:destVC animated:NO];
            }
            
        }
        
    }
}
    
-(void) synchronizeFireBase
    {
        NSUserDefaults *defaults = [[NSUserDefaults alloc] initWithSuiteName:ID_GROUP_DIRECTVC];
        NSMutableDictionary * fontUsage = [NSMutableDictionary dictionaryWithDictionary:[defaults objectForKey:KEY_FONT_USED]];
        FIRDatabaseReference * refFontUsed = [[[FIRDatabase database] reference] child:KEY_FONT_USED];
        
        for (NSString * keyFont in fontUsage.allKeys){
            
            NSMutableArray * itemFont = [NSMutableArray arrayWithArray:[fontUsage objectForKey:keyFont]];
            FIRDatabaseReference * refItemFont = [refFontUsed child:keyFont];
            
            for (NSInteger i = 0 ; i < itemFont.count ; i ++){
                
                NSMutableDictionary * user = [NSMutableDictionary dictionaryWithDictionary:itemFont[i]];
                NSInteger count = [[user objectForKey:KEY_COUNT] integerValue];
                
                if(count > 0){
                    
                    [[[refItemFont queryOrderedByChild:KEY_EMAIL] queryEqualToValue:[user objectForKey:KEY_EMAIL]]
                     observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot *snapshot){
                         
                         NSDictionary * updatedUser = nil;
                         FIRDatabaseReference * updatedUserRef = nil;
                         NSDictionary * userRefs = snapshot.value;
                         
                         if (userRefs && ![userRefs isKindOfClass:[NSNull class]] && userRefs.allKeys.count > 0){
                             
                             NSString * keyRefId = userRefs.allKeys.firstObject;
                             NSMutableDictionary * userRef =[NSMutableDictionary dictionaryWithDictionary:[userRefs objectForKey:keyRefId]];
                             NSInteger countNew = [[userRef objectForKey:KEY_COUNT] integerValue] + count;
                             userRef[KEY_COUNT] = @(countNew);
                             updatedUser = userRef;
                             updatedUserRef = [refItemFont child:keyRefId];
                         }else{
                             updatedUser = user;
                             updatedUserRef = [refItemFont childByAutoId];
                         }
                         
                         [updatedUserRef setValue:updatedUser withCompletionBlock:^(NSError *__nullable error, FIRDatabaseReference * ref){
                             if(error){
                                 NSLog(@"Failed data saving by error : %@", error.description);
                             }else{
                                 NSLog(@"Successed data saving");
                                 user[KEY_COUNT] = @(0);
                                 [itemFont replaceObjectAtIndex:i withObject:user];
                                 [fontUsage setObject:itemFont forKey:keyFont];
                                 [defaults setObject:fontUsage forKey:KEY_FONT_USED];
                                 [defaults synchronize];
                             }
                         }];
                         
                     }];
                    
                }
                
            }
            
        }
        
    }
    
    
 

@end
