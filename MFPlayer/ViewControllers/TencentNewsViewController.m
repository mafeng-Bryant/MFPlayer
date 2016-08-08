//
//  TencentNewsViewController.m
//  MFPlayer
//
//  Created by patpat on 16/8/4.
//  Copyright © 2016年 test. All rights reserved.
//

#import "TencentNewsViewController.h"
#import "VideoCell.h"
#import "VideoModel.h"
#import "MFPlayer.h"
#import "SidModel.h"

#define WS(weakSelf) __weak __typeof(&*self)weakSelf = self;

@interface TencentNewsViewController ()<UITableViewDelegate,UITableViewDataSource>
{
    NSMutableArray* _dataArray;
    MFPlayer* _mfPlayer;
}

@end

@implementation TencentNewsViewController

-(instancetype)init
{
    self = [super init];
    if (self) {
        _dataArray = [NSMutableArray array];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.tableView registerNib:[UINib nibWithNibName:@"VideoCell" bundle:nil] forCellReuseIdentifier:@"VideoCell"];
    [self addMJRefresh];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

}

#pragma mark Private method
- (void)addMJRefresh
{
    __weak __typeof(&*self)weakSelf = self;
     
  
    
    
    
    
    
    
    
    
    
    
    
    
    

}

#pragma mark UITableViewDelegate,UITableViewDataSource


-(BOOL)prefersStatusBarHidden
{
    if (_mfPlayer) {
        if (_mfPlayer.isFullScreen) {
            return YES;
        }else {
            return NO;
        }
    }else {
        return NO;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
