//
//  ViewController.m
//  高德地图的使用
//
//  Created by qianfeng on 15/9/26.
//  Copyright (c) 2015年 qianfeng. All rights reserved.
//

#import "ViewController.h"

// 高德地图框架包
#import <AMapNaviKit/AMapNaviKit.h>

// 高德搜索api
#import <AMapSearchKit/AMapSearchAPI.h>

// bundle id @"com.qianfeng.gaodedemo"
#define APIKey @"f29177f8fe21029eed3a65e54d41c5af"

@interface ViewController () <MAMapViewDelegate, AMapSearchDelegate, AMapNaviManagerDelegate>
{
    MAMapView           *_mapView;
    
    AMapSearchAPI       *_searchAPI;
    
    UITextField         *_textField;
    
    AMapNaviManager     *_naviManager;
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 设置导航服务的apiKey
    [AMapNaviServices sharedServices].apiKey = APIKey;
    
    // 设置高德地图的apiKey
    [MAMapServices sharedServices].apiKey = APIKey;
    
    // 初始化导航管理类
    _naviManager = [[AMapNaviManager alloc] init];
    _naviManager.delegate = self;
    
    // 创建地图
    _mapView = [[MAMapView alloc] initWithFrame:self.view.bounds];
    
    [self.view addSubview:_mapView];
    
    // 坐标
    CLLocationCoordinate2D coordiante = CLLocationCoordinate2DMake(31.384608, 121.498218);
    
    // 比例
    MACoordinateSpan span = MACoordinateSpanMake(0.5, 0.5);
    
    MACoordinateRegion region = MACoordinateRegionMake(coordiante, span);
    
    // 设置显示区域
    [_mapView setRegion:region animated:YES];
    
    // 设置地图的类型
    /** MAMapTypeStandard       标准地图
        MAMapTypeSatellite      卫星地图
        MAMapTypeStandardNight  标准夜间地图
     */
    _mapView.mapType = MAMapTypeStandard;
    
    // 设置地图罗盘
    _mapView.showsCompass = NO;
    
    // 隐藏比例尺
    _mapView.showsScale = NO;
    
    // 显示交通线
    _mapView.showTraffic = NO;
    
    // 显示用户位置 : 开启定位
    _mapView.showsUserLocation = YES;
    
    _mapView.delegate = self;
    
    // 如果不实现自定义大头针的代理设置可以弹框,默认是不能弹框
    MAPointAnnotation *anno = [[MAPointAnnotation alloc] init];
    anno.coordinate = coordiante;
    anno.title = @"标题";
    anno.subtitle = @"副标题";
    
    [_mapView addAnnotation:anno];
    
    // 添加手势
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
    [_mapView addGestureRecognizer:longPress];
    
    
    // 初始化搜索API
    _searchAPI = [[AMapSearchAPI alloc] initWithSearchKey:APIKey Delegate:self];
    
    // 创建文本框
    _textField = [[UITextField alloc] initWithFrame:CGRectMake(10, 30, 250, 35)];
    _textField.borderStyle = UITextBorderStyleRoundedRect;
    _textField.placeholder = @"请输入搜索关键字..";
    [self.view addSubview:_textField];
    
    // 创建按钮
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(260, 30, 40, 35);
    [btn setTitle:@"搜索" forState:UIControlStateNormal];
    btn.backgroundColor = [UIColor orangeColor];
    [btn addTarget:self action:@selector(routeCal) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
}

#pragma mark 导航方法
- (void)routeCal
{
    [_textField resignFirstResponder];
    
    // 31.384608, 121.498218
    AMapNaviPoint *startPoint = [AMapNaviPoint locationWithLatitude:39.989614 longitude:116.481763];
    AMapNaviPoint *endPoint = [AMapNaviPoint locationWithLatitude:39.983456 longitude:116.315495];
    
    NSArray *startPoints = @[startPoint];
    NSArray *endPoints   = @[endPoint];
    
    //驾车路径规划（未设置途经点、导航策略为速度优先）
    [_naviManager calculateDriveRouteWithStartPoints:startPoints endPoints:endPoints wayPoints:nil drivingStrategy:0];

}

#pragma mark - 路径规划的代理方法
#pragma mark 路径规划失败
- (void)naviManager:(AMapNaviManager *)naviManager error:(NSError *)error
{
    NSLog(@"路径规划失败:%@",  error.localizedDescription);
}

- (void)naviManagerOnCalculateRouteSuccess:(AMapNaviManager *)naviManager {
    NSLog(@"路径规划成功");
}

#pragma mark 搜索
- (void)search {
    
    [_textField resignFirstResponder];
    
    if (0 ==  _textField.text.length) return;
    
    AMapPlaceSearchRequest *request = [[AMapPlaceSearchRequest alloc] init];
    
    // 设置搜索类型
    request.searchType = AMapSearchType_PlaceKeyword;
    
    // 设置搜索关键字
    request.keywords = _textField.text;
    
    // 设置搜索城市
    request.city = @[@"上海市"];
    
    // 开始搜索
    [_searchAPI AMapPlaceSearch:request];
}

#pragma mark - SearchAPI Delegate
#pragma mark 搜索成功
- (void)onPlaceSearchDone:(AMapPlaceSearchRequest *)request response:(AMapPlaceSearchResponse *)response {
    if (response) {
        NSLog(@"搜索成功");
        
        // AMapPOI 装载搜索信息
        NSArray *arr = response.pois;
        
        // 移除所有大头针
        [_mapView removeAnnotations:_mapView.annotations];
        
        for (AMapPOI *poi in arr) {
            NSString *name = poi.name;
            
            NSString *address = poi.address;
            
            CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(poi.location.latitude, poi.location.longitude);
            
            NSLog(@"name:%@, address:%@, longitude:%f, latitude:%f", name, address, coordinate.longitude, coordinate.latitude);
            
            MAPointAnnotation *anno = [[MAPointAnnotation alloc] init];
            anno.title = name;
            anno.subtitle = address;
            anno.coordinate = coordinate;
            
            [_mapView addAnnotation:anno];
        }
    }
}

#pragma mark 搜索失败
- (void)searchRequest:(id)request didFailWithError:(NSError *)error {
    NSLog(@"搜索失败:error:%@", error.localizedDescription);
}

#pragma mark 长按手势
- (void)longPress:(UILongPressGestureRecognizer *)rec {
    
    if (rec.state != UIGestureRecognizerStateBegan) {
        return ;
    }
    
    CGPoint point = [rec locationInView:_mapView];
    
    CLLocationCoordinate2D coordinate = [_mapView convertPoint:point toCoordinateFromView:_mapView];
    
    MAPointAnnotation *anno = [[MAPointAnnotation alloc] init];
    anno.title = @"新标题";
    anno.subtitle = @"新副标题";
    anno.coordinate = coordinate;
    
    [_mapView addAnnotation:anno];
}

#pragma mark - MapView Delegate
#pragma mark 定位成功
- (void)mapView:(MAMapView *)mapView didUpdateUserLocation:(MAUserLocation *)userLocation {
    
    CLLocation *location = userLocation.location;
    
    // 获取用户位置信息
    NSLog(@"经度:%f, 纬度:%f", location.coordinate.longitude, location.coordinate.latitude);
    
    // showsUserLocation设置为NO,会停止定位.
    _mapView.showsUserLocation = NO;
}

#pragma mark 定位失败
- (void)mapView:(MAMapView *)mapView didFailToLocateUserWithError:(NSError *)error
{
    NSLog(@"定位失败");
}

#pragma mark 自定义的大头针
- (MAAnnotationView *)mapView:(MAMapView *)mapView viewForAnnotation:(id<MAAnnotation>)annotation
{
    MAPinAnnotationView  *pinAnnoView = (MAPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:@"id"];
    
    if (!pinAnnoView) {
        pinAnnoView = [[MAPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"id"];
    }
    
    pinAnnoView.canShowCallout = YES;
    pinAnnoView.animatesDrop = YES;
    pinAnnoView.pinColor = MAPinAnnotationColorPurple;
    
    pinAnnoView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    
    return pinAnnoView;
    
    // MAAnnotationView
}


@end
