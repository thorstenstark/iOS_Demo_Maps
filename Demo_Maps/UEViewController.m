//
//  UEViewController.m
//  Demo_Maps
//
//  Created by Thorsten Stark on 25.06.14.
//  Copyright (c) 2014 Beuth Hochschule. All rights reserved.
//

#import "UEViewController.h"

@interface UEViewController ()

@end

@implementation UEViewController

CLLocationCoordinate2D targetCoordinates;
bool showHeading = NO;
CLLocationManager* locationManager;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    [self setUpMap];
    
}

-(void)setUpMap{
    // set the type of the map (standard, satellite, hybrid)
    self.mapView.mapType = MKMapTypeStandard;
    self.mapView.showsBuildings = YES;

    // define Region to display
    targetCoordinates = CLLocationCoordinate2DMake(52.516477,13.377688);
    
    
    MKCoordinateSpan span = MKCoordinateSpanMake(0.01, 0.01) ;
    MKCoordinateRegion region = MKCoordinateRegionMake(targetCoordinates, span);
    
    [_mapView setRegion:region];
    
    locationManager = [[CLLocationManager alloc] init];
    
}






-(void)showAnnotation{
    // create annotation
    MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
    annotation.title = @"Brandenburger Tor";
    annotation.subtitle = @"Berlin";
    annotation.coordinate = targetCoordinates;
    
    [self.mapView addAnnotation:annotation];
}







-(void)show3DView{
    MKMapCamera* myCamera = [MKMapCamera camera];
    myCamera.centerCoordinate = targetCoordinates; // coordinates the camera looks at
    myCamera.altitude = 300;  // height above ground
    myCamera.heading = 30;   // looking in which direction? 0-360
    myCamera.pitch = 70;     // view angle of the camera; 0 would be straight down
    
    // Assign the camera to your map view.
    self.mapView.camera = myCamera;
    
    
}






-(void)animateCamera{
    CLLocationCoordinate2D alexanderPlatzCoordinates = CLLocationCoordinate2DMake(52.520713, 13.409669);
    
    MKMapCamera* myCamera2 = [MKMapCamera camera];
    myCamera2.centerCoordinate = alexanderPlatzCoordinates;
    myCamera2.altitude = 300;
    myCamera2.heading = 180;
    myCamera2.pitch = 70;
    
    [UIView animateWithDuration:5.5  // lenght of the anoimation (5.5 sec)
                          delay:.5     // delay before the animation starts
                        options:UIViewAnimationOptionCurveEaseInOut      // animation options
                     animations:^{[self.mapView setCamera:myCamera2];}
                     completion:NULL];

}





-(void)showOverlay{
    // Define an overlay that covers Pariser Platz.
    CLLocationCoordinate2D  points[4];
    
    points[0] = CLLocationCoordinate2DMake(52.516769, 13.378033);
    points[1] = CLLocationCoordinate2DMake(52.516861, 13.379439);
    points[2] = CLLocationCoordinate2DMake(52.515960, 13.379611);
    points[3] = CLLocationCoordinate2DMake(52.515849, 13.378259);
    
    MKPolygon* poly = [MKPolygon polygonWithCoordinates:points count:4];
    poly.title = @"Pariser Platz";
    
    [self.mapView addOverlay:poly];
    [self.mapView setNeedsLayout];
    
}

-(void)showRoute{
    MKDirectionsRequest *request = [[MKDirectionsRequest alloc] init];

    // From where we want to start the route
    MKPlacemark* start = [[MKPlacemark alloc] initWithCoordinate:targetCoordinates addressDictionary:nil];
    request.source = [[MKMapItem alloc ]initWithPlacemark:start];

    // where it schould end
    MKPlacemark* end = [[MKPlacemark alloc] initWithCoordinate:CLLocationCoordinate2DMake(52.520713, 13.409669) addressDictionary:nil];
    request.destination = [[MKMapItem alloc ]initWithPlacemark:end];;
    
    request.requestsAlternateRoutes = YES;    // we want alternative routes if available
    
    MKDirections *directions =  [[MKDirections alloc] initWithRequest:request];
    
    [directions calculateDirectionsWithCompletionHandler: ^(MKDirectionsResponse *response, NSError *error) {
         if (error) {
             // Handle Error
             NSLog(@"Route Error");
         } else {
             [self showRoute:response];
         }
     }];
}

-(void)showRoute:(MKDirectionsResponse *)response
{
    // Draw the polyline for every route object in our response
    for (MKRoute *route in response.routes)
    {
        [self.mapView addOverlay:route.polyline level:MKOverlayLevelAboveRoads];
    }

    [self.mapView setNeedsLayout];
}



-(void)showUserLocation{
     // displays our position on the map as blue spot
    if ([locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [locationManager requestWhenInUseAuthorization];
    }
    
    self.mapView.showsUserLocation = YES; 
    
    [self.mapView setUserTrackingMode:MKUserTrackingModeFollow animated:YES];
}


-(void)showUserLocationWithHeading{
    // displays our position on the map as blue spot with a viewing angle
    if ([locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [locationManager requestWhenInUseAuthorization];
    }
    self.mapView.showsUserLocation = YES;
    
    [self.mapView setUserTrackingMode:MKUserTrackingModeFollowWithHeading animated:YES];
}




#pragma mark - MapViewDelegate methods

-(void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation {
    
    [self.mapView setCenterCoordinate:userLocation.coordinate animated:YES];
    
}




// define your own view to show as annotation with own image
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    // If the annotation is the user location, just return nil.
    if ([annotation isKindOfClass:[MKUserLocation class]])
        return nil;
    
    // Handle any custom annotations.
    if ([annotation isKindOfClass:[MKPointAnnotation class]])
    {
        // Try to dequeue an existing view first.
        MKAnnotationView*    annotationView = (MKAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:@"CustomAnnotationView"];
        
        if (!annotationView)
        {
            annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"CustomAnnotationView"];
           
            
            annotationView.canShowCallout = YES;                 // allow to show a callout when tapped
            annotationView.image = [UIImage imageNamed:@"pin_icon.png"];   // set your own image
            
            // calculate offset for image
            annotationView.centerOffset = CGPointMake( annotationView.centerOffset.x + annotationView.image.size.width/2, annotationView.centerOffset.y - annotationView.image.size.height/2 );
                    }
        else
            annotationView.annotation = annotation;
        
        return annotationView;
        
    }
    
    return nil;
}



// define your own view to show as overlay
- (MKOverlayRenderer *)mapView:(MKMapView *)mapView viewForOverlay:(id <MKOverlay>)overlay
{
    if ([overlay isKindOfClass:[MKPolygon class]]) // polygon for won shapes
    {
        MKPolygonRenderer* polygonRenderer = [[MKPolygonRenderer alloc] initWithPolygon:(MKPolygon*)overlay];
        
        polygonRenderer.fillColor = [[UIColor cyanColor] colorWithAlphaComponent:0.2];
        polygonRenderer.strokeColor = [[UIColor blueColor] colorWithAlphaComponent:0.7];
        polygonRenderer.lineWidth = 3;
        
        return polygonRenderer;
    }else if ([overlay isKindOfClass:[MKPolyline class]]){     // polyline i.e. for routes
        MKPolylineRenderer *renderer = [[MKPolylineRenderer alloc] initWithOverlay:overlay];
        renderer.strokeColor = [UIColor blueColor];
        renderer.lineWidth = 5.0;
        return renderer;
    }
    
    return nil;
}








#pragma mark - Memory Management

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Event Handler
- (IBAction)changeMapType:(UISegmentedControl *)sender {
    switch (sender.selectedSegmentIndex) {
        case 0:
            self.mapView.mapType = MKMapTypeStandard;
            break;
        case 1:
            self.mapView.mapType = MKMapTypeHybrid;
            break;
        case 2:
            self.mapView.mapType = MKMapTypeSatellite;
            break;
            
        default:
            break;
    }
    
}

- (IBAction)toggleAnnoatation:(id)sender {
    if(self.mapView.annotations.count > 0){
        [self.mapView removeAnnotations:self.mapView.annotations];
    }else{
        [self showAnnotation];

    }
    
}

- (IBAction)toggle3DView:(id)sender {
    [self show3DView];
}

- (IBAction)animateCamera:(id)sender {
    [self animateCamera];
}

- (IBAction)togleOverlay:(id)sender {
    if(self.mapView.overlays.count > 0){
        [self.mapView removeOverlays:self.mapView.overlays];
    }else{
        [self showOverlay];
        
    }
}

- (IBAction)toggleRoute:(id)sender {
    if(self.mapView.overlays.count > 0){
        [self.mapView removeOverlays:self.mapView.overlays];
    }else{
        [self showRoute];
    }
    
}

- (IBAction)changeUserLocationDisplay:(UISegmentedControl *)sender {
    switch (sender.selectedSegmentIndex) {
        case 0:
            [locationManager stopUpdatingLocation];
            self.mapView.showsUserLocation = NO;

            [self.mapView setUserTrackingMode:MKUserTrackingModeNone animated:NO];
            break;
        case 1:
            [self showUserLocation];
            break;
        case 2:
            [self showUserLocationWithHeading];
            break;
        default:
            break;
    }

    
}


@end
