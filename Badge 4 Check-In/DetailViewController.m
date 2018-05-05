//
//  DetailViewController.m
//  Badge 4 Check-In
//
//  Created by Sergey Koval on 26/10/2016.
//  Copyright © 2016 Sergey Koval. All rights reserved.
//

#import "DetailViewController.h"
#import "UIImageView+WebCache.h"
#import <CoreLocation/CoreLocation.h>

#define IS_OS_8_OR_LATER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)

@interface DetailViewController () <CLLocationManagerDelegate, UIAlertViewDelegate> {
    IBOutlet UIImageView *imageView;
    IBOutlet UITextView *textView;
    IBOutlet UILabel *titleLabel;
    IBOutlet UILabel *pointsLabel;
    CLLocationManager *locationManager;
}

@end

@implementation DetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Detail";
    
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
    titleLabel.text = _mainData[@"title"];
    pointsLabel.text = [NSString stringWithFormat:@"%@ points", _mainData[@"points"]];
    pointsLabel.layer.cornerRadius = 19;
    pointsLabel.layer.masksToBounds = YES;
    
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.distanceFilter = kCLDistanceFilterNone; // whenever we move
    locationManager.desiredAccuracy = kCLLocationAccuracyBest; // 100 m
    
    if(IS_OS_8_OR_LATER) {
        if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined) {
            [locationManager requestWhenInUseAuthorization];
        }
    }
    
    [locationManager startUpdatingLocation];
}

-(void)identifyProximity:(CLLocation*)location {
    NSString *cellLatValue = _mainData[@"latitude"];
    NSString *cellLonValue = _mainData[@"longitude"];
    
    CLLocation * venueLocation = [[CLLocation alloc] initWithLatitude:[cellLatValue floatValue] longitude:[cellLonValue floatValue]];
    CLLocationDistance distanceMetersDouble = ([location distanceFromLocation:venueLocation]) / 1000;
    NSLog(@"distanceMetersDouble = %f", distanceMetersDouble);
    if (distanceMetersDouble <= 200) {
        [[[UIAlertView alloc] initWithTitle:@"Attention" message:[NSString stringWithFormat:@"You are near this location and you can collect %@ points! Do you want to collect?", _mainData[@"points"]] delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Collect", nil] show];
    }
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        return;
    }
    else {
        [self collectPoints:nil];
    }
}

-(IBAction)collectPoints:(id)sender {
    NSUInteger points = [[NSUserDefaults standardUserDefaults] integerForKey:@"myCollectedPoints"];
    if (!points) {
        points = 0;
    }
    points = points + [_mainData[@"points"] integerValue];
    [[NSUserDefaults standardUserDefaults] setInteger:points forKey:@"myCollectedPoints"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [[[UIAlertView alloc] initWithTitle:@"Success" message:[NSString stringWithFormat:@"You collected %@ points!", _mainData[@"points"]] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
}

-(IBAction)share:(id)sender {
    [self shareText:_mainData[@"text"] andImage:_mainData[@"image"] andUrl:_mainData[@"url"]];
}

- (void)shareText:(NSString *)text andImage:(UIImage *)image andUrl:(NSURL *)url {
    NSMutableArray *sharingItems = [NSMutableArray new];
    if (text) {
        [sharingItems addObject:text];
    }
    if (image) {
        [sharingItems addObject:image];
    }
    if (url) {
        [sharingItems addObject:url];
    }
    UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:sharingItems applicationActivities:nil];
    [self presentViewController:activityController animated:YES completion:nil];
}

#pragma mark - CLLocation Delegate


- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    NSLog(@"didFailWithError: %@", error);
    [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Failed to Get Your Location" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    CLLocation *myLocation = [locations lastObject];
    [locationManager stopUpdatingLocation];
    locationManager.delegate = nil;
    locationManager = nil;
    
    [self identifyProximity:myLocation];
}

@end
