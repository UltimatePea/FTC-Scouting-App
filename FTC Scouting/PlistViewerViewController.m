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
        if ([obj isKindOfClass:[NSDictionary class]]) {
            NSDictionary *dic = obj;
            [self addStringToTextView:[NSString stringWithFormat:@"%@:\r\n", key]];
            [dic enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                [self addStringToTextView:[NSString stringWithFormat:@"%@:%@\r\n", key, obj]];
            }];
        } else {
            [self addStringToTextView:[NSString stringWithFormat:@"%@:%@\r\n", key, obj]];
        }
    }];
}

- (void)addStringToTextView:(NSString *)string
{
    self.textView.text = [NSString stringWithFormat:@"%@%@", self.textView.text, string];
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
