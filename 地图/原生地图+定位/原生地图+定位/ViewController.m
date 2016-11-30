//
//  ViewController.m
//  原生地图+定位
//
//  Created by qianfeng on 15/9/26.
//  Copyright (c) 2015年 qianfeng. All rights reserved.
//

#import "ViewController.h"

// 地图框架
#import <MapKit/MapKit.h>

// 定位框架
#import <CoreLocation/CoreLocation.h>


@interface ViewController () <MKMapViewDelegate, CLLocationManagerDelegate>
{
    MKMapView         *_mapView;
    CLLocationManager *_manager; // 定位管理类
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 创建地图
    _mapView = [[MKMapView alloc] initWithFrame:self.view.bounds];
    
    [self.view addSubview:_mapView];
    
    // 设置地图样式
    /** MKMapTypeStandard 标准行政地图:街道，城市信息
        MKMapTypeSatellite 卫星地图:地形图
        MKMapTypeHybrid    混合地图:卫星图上显示城市,街道信息
     */
    _mapView.mapType = MKMapTypeStandard;
    
    // 经纬度
    // 纬度:31.384608
    // 经度:121.498218
    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(31.384608, 121.498218);
    
    // 缩放比例 : 参数越大,放大系数越大
    MKCoordinateSpan span = MKCoordinateSpanMake(0.5, 0.5);
    
    // 区域
    MKCoordinateRegion region = MKCoordinateRegionMake(coordinate, span);
    
    // 设置显示区域
    [_mapView setRegion:region animated:YES];
    
    // 设置是否可以缩放
    _mapView.zoomEnabled = YES;
    
    // 设置是否可以滑动
    _mapView.scrollEnabled = YES;
    
    // 设置是否可以旋转
    _mapView.rotateEnabled = YES;
    
    // 显示用户位置
    _mapView.showsUserLocation = YES;
    
    // 设置代理
    _mapView.delegate = self;
    
    // 初始化定位管理类
    _manager = [[CLLocationManager alloc] init];
    
    _manager.delegate = self;
    
    // iOS8需要添加如下代码
    if ([UIDevice currentDevice].systemVersion.floatValue >= 8.0) {
        [_manager requestAlwaysAuthorization]; // 请求一直定位
        [_manager requestWhenInUseAuthorization]; // 请求在使用中定位
    }
    
    // 开启定位
    [_manager startUpdatingLocation];
//    
//    // 添加大头针(标注)
//    MKPointAnnotation *anno = [[MKPointAnnotation alloc] init];
//    anno.coordinate = CLLocationCoordinate2DMake(31.4, 121.48);
//    anno.title = @"上海千锋";
//    anno.subtitle = @"移动互联网培训机构";
//    
//    // 将大头针添加到地图上
//    [_mapView addAnnotation:anno];
    
    // 添加长按手势
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
    
    // 将长按手势添加到地图上
    [_mapView addGestureRecognizer:longPress];
    
}

#pragma mark - MapView Delegate
#pragma mark 定制大头针
- (MKAnnotationView *)mapView1:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    // 不改变用户位置的大头针
    if ([annotation isKindOfClass:[MKUserLocation class]]) {
        return nil;
    }
    
    // 自带的大头针视图
    static NSString *ID = @"id";
    
    // 从复用池中取出是否有可用的大头针
    MKPinAnnotationView *pinAnnoView = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:ID];
    
    if (!pinAnnoView) {
        pinAnnoView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:ID];
    }
    
    // 设置颜色
    pinAnnoView.pinColor = MKPinAnnotationColorPurple;
    
    // 是否有掉落效果
    pinAnnoView.animatesDrop = YES;
    
    // 是否可以弹框
    pinAnnoView.canShowCallout = YES;
    
    // 左视图
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 40, 30)];
    label.textColor = [UIColor redColor];
    label.text = @"培训";
    pinAnnoView.leftCalloutAccessoryView = label;
    
    // 右视图
    pinAnnoView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    
    // 图片 : 图片无效
    // pinAnnoView.image = [UIImage imageNamed:@"marker.png"];
    
    return pinAnnoView;
}

#pragma mark 自定义图片大头针
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    // 不改变用户位置大头针
    if ([annotation isKindOfClass:[MKUserLocation class]]) {
        return nil;
    }
    
    static NSString *ID = @"id";
    
    // 从复用池取出是否有可用的大头针
    MKAnnotationView *annoView = [mapView dequeueReusableAnnotationViewWithIdentifier:ID];
    
    // 如果没有，自己创建
    if (!annoView) {
        annoView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:ID];
    }
    
    // 设置自定义图片
    annoView.image = [UIImage imageNamed:@"marker.png"];
    
    // 是否可以弹框
    annoView.canShowCallout = YES;
    
    return annoView;
}

#pragma mark - 手势方法
#pragma mark 长按手势
- (void)longPress :(UIGestureRecognizer *)gesRec {
    // 在长按手势开始的时候添加大头针
    if (gesRec.state != UIGestureRecognizerStateBegan) {
        return ;
    }
    
    // 获取长按所在点
    CGPoint point = [gesRec locationInView:_mapView];
    
    // 将点转换为坐标 CGPoint -> CLLocationCoordinate2D
    CLLocationCoordinate2D coordinate = [_mapView convertPoint:point toCoordinateFromView:_mapView];
    
    
    // 移除所有大头针
     [_mapView removeAnnotations:_mapView.annotations];
    
    // 移除指定的大头针
    for (MKPointAnnotation *anno in _mapView.annotations) {
        if ([anno.title isEqualToString:@"上海千锋"]) {
            continue ;
        }
        [_mapView removeAnnotation:anno];
    }
    
    // 创建大头针
    MKPointAnnotation *anno = [[MKPointAnnotation alloc] init];
    anno.title = @"标题";
    anno.subtitle = @"副标题";
    anno.coordinate = coordinate;
    
    // 将大头针添加到地图
    [_mapView addAnnotation:anno];
}

#pragma mark - CLLocationManager Delegate 
#pragma mark 定位成功
// iOS6及其以前的定位成功方法
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    NSLog(@"iOS6定位");
}

// iOS7及其以后定位成功方法
// 将所有更新的位置装在一个数组里面,最新的位置会在数组的第一位.
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    NSLog(@"定位成功");
    
    // 获取位置信息
    CLLocation *location = [locations firstObject];
    
    NSLog(@"经度:%f, 纬度:%f", location.coordinate.longitude, location.coordinate.latitude);
    
    // 反地理编码(逆地理编码):将位置信息转换为地理信息
    // 地理编码: 将地理信息转换为位置信息
    
    // 地理编码类
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    
    // 传入一个位置信息,通过block将地理信息返回
    [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
        
        if (error) {
            NSLog(@"反地理编码失败,地理信息不存在");
        }
        
        // 地理信息.
        CLPlacemark *placeMark = [placemarks firstObject];
        NSLog(@"address:%@", placeMark.addressDictionary);
        
    }];
    
    // 将地理信息转换为位置信息
    /* {
     FormattedAddressLines = [
     中国上海市黄浦区自忠路
     ],
     Street = 自忠路,
     Thoroughfare = 自忠路,
     Name = 中国上海市黄浦区自忠路,
     City = 上海市,
     Country = 中国,
     State = 上海市,
     SubLocality = 黄浦区,
     CountryCode = CN
     }

     
     */
    NSDictionary *dict = @{
    @"FormattedAddressLines" : @[@"中国上海市宝山区同济支路"],
    @"Street" : @"同济支路",
    @"Thoroughfare" : @"同济支路",
    @"Name" : @"中国上海市宝山区同济支路",
    @"City" : @"上海市",
    @"Country" : @"中国",
    @"State" : @"上海市",
    @"SubLocality" : @"宝山区",
    @"CountryCode" : @"CN"
    };
    
    CLGeocoder *geocoder1 = [[CLGeocoder alloc] init];
    [geocoder1 geocodeAddressDictionary:dict completionHandler:^(NSArray *placemarks, NSError *error) {
        if (error) {
            NSLog(@"地理编码失败:%@", error.localizedDescription);
        }
        
        CLPlacemark *placemark = [placemarks firstObject];
        
        NSLog(@"11经度:%f, 11纬度:%f",placemark.location.coordinate.longitude,  placemark.location.coordinate.latitude);
    }];
    
    // 添加大头针(标注)
    MKPointAnnotation *anno = [[MKPointAnnotation alloc] init];
    anno.coordinate = CLLocationCoordinate2DMake(location.coordinate.longitude, location.coordinate.latitude);
    anno.title = @"xxxxxx";
    anno.subtitle = @"xxxxxxxxxxx";
    
    // 将大头针添加到地图上
    [_mapView addAnnotation:anno];
    
    // 停止定位
    [_manager stopUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"定位失败");
}







@end
