//
//  FirstViewController.m
//  Emotifont
//
//  Created by Boris Esanu on 2/3/17.
//  Copyright © 2017 Emotifont. All rights reserved.
//

#import "FirstViewController.h"

@interface FirstViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *imageviewGif;

@end

@implementation FirstViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSMutableArray *images = [[NSMutableArray alloc] init];
    for (NSInteger i = 0 ; i < 9 ; i ++){
        [images addObject:[UIImage imageNamed:[NSString stringWithFormat:@"launch-animation%ld", (long)i]]];
    }
    self.imageviewGif.animationImages = images;
    self.imageviewGif.image = images[images.count - 1];
    self.imageviewGif.animationRepeatCount = 1;
    self.imageviewGif.animationDuration = 5.f;
    [self.imageviewGif startAnimating];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5.f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        UIViewController * vc = [self.storyboard instantiateViewControllerWithIdentifier:@"EmotifontViewController"];
        [self.navigationController pushViewController:vc animated:YES];
    });
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
