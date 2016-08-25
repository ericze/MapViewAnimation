//
//  MKMapView+WZLExtension.h
//  Apin
//
//  Created by wangZL on 16/7/29.
//  Copyright © 2016年 Apin. All rights reserved.
//

#import <MapKit/MapKit.h>

@interface MKMapView (WZLExtension)
/**最大缩放级别:28*/
- (void)wzl_setCenterCoordinate:(CLLocationCoordinate2D)centerCoordinate
                  zoomLevel:(NSUInteger)zoomLevel
                   animated:(BOOL)animated;
@end
