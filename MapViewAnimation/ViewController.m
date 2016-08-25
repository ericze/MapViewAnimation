//
//  ViewController.m
//  MapViewAnimation
//
//  Created by wangZL on 16/8/25.
//  Copyright © 2016年 WangZeLin. All rights reserved.
//

#import "ViewController.h"
#import "MKMapView+WZLExtension.h"
typedef enum : NSUInteger {
    RIGHT_TOP,
    LEFT_TOP,
    LEFT_BOTTOM,
    RIGHT_BOTTOM,
} DIRECTION;
@interface ViewController ()<MKMapViewDelegate>
{
    MKMapView *_mapView;
    CFTimeInterval _duration;
    UIImageView *_planeImage;
    CLLocationCoordinate2D * _coords;
    NSMutableArray *_dataArray;
    NSMutableArray *_timeArray;
    NSTimeInterval _sumTime;
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configMapView];
    [self configPlaneView];
    [self initTempData];
    [self calculateTime];
    [self addPolyLine];
    [self addSwitchBtn];
    [self addCoordinatePoint];
    [self mov];
}
-(void)addSwitchBtn{
    UIButton *switchBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [switchBtn setBackgroundImage:[UIImage imageNamed:@"Switch"] forState:UIControlStateNormal];
    switchBtn.frame = CGRectMake(KScreenWidth-70,KScreenHeight-70, 50, 50);
    [switchBtn addTarget:self action:@selector(switchAnimate) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:switchBtn];
}
-(void)switchAnimate{
    [self presentViewController:[[CoreAnimationController alloc] init] animated:YES completion:nil];
}
-(void)addCoordinatePoint{
    for (int i=0; i<_dataArray.count; i++) {
        MKPointAnnotation *pointAnnotation = [[MKPointAnnotation alloc] init];
        MapModel *model = _dataArray[i];
        pointAnnotation.coordinate = model.location2D;
        
        pointAnnotation.title = @"";
        pointAnnotation.subtitle = @"肯尼迪国际机场";
        [_mapView addAnnotation:pointAnnotation];
    }
}
- (void)mov{
    [[NSTimer scheduledTimerWithTimeInterval:_sumTime target:self selector:@selector(movePlane) userInfo:nil repeats:YES] fire];
}
-(void)movePlane{
    [self startAnimWithIndex:0];
}
-(void)addPolyLine{
    //构造大地曲线对象
    MKPolyline *geodesicPolyline = [MKPolyline polylineWithCoordinates:_coords count:_dataArray.count];
    
    [_mapView addOverlay:geodesicPolyline];
}
-(void)calculateTime{
    _timeArray = [NSMutableArray arrayWithCapacity:6];
    
    for (int i =0; i<_dataArray.count-1; i++) {
        MapModel *nowModel = _dataArray[i];
        MapModel *nextModel = _dataArray[i+1];
        //根据经纬度创建两个位置对象
        CLLocation *loc1=[[CLLocation alloc]initWithLatitude:nowModel.location2D.latitude longitude:nowModel.location2D.longitude];
        CLLocation *loc2=[[CLLocation alloc]initWithLatitude:nextModel.location2D.latitude longitude:nextModel.location2D.longitude];
        CLLocationDistance distance = [loc1 distanceFromLocation:loc2];
        NSLog(@"distance === %f",distance);
        if(distance/100000000>1){
            _timeArray[i] = @(20);
        }else if (distance/10000000>1) {
            _timeArray[i] = @(18);
        }else if (distance/1000000>1){
            _timeArray[i] = @(16);
        }else if(distance/100000>1){
            _timeArray[i] = @(13);
        }else if (distance/10000>1){
            _timeArray[i] = @(8);
        }else if (distance/1000>1){
            _timeArray[i] = @(6);
        }else{
            _timeArray[i] = @(0.001);
        }
        CFTimeInterval tempTime = [_timeArray[i] floatValue] + 1;
        _sumTime+=tempTime;
    }
}
#pragma mark - configMethod
-(void)configPlaneView{
    _planeImage = [UIImageView new];
    _planeImage.frame = CGRectMake((KScreenWidth-32)/2, (KScreenHeight-64-32)/2, 32, 32);
    _planeImage.image = [UIImage imageNamed:@"apin_plane"];
    //_planeImage.transform = CGAffineTransformMakeRotation((40.714352-30.287459f)/(120.153576+74.005973));
    [_mapView addSubview:_planeImage];
}
-(void)configMapView{
    // Do any additional setup after loading the view.
    _mapView = [[MKMapView alloc] initWithFrame:CGRectMake(0, 64, KScreenWidth, KScreenHeight-64)];
    _mapView.delegate = self;
    _mapView.rotateEnabled = YES;
    _mapView.zoomEnabled = NO;
    _mapView.scrollEnabled = NO;
    [_mapView showsUserLocation];
    //   [_mapView setZoomLevel:_mapView.minZoomLevel+2 animated:YES];
    [self.view addSubview:_mapView];
    [_mapView wzl_setCenterCoordinate:CLLocationCoordinate2DMake(30.3503933130, 120.1924251869) zoomLevel:5 animated:YES];
}

- (void)initTempData
{
    
    _dataArray = [NSMutableArray new];
    _coords = malloc(4*sizeof(CLLocationCoordinate2D));
    CLLocationCoordinate2D coodinateOne = CLLocationCoordinate2DMake(40.0550107248, 116.6147402007);
    _coords[0] = coodinateOne;
    CLLocationCoordinate2D coodinateTwo = CLLocationCoordinate2DMake(34.436143, 135.243227);
    _coords[1] = coodinateTwo;
    CLLocationCoordinate2D coodinateThree = CLLocationCoordinate2DMake(34.436143, 135.243227);
    _coords[2] = coodinateThree;
    CLLocationCoordinate2D coodinateFour = CLLocationCoordinate2DMake(49.0096906, 2.5479245);
    _coords[3] = coodinateFour;
    for (int i=0; i<4; i++) {
        MapModel *model = [MapModel new];
        model.location2D = _coords[i];
        [_dataArray addObject:model];
    }
}

-(void)startAnimWithIndex:(NSInteger)index{
    if (index == 0) {
        MapModel *model = _dataArray[0];
        [_mapView setCenterCoordinate:model.location2D animated:NO];
    }
    
    if (index>=_dataArray.count-1) {
        return;
    }
    MapModel *preModel = nil;
    MapModel *nowModel = _dataArray[index];
    MapModel *nextModel = _dataArray[index+1];
    DIRECTION preDir = LEFT_BOTTOM;
    DIRECTION nextDir = LEFT_BOTTOM;
    
    //根据经纬度创建两个位置对象
    CLLocation *loc1=[[CLLocation alloc]initWithLatitude:nowModel.location2D.latitude longitude:nowModel.location2D.longitude];
    CLLocation *loc2=[[CLLocation alloc]initWithLatitude:nextModel.location2D.latitude longitude:nextModel.location2D.longitude];
    CLLocationDistance distance = [loc1 distanceFromLocation:loc2];
    NSLog(@"distance === %f",distance);
    if(distance/100000000>1){
        [_mapView wzl_setCenterCoordinate:nowModel.location2D zoomLevel:1 animated:YES];
    }else if (distance/10000000>1) {
        [_mapView wzl_setCenterCoordinate:nowModel.location2D zoomLevel:2 animated:YES];
        
    }else if (distance/1000000>1){
        [_mapView wzl_setCenterCoordinate:nowModel.location2D zoomLevel:4 animated:YES];
    }else if(distance/100000>1){
        [_mapView wzl_setCenterCoordinate:nowModel.location2D zoomLevel:5 animated:YES];
    }else if (distance/10000>1){
        [_mapView wzl_setCenterCoordinate:nowModel.location2D zoomLevel:6 animated:YES];
    }else if (distance/1000>1){
        [_mapView wzl_setCenterCoordinate:nowModel.location2D zoomLevel:7 animated:YES];
    }
    CGFloat rotation = 0;
    CGPoint nowPoint = [_mapView convertCoordinate:nowModel.location2D toPointToView:_mapView];
    CGPoint nextPoint =[_mapView convertCoordinate:nextModel.location2D toPointToView:_mapView];
    
    if (index!=0) {
        preModel = _dataArray[index-1];
        CGPoint prePoint = [_mapView convertCoordinate:preModel.location2D toPointToView:_mapView];
        preDir = [self getdirStart:prePoint end:nowPoint];
        nextDir = [self getdirStart:nowPoint end:nextPoint];
        
    }
    
    rotation =atan2f((nowPoint.y-nextPoint.y),(nowPoint.x-nextPoint.x));
    __block typeof(self) blockSelf = self;
    [_planeImage.layer removeAllAnimations];
    [UIView animateWithDuration:1 animations:^{
        _planeImage.transform = CGAffineTransformMakeRotation(rotation);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:[_timeArray[index] floatValue] animations:^{
            _mapView.centerCoordinate = nextModel.location2D;
        } completion:^(BOOL finished) {
            [blockSelf startAnimWithIndex:index+1];
        }];
    }];
}

-(DIRECTION)getdirStart:(CGPoint)start2D end:(CGPoint)end2D{
    if (start2D.x<end2D.x) {
        //left
        if (start2D.y>end2D.y) {
            return LEFT_BOTTOM;
        }else{
            return LEFT_TOP;
        }
    }else{
        if (start2D.y>end2D.y) {
            return RIGHT_BOTTOM;
        }else{
            return RIGHT_TOP;
        }
    }
}

#pragma mark - mapViewDelegate
-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation{
    if ([annotation isKindOfClass:[MKPointAnnotation class]]) {
        static NSString *pointReuseIndentifier = @"pointReuseIndentifier";
        MKPinAnnotationView *annotationView = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:pointReuseIndentifier];
        if (annotationView == nil) {
            annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:pointReuseIndentifier];
        }
        //annotationView.image = [UIImage imageNamed:@"地图大头针"];
        annotationView.canShowCallout = YES;//设置气泡可以弹出
        annotationView.animatesDrop = YES;//设置标注动画显示
        annotationView.draggable = NO;//设置标注可以拖动
        
        //  annotationView.pinColor = MKPinAnnotationColorRed;
        return annotationView;
    }
    return nil;
}
- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id <MKOverlay>)overlay
{
    
    if ([overlay isKindOfClass:[MKPolyline class]])
    {
        MKPolylineRenderer *polylineRenderer = [[MKPolylineRenderer alloc] initWithPolyline:overlay];
        
        polylineRenderer.lineWidth   = 2.f;
        polylineRenderer.strokeColor = [UIColor colorWithRed:57/255.0 green:185/255.0 blue:227/255.0 alpha:1];
        
        return polylineRenderer;
    }
    return nil;
}
- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id<MKOverlay>)overlay {
    if ([overlay isKindOfClass:[MKPolyline class]])
    {
        MKPolylineView *lineview = [[MKPolylineView alloc] initWithOverlay:overlay];
        lineview.strokeColor = [[UIColor grayColor] colorWithAlphaComponent:0.5];
        lineview.lineWidth = 2;
        return lineview;
    }
    return nil;
}
@end



@implementation MapModel



@end
