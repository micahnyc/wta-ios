//
//  ViewController.h
//  wta-ios
//
//  Created by Micah Acinapura on 10/4/14.
//  Copyright (c) 2014 Micah Acinapura. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <MapKit/MapKit.h>
#import <AVFoundation/AVFoundation.h>
@interface ViewController : UIViewController <MKMapViewDelegate>

@property (nonatomic, strong) MKMapView *map;
@property (nonatomic, strong) NSDate *mapScrollingDelay;

@property (nonatomic, strong) NSArray *mapResults;
@property (nonatomic, strong) AVSpeechSynthesizer *speaker;

@end

