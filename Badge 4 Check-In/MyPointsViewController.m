//
//  MyPointsViewController.m
//  Badge 4 Check-In
//
//  Created by Sergey Koval on 26/10/2016.
//  Copyright © 2016 Sergey Koval. All rights reserved.
//

#import "MyPointsViewController.h"

@interface MyPointsViewController () {
    IBOutlet UILabel *pointsLabel;
}

@end

@implementation MyPointsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"My Points";
    
    pointsLabel.layer.cornerRadius = 100;
    pointsLabel.layer.masksToBounds = YES;
    pointsLabel.numberOfLines = 0;
    
    NSUInteger points = [[NSUserDefaults standardUserDefaults] integerForKey:@"myCollectedPoints"];
    if (points) {
        pointsLabel.text = [NSString stringWithFormat:@"%lu\npoints", (unsigned long)points];
    }
    else {
        pointsLabel.text = @"NO\npoints...";
    }
}

@end
