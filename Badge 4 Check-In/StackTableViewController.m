//
//  StackTableViewController.m
//  Badge 4 Check-In
//
//  Created by Sergey Koval on 25/10/2016.
//  Copyright © 2016 Sergey Koval. All rights reserved.
//

#import "StackTableViewController.h"
#import <CoreLocation/CoreLocation.h>
#import "DetailViewController.h"
#import "UIImageView+WebCache.h"

#define IS_OS_8_OR_LATER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)

@interface StackTableViewController () <CLLocationManagerDelegate> {
    CLLocationManager *locationManager;
    NSNumberFormatter *numberFormatter;
    NSMutableArray *masterArray;
}

@end

@implementation StackTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Locations";
    masterArray = [NSMutableArray arrayWithArray:_mainData];
    
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
    
    numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setNumberStyle: NSNumberFormatterDecimalStyle];
    [numberFormatter setMaximumFractionDigits:1];
    [numberFormatter setGroupingSeparator:@"."];
    [numberFormatter setDecimalSeparator:@","];
    [numberFormatter setGroupingSize:3];
    [numberFormatter setUsesGroupingSeparator:YES];
    [numberFormatter setRoundingMode:NSNumberFormatterRoundHalfUp];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    
    for (NSUInteger j = 0; j < masterArray.count; j++) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:masterArray[j]];
        
        NSString *cellLatValue = [dict objectForKey:@"latitude"];
        NSString *cellLonValue = [dict objectForKey:@"longitude"];
        
        CLLocation * venueLocation = [[CLLocation alloc] initWithLatitude:[cellLatValue floatValue] longitude:[cellLonValue floatValue]];
        CLLocationDistance distanceMetersDouble = ([myLocation distanceFromLocation:venueLocation]) / 1000;
        NSString *distanceFinal = [numberFormatter stringFromNumber:[NSNumber numberWithDouble:distanceMetersDouble]];
        dict[@"distance"] = distanceFinal;
        [masterArray replaceObjectAtIndex:j withObject:dict];
    }
    
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return masterArray.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    cell.textLabel.text = masterArray[indexPath.row][@"title"];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"Collect %@ points --- %@ km from you", masterArray[indexPath.row][@"points"], masterArray[indexPath.row][@"distance"]];
    cell.imageView.image = [UIImage imageNamed:@"transparent-50"];
    
    UIImageView *thumbnail = [[UIImageView alloc] initWithFrame:CGRectMake(5, 5, 50, 50)];
    thumbnail.contentMode = UIViewContentModeScaleAspectFill;
    thumbnail.clipsToBounds = YES;
    [cell.contentView addSubview:thumbnail];
    NSString *url = masterArray[indexPath.row][@"image"];
    if (url != nil && [url length] > 0) {
        [thumbnail sd_setImageWithURL:[NSURL URLWithString:url]
                     placeholderImage:[UIImage imageNamed:@"placeholder.png"]
                            completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                thumbnail.alpha = 0.0;
                                thumbnail.image = image;
                                [UIView animateWithDuration:0.5
                                                 animations:^{
                                                     thumbnail.alpha = 1.0;
                                                 }];
                            }];
    } else {
        thumbnail.image = [UIImage imageNamed:@"placeholder.png"];
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self performSegueWithIdentifier:@"showLocationDetail" sender:indexPath];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"showLocationDetail"]) {
        NSIndexPath *indexPath = sender;
        DetailViewController *photoController = segue.destinationViewController;
        photoController.mainData = _mainData[indexPath.row];
    }
}

/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
 } else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }
 }
 */

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
