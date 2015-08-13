//
//  TeamDetailViewController.m
//  FTC Scouting
//
//  Created by Chen Zhibo on 3/21/15.
//  Copyright (c) 2015 Chen Zhibo. All rights reserved.
//

#import "TeamDetailViewController.h"
#import "HexagonView.h"

@interface TeamDetailViewController ()

@property (weak, nonatomic) IBOutlet HexagonView *hexagonView;
@property (weak, nonatomic) IBOutlet UILabel *autoDescendRampLbl;
@property (weak, nonatomic) IBOutlet UILabel *sixtyRollingGoalLbl;
@property (strong, nonatomic) NSString *oriTitle;

@end

@implementation TeamDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.hexagonView.values = self.hexagonValues;
    self.oriTitle = self.title;
    
    [self promptUserToRotate];
}

- (void)promptUserToRotate
{
    if (([[UIDevice currentDevice].model isEqualToString:@"iPhone"]||[[UIDevice currentDevice].model isEqualToString:@"iPod touch"])&&(!UIInterfaceOrientationIsLandscape(self.interfaceOrientation))) {
        self.title = @"Please rotate your device!";
//        [[[UIAlertView alloc] initWithTitle:@"Please rotate your device!" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
//        return;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [self.hexagonView setNeedsDisplay];
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    UIDeviceOrientation toInterfaceOrientation = [[UIDevice currentDevice] orientation];
    
    if (UIDeviceOrientationIsLandscape(toInterfaceOrientation)) {
        self.title = self.oriTitle;
    } else {
        [self promptUserToRotate];
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

//- (NSUInteger)supportedInterfaceOrientations
//{
//    if ([[UIDevice currentDevice].model isEqualToString:@"iPhone"]||[[UIDevice currentDevice].model isEqualToString:@"iPod touch"]) {
//        return UIInterfaceOrientationMaskLandscape;
//    } else {
//        return UIInterfaceOrientationMaskAllButUpsideDown;
//    }
//}
//
//- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
//{
//    if ([[UIDevice currentDevice].model isEqualToString:@"iPhone"]||[[UIDevice currentDevice].model isEqualToString:@"iPod touch"]) {
//        return UIInterfaceOrientationLandscapeLeft;
//    } else {
//        return [super preferredInterfaceOrientationForPresentation];
//    }
//}

@end
