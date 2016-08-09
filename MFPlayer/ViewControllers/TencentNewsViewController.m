//
//  TencentNewsViewController.m
//  MFPlayer
//
//  Created by patpat on 16/8/4.
//  Copyright © 2016年 test. All rights reserved.
//

#import "TencentNewsViewController.h"
#import "AppDelegate.h"
#import "VideoCell.h"
#import "VideoModel.h"
#import "MFPlayer.h"
#import "SidModel.h"
#import "UIScrollView+MJRefresh.h"

#define WS(weakSelf) __weak __typeof(&*self)weakSelf = self;

#define kScreenWidth  [UIScreen mainScreen].bounds.size.width
#define kScreenHeight [UIScreen mainScreen].bounds.size.height
#define kDeviceVersion [[UIDevice currentDevice].systemVersion floatValue]

#define kNavbarHeight ((kDeviceVersion>=7.0)? 64 :44 )
#define kIOS7DELTA   ((kDeviceVersion>=7.0)? 20 :0 )
#define kTabBarHeight 49

@interface TencentNewsViewController ()<UITableViewDelegate,UITableViewDataSource>
{
    NSMutableArray* _dataArray;
    MFPlayer* _mfPlayer;
    NSIndexPath* _currentIndexPath;
}
@property(nonatomic,retain)VideoCell *currentCell;

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
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self performSelector:@selector(loadData) withObject:nil afterDelay:1.0];
}

#pragma mark UITableViewDelegate,UITableViewDataSource

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _dataArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 274.0f;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
   static NSString* identify = @"VideoCell";
    VideoCell* cell = (VideoCell*)[tableView dequeueReusableCellWithIdentifier:identify];
    cell.model = _dataArray[indexPath.row];
    [cell.playBtn addTarget:self action:@selector(startPlayVideo:) forControlEvents:UIControlEventTouchUpInside];
    cell.playBtn.tag = indexPath.row;
    if (_mfPlayer && _mfPlayer.superview) {
        if (_currentIndexPath.row == indexPath.row) {
            [cell.playBtn.superview sendSubviewToBack:cell.playBtn];
        }else {
            [cell.playBtn.superview bringSubviewToFront:cell.playBtn];
        }
        NSArray* visibleIndexPaths = [tableView indexPathsForVisibleRows];
        if (![visibleIndexPaths containsObject:_currentIndexPath] && _currentIndexPath != nil) {
          if ([[UIApplication sharedApplication].keyWindow.subviews containsObject:_mfPlayer]) {
                _mfPlayer.hidden = NO;
            }else{
                _mfPlayer.hidden = YES;
            }
        }else {
            if ([cell.backgroundIV.subviews containsObject:_mfPlayer]) {
                [_mfPlayer play];
                _mfPlayer.hidden = NO;
            }
      }
   }
    return cell;
}

#pragma mark Private method

- (void)loadData
{
    [_dataArray addObjectsFromArray:[AppDelegate shareAppDelegate].videoArray];
    [self.tableView reloadData];
}

- (void)startPlayVideo:(UIButton*)btn
{
    _currentIndexPath = [NSIndexPath indexPathForRow:btn.tag inSection:0];
    self.currentCell = (VideoCell*)btn.superview.superview;
    VideoModel* videoModel = _dataArray[btn.tag];
    if (_mfPlayer) {
        [self resertMFPlayer];
        _mfPlayer = [[MFPlayer alloc]initWithFrame:self.currentCell.backgroundIV.bounds];
        _mfPlayer.style = MFPlayerCloseBtnStyleClose;
        _mfPlayer.urlString = videoModel.mp4_url;
    }else {
        _mfPlayer = [[MFPlayer alloc]initWithFrame:self.currentCell.backgroundIV.bounds];
        _mfPlayer.style = MFPlayerCloseBtnStyleClose;
        _mfPlayer.titleLbl.text = videoModel.title;//标题
        _mfPlayer.urlString = videoModel.mp4_url;
    }
    [self.currentCell.backgroundIV addSubview:_mfPlayer];
    [self.currentCell.backgroundIV bringSubviewToFront:_mfPlayer];
    [self.currentCell.playBtn.superview sendSubviewToBack:self.currentCell.playBtn];
//    [self.tableView reloadData];
    [_mfPlayer play];
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView == self.tableView) {
        if (_mfPlayer ==nil) {
            return;
        }
        NSLog(@"height = %f",self.currentCell.backgroundIV.frame.size.height);
        NSLog(@"height = %f",kScreenHeight-kNavbarHeight-kTabBarHeight);
        if (_mfPlayer.superview) {
            CGRect rectInTableView = [self.tableView rectForRowAtIndexPath:_currentIndexPath];
            CGRect rectInSuperView = [self.tableView convertRect:rectInTableView toView:self.tableView.superview];
            NSLog(@"y = %f",rectInSuperView.origin.y);
            if (rectInSuperView.origin.y <-self.currentCell.backgroundIV.frame.size.height || rectInSuperView.origin.y > kScreenHeight - kNavbarHeight - kTabBarHeight) {
                [self resertMFPlayer];
                [self.currentCell.playBtn.superview bringSubviewToFront:self.currentCell.playBtn];
            }
        }
    }
}

//清除播放器
- (void)resertMFPlayer
{
    [_mfPlayer.player.currentItem cancelPendingSeeks];
    [_mfPlayer.player.currentItem.asset cancelLoading];
    [_mfPlayer pause];
    [_mfPlayer.player replaceCurrentItemWithPlayerItem:nil];
    _mfPlayer.currentPlayerItem = nil;
    [_mfPlayer.autoDismissTimer invalidate];
    _mfPlayer.autoDismissTimer = nil;
    _mfPlayer.playOrPauseBtn = nil;
    _mfPlayer.player = nil;
    [_mfPlayer.playerLayer removeFromSuperlayer];
    _mfPlayer.playerLayer = nil;
    [_mfPlayer removeFromSuperview];
    _mfPlayer = nil;
}

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
-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self resertMFPlayer];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
