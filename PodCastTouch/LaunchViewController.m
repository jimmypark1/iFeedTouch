//
//  LaunchViewController.m
//  PodCastTouch
//
//  Created by Park Jun Sung on 2016. 4. 19..
//  Copyright © 2016년 Junsoft. All rights reserved.
//

#import "LaunchViewController.h"

@implementation LaunchViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    UIImageView *imgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"launch_new"]];
    [self.view addSubview:imgView];
}

@end
