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

@interface TencentNewsViewController ()<UITableViewDelegate,UITableViewDataSource,MFPlayerDelegate>
{
    NSMutableArray* _dataArray;
    MFPlayer* _mfPlayer;
    NSIndexPath* _currentIndexPath;
}
@property(nonatomic,retain)VideoCell *currentCell;

@end

@implementation TencentNewsViewController

#pragma mark cicle
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
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
    //添加屏幕旋转通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onDeviceOrientationChange) name:UIDeviceOrientationDidChangeNotification object:nil];
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
        _mfPlayer.delegate = self;
        _mfPlayer.titleLbl.text = videoModel.title;//标题
        _mfPlayer.urlString = videoModel.mp4_url;
    }else {
        _mfPlayer = [[MFPlayer alloc]initWithFrame:self.currentCell.backgroundIV.bounds];
        _mfPlayer.style = MFPlayerCloseBtnStyleClose;
        _mfPlayer.delegate = self;
        _mfPlayer.titleLbl.text = videoModel.title;//标题
        _mfPlayer.urlString = videoModel.mp4_url;
    }
    [self.currentCell.backgroundIV addSubview:_mfPlayer];
    [self.currentCell.backgroundIV bringSubviewToFront:_mfPlayer];
    [self.currentCell.playBtn.superview sendSubviewToBack:self.currentCell.playBtn];
    [self.tableView reloadData];
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

- (void)autoTransFormDirection:(UIInterfaceOrientation)orientation
{
    [_mfPlayer removeFromSuperview];
    _mfPlayer.transform = CGAffineTransformIdentity;
    if (orientation == UIInterfaceOrientationLandscapeLeft) {
        _mfPlayer.transform = CGAffineTransformMakeRotation(-M_PI_2);
    }else if (orientation == UIInterfaceOrientationLandscapeRight) {
        _mfPlayer.transform = CGAffineTransformMakeRotation(M_PI_2);
    }
    _mfPlayer.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight);
    _mfPlayer.playerLayer.frame = CGRectMake(0, 0, kScreenHeight, kScreenWidth);
    
    // update Constraints bottomView
    [_mfPlayer.bottomView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(40);
        make.top.mas_equalTo(kScreenWidth-40);
        make.width.mas_equalTo(kScreenHeight);
    }];
    
    //topView
    [_mfPlayer.topView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(40);
        make.top.mas_equalTo(0);
        make.left.mas_equalTo(0);
        make.width.mas_equalTo(kScreenHeight);
    }];
    
    //closebtn
    [_mfPlayer.closeBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(30);
        make.width.mas_equalTo(30);
        make.left.equalTo(_mfPlayer).with.offset(5);
        make.top.equalTo(_mfPlayer).with.offset(5);
    }];
    
    //title label
    [_mfPlayer.titleLbl mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(_mfPlayer.topView);
    }];
    
    [_mfPlayer.loadingFailedLbl mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(kScreenHeight);
        make.center.mas_equalTo(CGPointMake(kScreenWidth/2-36, -(kScreenWidth/2 -36)));
        make.height.equalTo(@30);
    }];
    
    [_mfPlayer.loadingView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(CGPointMake(kScreenWidth/2-37, -(kScreenWidth/2-37)));
    }];
    
    
    [[UIApplication sharedApplication].keyWindow addSubview:_mfPlayer];
    _mfPlayer.fullScreenBtn.selected = YES;
    [_mfPlayer bringSubviewToFront:_mfPlayer.bottomView];
}

- (void)toCell
{
    VideoCell* cell = (VideoCell*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:_currentIndexPath.row inSection:0]];
    [_mfPlayer removeFromSuperview];
    [UIView animateWithDuration:0.25 animations:^{
        _mfPlayer.transform = CGAffineTransformIdentity;
        _mfPlayer.frame = cell.backgroundIV.bounds;
        _mfPlayer.playerLayer.frame = _mfPlayer.bounds;
        [cell.backgroundIV addSubview:_mfPlayer];
        [cell.backgroundIV bringSubviewToFront:_mfPlayer];
     [_mfPlayer.topView mas_remakeConstraints:^(MASConstraintMaker *make) {
         make.left.equalTo(_mfPlayer).with.offset(0);
         make.right.equalTo(_mfPlayer).with.offset(0);
         make.height.mas_equalTo(40);
         make.top.equalTo(_mfPlayer).with.offset(0);
     }];
      [_mfPlayer.bottomView mas_remakeConstraints:^(MASConstraintMaker *make) {
         make.left.equalTo(_mfPlayer).with.offset(0);
         make.right.equalTo(_mfPlayer).with.offset(0);
         make.height.mas_equalTo(40);
         make.bottom.equalTo(_mfPlayer).with.offset(0);
     }];
     [_mfPlayer.titleLbl mas_remakeConstraints:^(MASConstraintMaker *make) {
          make.left.equalTo(_mfPlayer.topView).with.offset(45);
          make.right.equalTo(_mfPlayer.topView).with.offset(-45);
          make.center.equalTo(_mfPlayer.topView);
          make.top.equalTo(_mfPlayer.topView).with.offset(0);
      }];
      [_mfPlayer.closeBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_mfPlayer).with.offset(5);
            make.height.mas_equalTo(30);
            make.width.mas_equalTo(30);
            make.top.equalTo(_mfPlayer).with.offset(5);
        }];
        [_mfPlayer.loadingFailedLbl mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(_mfPlayer);
            make.width.equalTo(_mfPlayer);
            make.height.equalTo(@30);
        }];
       } completion:^(BOOL finished) {
         _mfPlayer.isFullScreen = NO;
         [self setNeedsStatusBarAppearanceUpdate];
         _mfPlayer.fullScreenBtn.selected = NO;
    }];
}

#pragma mark UIScrollViewDelegate

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView == self.tableView) {
        if (_mfPlayer ==nil) {
            return;
        }
        if (_mfPlayer.superview) {
            CGRect rectInTableView = [self.tableView rectForRowAtIndexPath:_currentIndexPath];
            CGRect rectInSuperView = [self.tableView convertRect:rectInTableView toView:self.tableView.superview];
            if (rectInSuperView.origin.y <-self.currentCell.backgroundIV.frame.size.height || rectInSuperView.origin.y > kScreenHeight - kNavbarHeight - kTabBarHeight) {
                [self resertMFPlayer];
                [self.currentCell.playBtn.superview bringSubviewToFront:self.currentCell.playBtn];
            }
        }
    }
}

#pragma MFPlayerDelegate

- (void)mfPlayer:(MFPlayer*)player closeBtn:(UIButton*)btn;
{
    VideoCell* currentCell = (VideoCell*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:_currentIndexPath.row inSection:0]];
    [currentCell.playBtn.superview bringSubviewToFront:currentCell.playBtn];
    [self resertMFPlayer];
}

- (void)mfPlayer:(MFPlayer *)player clickFullScreen:(UIButton*)btn
{
    if (btn.isSelected) { //全屏显示
        _mfPlayer.isFullScreen = YES;
        [self setNeedsStatusBarAppearanceUpdate];
        [self autoTransFormDirection:UIInterfaceOrientationLandscapeLeft];
     }else {
         [self toCell];
    }
}

- (void)mfPlayer:(MFPlayer *)player playFinished:(id)finish
{
    VideoCell* currentCell = (VideoCell*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:_currentIndexPath.row inSection:0]];
    [currentCell.playBtn.superview bringSubviewToFront:currentCell.playBtn];
    [self resertMFPlayer];
    [self setNeedsStatusBarAppearanceUpdate];
}

#pragma mark notification
- (void)onDeviceOrientationChange
{
    if (_mfPlayer ==nil || _mfPlayer.superview ==nil) {
        return;
    }
    UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
    UIInterfaceOrientation direction = (UIInterfaceOrientation)orientation;
    //handle direction
    switch (direction) {
        case UIInterfaceOrientationLandscapeLeft:
        {
            _mfPlayer.isFullScreen = YES;
            [self setNeedsStatusBarAppearanceUpdate];
            [self autoTransFormDirection:direction];
        }
          break;
        case UIInterfaceOrientationLandscapeRight:
        {
            _mfPlayer.isFullScreen = YES;
            [self setNeedsStatusBarAppearanceUpdate];
            [self autoTransFormDirection:direction];
        }
           break;
       case UIInterfaceOrientationPortraitUpsideDown:
        {
            NSLog(@"状态栏向下");
        }
        break;
      case UIInterfaceOrientationPortrait:
        {
            if (_mfPlayer.isFullScreen) {
                [self toCell];
            }
        }
           break;
         default:
           break;
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
