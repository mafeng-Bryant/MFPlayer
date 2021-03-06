//
//  MFRootTabBarController.m
//  MFPlayer
//
//  Created by patpat on 16/8/4.
//  Copyright © 2016年 test. All rights reserved.
//

#import "MFRootTabBarController.h"
#import "TencentNewsViewController.h"
#import "SinaViewController.h"
#import "NetEaseViewController.h"
#import "BaseNavigationController.h"
#import "PersonCenterViewController.h"

@interface MFRootTabBarController ()

@end

@implementation MFRootTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];

    TencentNewsViewController *tencentVC = [[TencentNewsViewController alloc]init];
    tencentVC.title = @"首页";
    
    BaseNavigationController *tencentNav = [[BaseNavigationController alloc]initWithRootViewController:tencentVC];
    tencentNav.tabBarItem = [[UITabBarItem alloc]initWithTitle:@"首页" image:[UIImage imageNamed:@"found@2x.png"] selectedImage:[UIImage imageNamed:@"found_s@2x.png"]];
    tencentNav.navigationBar.barTintColor = [UIColor redColor];
    
    
    
    SinaViewController *sinaVC = [[SinaViewController alloc]init];
    sinaVC.title = @"新浪视频";
    BaseNavigationController *sinaNav = [[BaseNavigationController alloc]initWithRootViewController:sinaVC];
    
    sinaNav.tabBarItem = [[UITabBarItem alloc]initWithTitle:@"新浪视频" image:[UIImage imageNamed:@"message@2x.png"] selectedImage:[UIImage imageNamed:@"message_s@2x.png"]];
    
    
    
    NetEaseViewController *netEaseVC = [[NetEaseViewController alloc]init];
    netEaseVC.title = @"网易视频";
    BaseNavigationController *netEaseNav = [[BaseNavigationController alloc]initWithRootViewController:netEaseVC];
    netEaseNav.tabBarItem = [[UITabBarItem alloc]initWithTitle:@"网易视频" image:[UIImage imageNamed:@"share@2x.png"] selectedImage:[UIImage imageNamed:@"share_s@2x.png"]];
    
    
    PersonCenterViewController *pcenterVC = [[PersonCenterViewController alloc]init];
    pcenterVC.title = @"我";
    BaseNavigationController *pcenterNav = [[BaseNavigationController alloc]initWithRootViewController:pcenterVC];
    pcenterNav.tabBarItem = [[UITabBarItem alloc]initWithTitle:@"测试" image:[UIImage imageNamed:@"tab_icon05"] selectedImage:[UIImage imageNamed:@"tab_icon05_on"]];
    self.viewControllers = @[tencentNav,sinaNav,netEaseNav,pcenterNav];
    
    
    self.tabBar.tintColor = [UIColor redColor];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
