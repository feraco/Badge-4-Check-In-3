//
//  LocationViewController.m
//  Badge 4 Check-In
//
//  Created by Sergey Koval on 25/10/2016.
//  Copyright © 2016 Sergey Koval. All rights reserved.
//

#import "LocationViewController.h"
#import "UIImageView+WebCache.h"
#import "StackTableViewController.h"

@interface LocationViewController () {
    IBOutlet UIImageView *imageView;
    IBOutlet UITextView *textView;
}

@end

@implementation LocationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = _mainData[@"title"];
    
    if (_mainData[@"image"] != nil && [_mainData[@"image"] length] > 0) {
        imageView.alpha = 0.0;
        [imageView sd_setImageWithURL:[NSURL URLWithString:_mainData[@"image"]]
                     placeholderImage:[UIImage imageNamed:@"placeholder.png"]
                            completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                imageView.image = image;
                                [UIView animateWithDuration:0.5
                                                 animations:^{
                                                     imageView.alpha = 1.0;
                                                 }];
                            }];
    } else {
        imageView.alpha = 1.0;
        imageView.image = [UIImage imageNamed:@"placeholder.png"];
    }
    
    textView.text = _mainData[@"text"];
}

-(IBAction)moreInfo:(id)sender {
    [self performSegueWithIdentifier:@"showLocationStack" sender:nil];
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"showLocationStack"]) {
        StackTableViewController *photoController = segue.destinationViewController;
        photoController.mainData = (NSArray*)_mainData[@"locations"];
    }
}

@end
