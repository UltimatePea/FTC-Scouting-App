//
//  PlistViewerViewController.m
//  FTC Scouting
//
//  Created by Chen Zhibo on 3/19/15.
//  Copyright (c) 2015 Chen Zhibo. All rights reserved.
//

#import "PlistViewerViewController.h"

@interface PlistViewerViewController ()

@property (weak, nonatomic) IBOutlet UITextView *textView;


@end

@implementation PlistViewerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.textView.text = @"";
    [self.content enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        self.textView.text = [NSString stringWithFormat:@"%@%@：%@\r\n", self.textView.text, key, obj];
    }];
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

@end
