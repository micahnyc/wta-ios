//
//  ViewController.m
//  wta-ios
//
//  Created by Micah Acinapura on 10/4/14.
//  Copyright (c) 2014 Micah Acinapura. All rights reserved.
//

#import "ViewController.h"
#import <CoreLocation/CoreLocation.h>


static const int kSmallHeight = 100;

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.map = [[MKMapView alloc] initWithFrame:CGRectZero];
    [self.view addSubview:self.map];
    self.map.delegate = self;
    self.map.showsUserLocation = YES;
    self.map.userTrackingMode = MKUserTrackingModeFollow;

    self.speaker = [[AVSpeechSynthesizer alloc] init];
    AVSpeechUtterance *utterance = [[AVSpeechUtterance alloc] initWithString:@""];
    [self.speaker speakUtterance:utterance];

    BOOL enabled = [CLLocationManager locationServicesEnabled];
    if (enabled) {
        CLLocationManager *locationManager = [[CLLocationManager alloc] init];
        [locationManager requestWhenInUseAuthorization];
        NSLog(@"req");
    } else {
        NSLog(@"no loc");
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [self layoutSubViews];
}

- (void)layoutSubViews {
    self.map.frame = self.view.frame;
}

#pragma mark - map
- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
    
    NSLog(@"date :%f",[self.mapScrollingDelay timeIntervalSinceNow]);
    if ([self.mapScrollingDelay timeIntervalSinceNow] < -1.0) {
        [self requestLocationsForCoordinate:self.map.centerCoordinate];
    } else {
        NSLog(@"not longe enuf");
        self.mapScrollingDelay = [NSDate date];
    }
    
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
    MKPointAnnotation *annotation = ((MKPinAnnotationView *)view).annotation;
    AVSpeechUtterance *utterance = [[AVSpeechUtterance alloc] initWithString:annotation.title];
    utterance.voice = [AVSpeechSynthesisVoice voiceWithLanguage:@"en-US"];
    utterance.rate = AVSpeechUtteranceDefaultSpeechRate / 4;
    [self.speaker speakUtterance:utterance];
}



#pragma mark -data
- (void)requestLocationsForCoordinate:(CLLocationCoordinate2D)coordinate {
    
    NSString *string = [NSString stringWithFormat:@"http://en.wikipedia.org/w/api.php?action=query&gslimit=10&list=geosearch&gsradius=10000&gscoord=%f%%7c%f&format=json",coordinate.latitude,coordinate.longitude];
    NSLog(@"get! %@",string);
    NSURL *url = [NSURL URLWithString:string];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    NSOperationQueue *queue = [NSOperationQueue mainQueue];
    [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if (connectionError) {
            NSLog(@"con err %@",connectionError);
        } else {
            NSError *e = nil;
            NSDictionary *resultDictionary = [NSJSONSerialization JSONObjectWithData: data options: NSJSONReadingMutableContainers error: &e];
            
            if ((e) || (!resultDictionary) || (!data)) {
                NSLog(@"Error parsing JSON: %@", e);
            } else {
                self.mapResults = [[resultDictionary objectForKey:@"query"] objectForKey:@"geosearch"];
                NSLog(@"got :%i",self.mapResults.count);
                [self showMapResults];
            }
        }
    }];
}

#pragma mark - internal
- (void)showMapResults {
    self.map.userTrackingMode = MKUserTrackingModeNone;

    [self.map removeAnnotations:self.map.annotations];
    NSMutableArray *annotations = [NSMutableArray array];
    for (NSDictionary *result in self.mapResults) {
        CLLocationCoordinate2D coord = CLLocationCoordinate2DMake([[result objectForKey:@"lat"] floatValue], [[result objectForKey:@"lon"] floatValue]);
        MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
        [annotation setCoordinate:coord];
        [annotation setTitle:[result objectForKey:@"title"]];
        [annotations addObject:annotation];
    }
    
    [self.map showAnnotations:annotations animated:YES];
    self.mapScrollingDelay = [NSDate date];

}


@end
