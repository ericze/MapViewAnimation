//
//  ViewController.h
//  MapViewAnimation
//
//  Created by wangZL on 16/8/25.
//  Copyright © 2016年 WangZeLin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "CoreAnimationController.h"
@interface ViewController : UIViewController


@end

@interface MapModel : NSObject
@property(nonatomic,assign)CLLocationCoordinate2D location2D;
@end