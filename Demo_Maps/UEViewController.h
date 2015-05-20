//
//  UEViewController.h
//  Demo_Maps
//
//  Created by Thorsten Stark on 25.06.14.
//  Copyright (c) 2014 Beuth Hochschule. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface UEViewController : UIViewController <MKMapViewDelegate>
@property (weak, nonatomic) IBOutlet MKMapView *mapView;

- (IBAction)changeMapType:(UISegmentedControl *)sender;
- (IBAction)toggleAnnoatation:(id)sender;
- (IBAction)toggle3DView:(id)sender;
- (IBAction)animateCamera:(id)sender;
- (IBAction)togleOverlay:(id)sender;
- (IBAction)toggleRoute:(id)sender;
- (IBAction)changeUserLocationDisplay:(UISegmentedControl *)sender;


@end
