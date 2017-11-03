//
//  AppDelegate.h
//  Emotifont
//
//  Created by Boris Esanu on 10/12/17.
//  Copyright © 2017 Ricardo. All rights reserved.
//
#import <UIKit/UIKit.h>

@import Firebase;

#define APPDELEGATE     ((AppDelegate *)[UIApplication sharedApplication].delegate)

@interface AppDelegate : UIResponder <UIApplicationDelegate>
    
    @property (strong, nonatomic) UIWindow *window;
    @property (strong, nonatomic) UINavigationController * mainNavi;

@end

