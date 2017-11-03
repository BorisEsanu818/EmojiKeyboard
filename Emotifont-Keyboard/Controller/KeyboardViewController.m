//
//  KeyboardViewController.m
//  Emotifont-Keyboard
//
//  Created by Boris Esanu on 10/12/17.
//  Copyright © 2017 Ricardo. All rights reserved.
//

#import "KeyboardViewController.h"
#import "KeyboardInputView.h"
#import "KeyboardView.h"
#import "Glyphpack.h"
#import "PurchaseController.h"

@import Firebase;

@interface KeyboardViewController ()<KeyboardInputDelegate>
    @property (nonatomic, strong) KeyboardInputView *keyboardInputView;
    @property (nonatomic, strong) KeyboardView *keyboardView;
    @property (nonatomic, strong) GlyphPack *glyphpack;
    @end

@implementation KeyboardViewController
    
    
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
    
    
- (void)viewDidLoad
    {
        [super viewDidLoad];
        
        [self setKeyboardInputView:[[[NSBundle mainBundle] loadNibNamed:@"KeyboardInputView" owner:nil options:nil] lastObject]];
        [self setInputView:[self keyboardInputView]];
        self.keyboardInputView.delegate = self;
        
        [[[self keyboardInputView] nextKeyboardButton] addTarget:self action:@selector(advanceToNextInputMode) forControlEvents:UIControlEventTouchUpInside];
        
        [[[self keyboardInputView] nextKeyboardButtonSmall] addTarget:self action:@selector(advanceToNextInputMode) forControlEvents:UIControlEventTouchUpInside];
        
        if (!_glyphpack) {
            
            [self.textDocumentProxy insertText:@"Test"];
            
        }
        
        LoadPurchasedIAPs();
        
        // register notification.
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshKeyboardAfter:) name:NOTI_NAME_REFRESH_KEYBOARD object:nil];
        
        // test code for getting current app identification.
        [self initialWithCurrentApp];
    }
    
- (void)initialWithCurrentApp{
    UIViewController * vc = self.parentViewController;
    if (vc){
        NSString* hostBundleID = [vc valueForKey:@"_hostBundleID"];
        if (hostBundleID){
            NSLog(@"hostBundleID: %@", hostBundleID);
            if ([hostBundleID isEqualToString:BOUNDLE_ID_INSTAGRAM]){
            }
        }
    }
}
    
- (void)viewWillAppear:(BOOL)animated
    {
        [super viewWillAppear:animated];
        
        CGFloat _expandedHeight = 216;
        [[self keyboardInputView] setHeightConstraint:[NSLayoutConstraint constraintWithItem:[self keyboardInputView] attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:0.0 constant:_expandedHeight]];
        [[[self keyboardInputView] heightConstraint] setPriority:999];
        [[self keyboardInputView] addConstraint:[[self keyboardInputView] heightConstraint]];
    }
    
- (void)selectionWillChange:(nullable id <UITextInput>)textInput{
    NSLog(@"selectionWillChange");
    
}
    
- (void)selectionDidChange:(nullable id <UITextInput>)textInput{
    NSLog(@"selectionDidChange");
    
}
    
- (void)textWillChange:(id<UITextInput>)textInput
    {
        // The app is about to change the document's contents. Perform any preparation here.
        NSLog(@"textWillChange");
    }
    
- (void)textDidChange:(id<UITextInput>)textInput
    {
        // The app has just changed the document's contents, the document context has been updated.
        NSLog(@"textDidChange");
        
        
        UIColor *textColor = nil;
        if (self.textDocumentProxy.keyboardAppearance == UIKeyboardAppearanceDark) {
            textColor = [UIColor whiteColor];
        } else {
            textColor = [UIColor blackColor];
        }
        
        if (self.keyboardInputView && self.keyboardInputView.keyboardView && self.keyboardInputView.heightConstraint.constant == 216.f){
            [self.keyboardInputView.keyboardView initializeCapital];
        }
    }
    
    
#pragma mark keyboardInput delegate
-(void)keyTapped:(NSString *)key{
    [self.textDocumentProxy insertText:key];
}
    
    
- (void)deletekeyTapped{
    [self.textDocumentProxy deleteBackward];
}
    
#pragma mark - NSNotification
-(void)refreshKeyboardAfter:(NSNotification *) noti{
    CGFloat delay = 0.f;
    if (noti.object){
        delay = [noti.object floatValue];
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        exit(0);
    });
}
    
    @end

