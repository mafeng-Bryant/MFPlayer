//
//  MFPlayer.m
//  MFPlayer
//
//  Created by patpat on 16/8/4.
//  Copyright © 2016年 test. All rights reserved.
//

#import "MFPlayer.h"


#define MFPlayerSrcName(file) [@"MFPlayer.bundle" stringByAppendingPathComponent:file]
#define MFPlayerFrameworkSrcName(file) [@"Frameworks/MFPlayer.framework/MFPlayer.bundle" stringByAppendingPathComponent:file]
#define kHalfWidth        self.frame.size.width * 0.5
#define kHalfHeight       self.frame.size.height * 0.5


NSString* const kStatus                   = @"status";
NSString* const kLoadtimeRangesKey        = @"loadedTimeRanges";
NSString* const kPlaybackBufferEmpty      = @"playbackBufferEmpty";
NSString* const kPlaybackLikelyToKeepUp   = @"playbackLikelyToKeepUp";

static void *PlayViewCMTimeValue = &PlayViewCMTimeValue;

static void *AVPlayerPlayBackViewStatusObservationContext = &AVPlayerPlayBackViewStatusObservationContext;

@interface MFPlayer()<UIGestureRecognizerDelegate>
{

 
    
}
@property (nonatomic,strong) UISlider* lightSlider; //亮度的进度条，和屏幕的亮度一样
@property (nonatomic,strong) UISlider* volumeSlider;
@property (nonatomic,strong) UISlider* progressSlider;
@property (nonatomic,strong) UITapGestureRecognizer* tap;
@property (nonatomic,strong) UIProgressView* loadingProgress;
@property (nonatomic,strong) UILabel*  leftTimeLabel;
@property (nonatomic,strong) UILabel*  rightTimeLabel;
@property (nonatomic, strong)NSDateFormatter *dateFormatter;
@property (nonatomic, assign) BOOL isDragingSlider;//是否点击了按钮的响应事件

//播放器的监听者
@property (nonatomic,strong) id playObserve;

@end


@implementation MFPlayer
{
    UISlider* _systemSlider;
    UITapGestureRecognizer* _singleTap;
}


-(instancetype)init
{
    self = [super init];
    if (self) {
      [self initMFPlayer];
    }
    return self;
}

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initMFPlayer];
    }
    return self;
}

//初始化播放器类
- (void)initMFPlayer
{
     _isDragingSlider = NO;
    self.seekTime = 0.0;
    self.backgroundColor = [UIColor blackColor];
    //loading
    self.loadingView = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    [self addSubview:self.loadingView];
    [self.loadingView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self);
    }];
    
    //topview
    self.topView = [[UIView alloc]init];
    self.topView.backgroundColor = [UIColor colorWithWhite:0.4 alpha:0.4];
    [self addSubview:self.topView];
    [self.topView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).with.offset(0);
        make.left.equalTo(self).with.offset(0);
        make.right.equalTo(self).with.offset(0);
        make.height.mas_equalTo(40);
    }];
    
    //bottomView
    self.bottomView = [[UIView alloc]init];
    self.bottomView.backgroundColor = [UIColor colorWithWhite:0.4 alpha:0.4];
    [self addSubview:self.bottomView];
    [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).with.offset(0);
        make.right.equalTo(self).with.offset(0);
        make.bottom.equalTo(self).with.offset(0);
        make.height.mas_equalTo(40);
    }];
    
    //自动适应尺寸
    [self setAutoresizesSubviews:NO];
    
    //playOrPausebtn
    self.playOrPauseBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.playOrPauseBtn.showsTouchWhenHighlighted = YES;
    [self.playOrPauseBtn addTarget:self action:@selector(playOrPauseAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.playOrPauseBtn setImage:[UIImage imageNamed:MFPlayerSrcName(@"pause")] forState:UIControlStateNormal];
    [self.playOrPauseBtn setImage:[UIImage imageNamed:MFPlayerSrcName(@"play")] forState:UIControlStateSelected];
    [self.bottomView addSubview:self.playOrPauseBtn];
    [self.playOrPauseBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(40);
        make.height.mas_equalTo(40);
        make.left.equalTo(self.bottomView).with.offset(0);
        make.bottom.equalTo(self.bottomView).with.offset(0);
     }];
    
    //slider
    self.lightSlider = [[UISlider alloc]init];
    self.lightSlider.frame = CGRectMake(0, 0, 0, 0);
    self.lightSlider.minimumValue = 0.0;
    self.lightSlider.maximumValue = 1.0;
    self.lightSlider.hidden = YES;
    self.lightSlider.value = [UIScreen mainScreen].brightness;
    [self addSubview:self.lightSlider];
    
    //音量调节视图
    MPVolumeView* volumeView = [[MPVolumeView alloc]init];
    [self addSubview:volumeView];
    volumeView.frame = CGRectMake(-10000, -100, 100, 100);
    [volumeView sizeToFit];
    
    //system slider
    _systemSlider = [[UISlider alloc]init];
    _systemSlider.backgroundColor = [UIColor clearColor];
    for (UIView* view in volumeView.subviews) {
        if ([NSStringFromClass(view.classForCoder)  isEqualToString: @"MPVolumeSlider"]) {
            _systemSlider = (UISlider*)view;
        }
    }
    _systemSlider.autoresizesSubviews = NO;
    _systemSlider.autoresizingMask = UIViewAutoresizingNone;
    [self addSubview:_systemSlider];
    
    //slider change
    self.volumeSlider = [[UISlider alloc]initWithFrame:CGRectZero];
    self.volumeSlider.tag = 1000;
    self.volumeSlider.hidden = YES;
    self.volumeSlider.minimumValue = _systemSlider.minimumValue;
    self.volumeSlider.maximumValue = _systemSlider.maximumValue;
    self.volumeSlider.value = _systemSlider.value;
    [self.volumeSlider addTarget:self action:@selector(updateSystemVolumeValue:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.volumeSlider];
    
    
    //slider
    self.progressSlider = [[UISlider alloc]init];
    self.progressSlider.minimumValue = 0.0;
    [self.progressSlider setThumbImage:[UIImage imageNamed:MFPlayerSrcName(@"dot")] forState:UIControlStateNormal];
    self.progressSlider.minimumTrackTintColor = [UIColor greenColor];
    self.progressSlider.maximumTrackTintColor = [UIColor clearColor];
    self.progressSlider.value = 0.0;
    //进度条拖曳事件
    [self.progressSlider addTarget:self action:@selector(startDragSlider:) forControlEvents:UIControlEventValueChanged];
    [self.bottomView addSubview:self.progressSlider];
     self.progressSlider.backgroundColor = [UIColor clearColor];


    //autolayout slider
    [self.progressSlider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.bottomView).with.offset(45);
        make.right.equalTo(self.bottomView).with.offset(-45);
        make.center.equalTo(self.bottomView);
   }];
    
    
    self.loadingProgress = [[UIProgressView alloc]initWithProgressViewStyle:UIProgressViewStyleDefault];
    self.loadingProgress.progressTintColor = [UIColor clearColor];
    self.loadingProgress.trackTintColor = [UIColor lightGrayColor];
    [self.bottomView addSubview:self.loadingProgress];
    [self.loadingProgress setProgress:0.0 animated:NO];
    [self.loadingProgress mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.progressSlider);
        make.right.equalTo(self.progressSlider);
        make.center.equalTo(self.progressSlider);
    }];
    [self.bottomView sendSubviewToBack:self.loadingProgress];

    
    //fullbtn
    self.fullScreenBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.fullScreenBtn.showsTouchWhenHighlighted = YES;
    [self.fullScreenBtn addTarget:self action:@selector(fullScreenBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.fullScreenBtn setImage:[UIImage imageNamed:MFPlayerSrcName(@"fullscreen")] forState:UIControlStateNormal];
    [self.fullScreenBtn setImage:[UIImage imageNamed:MFPlayerSrcName(@"nonfullscreen")] forState:UIControlStateSelected];
    [self.bottomView addSubview:self.fullScreenBtn];
    [self.fullScreenBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.bottomView).with.offset(0);
        make.bottom.equalTo(self.bottomView).with.offset(0);
        make.width.mas_equalTo(40);
        make.height.mas_equalTo(40);
    }];
    
    //time label
    self.leftTimeLabel = [[UILabel alloc]init];
    self.leftTimeLabel.textAlignment = NSTextAlignmentLeft;
    self.leftTimeLabel.textColor = [UIColor whiteColor];
    self.leftTimeLabel.backgroundColor = [UIColor clearColor];
    self.leftTimeLabel.font = [UIFont systemFontOfSize:11];
    [self.bottomView addSubview:self.leftTimeLabel];
    //autoLayout timeLabel
    [self.leftTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.bottomView).with.offset(45);
        make.right.equalTo(self.bottomView).with.offset(-45);
        make.height.mas_equalTo(20);
        make.bottom.equalTo(self.bottomView).with.offset(0);
    }];
    
    //rightTimeLabel
    self.rightTimeLabel = [[UILabel alloc]init];
    self.rightTimeLabel.textAlignment = NSTextAlignmentRight;
    self.rightTimeLabel.textColor = [UIColor whiteColor];
    self.rightTimeLabel.backgroundColor = [UIColor clearColor];
    self.rightTimeLabel.font = [UIFont systemFontOfSize:11];
    [self.bottomView addSubview:self.rightTimeLabel];
    //autoLayout timeLabel
    [self.rightTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.bottomView).with.offset(45);
        make.right.equalTo(self.bottomView).with.offset(-45);
        make.height.mas_equalTo(20);
        make.bottom.equalTo(self.bottomView).with.offset(0);
    }];
    
    //_closeBtn
    _closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _closeBtn.showsTouchWhenHighlighted = YES;
    [_closeBtn addTarget:self action:@selector(colseTheVideo:) forControlEvents:UIControlEventTouchUpInside];
    [self.topView addSubview:_closeBtn];
    //autoLayout _closeBtn
    [self.closeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.topView).with.offset(5);
        make.height.mas_equalTo(30);
        make.top.equalTo(self.topView).with.offset(5);
        make.width.mas_equalTo(30);
        
    }];
    
    //titleLabel
    self.titleLbl = [[UILabel alloc]init];
    self.titleLbl.textAlignment = NSTextAlignmentCenter;
    self.titleLbl.textColor = [UIColor whiteColor];
    self.titleLbl.backgroundColor = [UIColor clearColor];
    self.titleLbl.font = [UIFont systemFontOfSize:17.0];
    [self.topView addSubview:self.titleLbl];
    //autoLayout titleLabel
    
    [self.titleLbl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.topView).with.offset(45);
        make.right.equalTo(self.topView).with.offset(-45);
        make.center.equalTo(self.topView);
        make.top.equalTo(self.topView).with.offset(0);
    }];

    [self bringSubviewToFront:self.loadingView];
    [self bringSubviewToFront:self.bottomView];
    
    // 单击的 Recognizer
    _singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    _singleTap.numberOfTapsRequired = 1; // 单击
    _singleTap.numberOfTouchesRequired = 1;
    [self addGestureRecognizer:_singleTap];
    
    [self addNotification];
}

#pragma mark Private methods

- (void)addNotification
{
    //监听是否触发home键挂起程序.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appwillResignActive:) name:UIApplicationWillResignActiveNotification object:nil];
    //监听是否重新进入程序程序.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive:)
                                                 name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
}

#pragma mark NSNotification

- (void)moviePlayDidEnd:(NSNotification*)noti
{
    self.state = MFPlayerStateFinished;
    if (self.delegate && [self.delegate respondsToSelector:@selector(mfPlayer:playFinished:)]) {
        [self.delegate mfPlayer:self playFinished:noti];
    }
    [self.player seekToTime:kCMTimeZero completionHandler:^(BOOL finished) {
        [self.progressSlider setValue:0.0 animated:YES];
        self.playOrPauseBtn.selected = YES;
    }];
    [UIView animateWithDuration:0.5 animations:^{
        self.bottomView.alpha = 1.0;
        self.topView.alpha = 1.0;
    }];
}

- (void)appwillResignActive:(NSNotification *)noti
{
    NSLog(@"appwillResignActive");
}
- (void)appBecomeActive:(NSNotification *)noti
{
    NSLog(@"appBecomeActive");
}

- (void)appDidEnterBackground:(NSNotification *)noti
{
    NSLog(@"appDidEnterBackground");
}
- (void)appWillEnterForeground:(NSNotification *)noti
{
    NSLog(@"appWillEnterForeground");
}

- (void)handleSingleTap:(UITapGestureRecognizer*)tap
{
   [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(autoDismissBottomView:) object:nil];
    [self.autoDismissTimer invalidate];
    self.autoDismissTimer = nil;
    self.autoDismissTimer = [NSTimer timerWithTimeInterval:5.0 target:self selector:@selector(autoDismissBottomView:) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:self.autoDismissTimer forMode:NSDefaultRunLoopMode];
    [UIView animateWithDuration:0.25 animations:^{
        if (self.topView.alpha ==0.0) {
            self.topView.alpha = 1.0;
            self.bottomView.alpha = 1.0;
            self.closeBtn.alpha = 1.0;
        }else if (self.topView.alpha ==1.0){
            self.topView.alpha = 0.0;
            self.bottomView.alpha = 0.0;
            self.closeBtn.alpha = 0.0;
        }
        } completion:^(BOOL finished) {
     }];
}

- (void)colseTheVideo:(UIButton*)btn
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(mfPlayer:closeBtn:)]) {
        [self.delegate mfPlayer:self closeBtn:btn];
    }
}

- (void)fullScreenBtnAction:(UIButton*)btn
{
    btn.selected = !btn.selected;
    if (self.delegate && [self.delegate respondsToSelector:@selector(mfPlayer:clickFullScreen:)]) {
        [self.delegate mfPlayer:self clickFullScreen:btn];
    }
}

- (void)playOrPauseAction:(UIButton*)btn
{
    if (self.player.rate != 1.0f) {
        if ([self currentPlayTime] == [self totalTime]) {
            [self setCurrentTime:0.0];
        }
         btn.selected = NO;
        [self.player play];
    }else {
        btn.selected = YES;
        [self.player pause];
    }
}

- (void)setCurrentTime:(double)time{
     dispatch_async(dispatch_get_main_queue(), ^{
         [self.player seekToTime:CMTimeMakeWithSeconds(time, self.currentPlayerItem.currentTime.timescale)];
     });
}

//获取视频当前播放的时间
- (double)currentPlayTime
{
    if (self.player) {
        return CMTimeGetSeconds([self.player currentTime]);
    }else {
        return 0.0f;
    }
 }

//获取视频的总时长
- (double)totalTime
{
    if (self.player) {
        AVPlayerItem* playerItem = self.player.currentItem;
        if (playerItem.status == AVPlayerItemStatusReadyToPlay) {
            return CMTimeGetSeconds([[playerItem asset] duration]);
        }else {
            return 0.0f;
        }
     }else {
        return 0.0f;
    }
}

- (void)updateSystemVolumeValue:(UISlider*)slider
{
  

}

- (void)startDragSlider:(UISlider*)slider
{
    self.isDragingSlider = YES;
}

#pragma mark set and get method

-(void)setUrlString:(NSString *)urlString
{
    _urlString = urlString;
    //使用playerItem获取视频的信息，当前播放时间，总时间等
    self.currentPlayerItem = [AVPlayerItem playerItemWithURL:[NSURL URLWithString:urlString]];
    self.player = [AVPlayer playerWithPlayerItem:self.currentPlayerItem];
    self.player.usesExternalPlaybackWhileExternalScreenIsActive = YES;
    self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
    self.playerLayer.frame = self.layer.bounds;
    self.playerLayer.videoGravity = AVLayerVideoGravityResize;
    [self.layer insertSublayer:self.playerLayer atIndex:0];
    self.state = MFPlayerStateBuffering;
    if (self.style == MFPlayerCloseBtnStylePop) {
        [_closeBtn setImage:[UIImage imageNamed:MFPlayerSrcName(@"play_back.png")] forState:UIControlStateNormal];
        [_closeBtn setImage:[UIImage imageNamed:MFPlayerSrcName(@"play_back.png")]  forState:UIControlStateSelected];
    }else {
        [_closeBtn setImage:[UIImage imageNamed:MFPlayerSrcName(@"close")] forState:UIControlStateNormal];
        [_closeBtn setImage:[UIImage imageNamed:MFPlayerSrcName(@"close")] forState:UIControlStateSelected];
    }
}

-(void)setCurrentPlayerItem:(AVPlayerItem *)currentPlayerItem
{
    if (_currentPlayerItem == currentPlayerItem) {
        return;
    }
    if (_currentPlayerItem) {
       [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:_currentPlayerItem];
        [_currentPlayerItem removeObserver:self forKeyPath:kStatus];
        [_currentPlayerItem removeObserver:self forKeyPath:kLoadtimeRangesKey];
        [_currentPlayerItem removeObserver:self forKeyPath:kPlaybackBufferEmpty];
        [_currentPlayerItem removeObserver:self forKeyPath:kPlaybackLikelyToKeepUp];
        _currentPlayerItem = nil;
    }
    _currentPlayerItem = currentPlayerItem;
    if (_currentPlayerItem) {
         [_currentPlayerItem addObserver:self forKeyPath:kStatus options:NSKeyValueObservingOptionNew context:AVPlayerPlayBackViewStatusObservationContext];
        [_currentPlayerItem addObserver:self forKeyPath:kLoadtimeRangesKey options:NSKeyValueObservingOptionNew context:AVPlayerPlayBackViewStatusObservationContext];
        //缓冲区数据为空
        [_currentPlayerItem addObserver:self forKeyPath:kPlaybackBufferEmpty options:NSKeyValueObservingOptionNew context:AVPlayerPlayBackViewStatusObservationContext];
        //缓冲区数据足够，可以播放了
        [_currentPlayerItem addObserver:self forKeyPath:kPlaybackLikelyToKeepUp options:NSKeyValueObservingOptionNew context:AVPlayerPlayBackViewStatusObservationContext];
        [self.player replaceCurrentItemWithPlayerItem:_currentPlayerItem];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moviePlayDidEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:_currentPlayerItem];
         }
}

-(UILabel *)loadingFailedLbl
{
    if (!_loadingFailedLbl) {
        _loadingFailedLbl = [[UILabel alloc]init];
        _loadingFailedLbl.textColor = [UIColor whiteColor];
        _loadingFailedLbl.textAlignment = NSTextAlignmentCenter;
        _loadingFailedLbl.text = @"视频加载失败";
        _loadingFailedLbl.hidden = YES;
        [self addSubview:_loadingFailedLbl];
        [_loadingFailedLbl mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self);
            make.width.equalTo(self);
            make.height.equalTo(@30);
        }];
    }
    return _loadingFailedLbl;
}

-(NSDateFormatter *)dateFormatter
{
    if (!_dateFormatter) {
        _dateFormatter = [[NSDateFormatter alloc]init];
    }
    return _dateFormatter;
}

#pragma mark KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context == AVPlayerPlayBackViewStatusObservationContext) {
        if ([keyPath isEqualToString:kStatus]) {
            AVPlayerStatus status = [[change objectForKey:NSKeyValueChangeNewKey] integerValue];
            switch (status) {
                {
                case AVPlayerStatusUnknown:
                    [self.loadingProgress setProgress:0.0 animated:NO];
                    self.state = MFPlayerStateBuffering;
                    [self.loadingView startAnimating];
                    break;
                }
                case AVPlayerStatusReadyToPlay:
                {
                    self.state = MFPlayerStateReadToPlay;
                    
                    if (CMTimeGetSeconds(_currentPlayerItem.duration)) {
                        double _x = CMTimeGetSeconds(_currentPlayerItem.duration);
                        if (!isnan(_x)) {
                            self.progressSlider.maximumValue = CMTimeGetSeconds(self.player.currentItem.duration);
                        }
                    }
        
                    //监听播放器状态
                    [self initTimer];
                    if (!self.autoDismissTimer) {
                        self.autoDismissTimer = [NSTimer timerWithTimeInterval:5.0 target:self selector:@selector(autoDismissBottomView:) userInfo:nil repeats:YES];
                        [[NSRunLoop currentRunLoop] addTimer:self.autoDismissTimer forMode:NSDefaultRunLoopMode];
                    }
                    [self.loadingView stopAnimating];
                    if (self.seekTime) {
                        [self seekToTimePlay:self.seekTime];
                    }
                    break;
                }
               case AVPlayerStatusFailed:
                {
                    self.state = MFPlayerStateFailed;
                    NSError *error = [self.player.currentItem error];
                    if (error) {
                        self.loadingFailedLbl.hidden = NO;
                        [self bringSubviewToFront:self.loadingFailedLbl];
                        [self.loadingView stopAnimating];
                    }
                    NSLog(@"error = %@",error.description);
                    break;
                }
                default:
                    break;
            }
      }else if ([keyPath isEqualToString:kLoadtimeRangesKey]){
          
            //计算缓冲进度
          NSTimeInterval timeInval = [self avaliableDuration];
          CMTime duration = self.currentPlayerItem.duration;
          CGFloat totalDuration = CMTimeGetSeconds(duration);
          //缓冲颜色设置
          self.loadingProgress.progressTintColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.7];
          [self.loadingProgress setProgress:(timeInval/totalDuration) animated:NO];
          
        }else if ([keyPath isEqualToString:kPlaybackBufferEmpty]){
             [self.loadingView startAnimating];
            if (self.currentPlayerItem.playbackBufferEmpty) {
                self.state = MFPlayerStateBuffering;
                [self loadTimeRanges];
            }
        }else if ([keyPath isEqualToString:kPlaybackLikelyToKeepUp]){
             [self.loadingView stopAnimating];
            if (self.currentPlayerItem.playbackLikelyToKeepUp && self.state ==MFPlayerStateBuffering) {
                self.state = MFPlayerStatePlaying;
            }
      }
    }
}

- (void)loadTimeRanges
{
    self.state = MFPlayerStateBuffering;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self play];
        [self.loadingView stopAnimating];
    });
}

//获取缓存总进度
- (NSTimeInterval)avaliableDuration
{
    NSArray* loadedTimeRanges = [_currentPlayerItem loadedTimeRanges];
    CMTimeRange timeRange = [loadedTimeRanges.firstObject CMTimeRangeValue];//本次缓冲时间范围
    float startSeconds = CMTimeGetSeconds(timeRange.start);
    float durationSeconds = CMTimeGetSeconds(timeRange.duration);
    NSTimeInterval totalBuffer = startSeconds + durationSeconds;
    NSLog(@"共缓冲: %.2f",totalBuffer);
    return totalBuffer;
}

//跳到xx秒播放视频
- (void)seekToTimePlay:(double)time
{
    if (self.player && self.player.currentItem.status == AVPlayerItemStatusReadyToPlay) {
        if (time > [self getMediaTotalTime]) {
            time = [self getMediaTotalTime];
        }else if (time <0){
            time = 0;
        }
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.player seekToTime:CMTimeMakeWithSeconds(time, self.currentPlayerItem.currentTime.timescale)];
    });
  }
}

- (CMTime)playItemDuration
{
    AVPlayerItem* playItem = _currentPlayerItem;
    if (playItem.status == AVPlayerItemStatusReadyToPlay) {
        return [playItem duration];
    }
    return (kCMTimeInvalid);
}

- (void)initTimer
{
    double interval = 1.0;
    CMTime time = [self playItemDuration];
     if (CMTIME_IS_INVALID(time)) {
        return ;
    }
    
    double duration = CMTimeGetSeconds(time);
    if (isfinite(duration)) {
        CGFloat width = CGRectGetWidth([self.progressSlider bounds]);
        interval = 0.5f * duration / width;
    }
    
    __weak typeof(self) weakSelf = self;
    self.playObserve = [weakSelf.player addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(1.0, NSEC_PER_SEC) queue:NULL usingBlock:^(CMTime time) {
        [weakSelf syncScrubber];
     }];
}

- (NSString*)showTime:(CGFloat)time
{
    NSDate* date = [NSDate dateWithTimeIntervalSince1970:time];
    if (time /3600 > 1) {
        [[self dateFormatter] setDateFormat:@"HH:mm:ss"];
    }else {
        [[self dateFormatter] setDateFormat:@"mm:ss"];
     }
    NSString* nowTime = [[self dateFormatter] stringFromDate:date];
    return nowTime;
}

- (void)syncScrubber
{
    CMTime playerDuration = [self playItemDuration];
    if (CMTIME_IS_INVALID(playerDuration)) {
        self.progressSlider.minimumValue = 0.0f;
        return ;
    }
    double duration = CMTimeGetSeconds(playerDuration);
    if (isfinite(duration)) {
        float minValue = [self.progressSlider minimumValue];
        float maxValue = [self.progressSlider maximumValue];
        double nowTime = CMTimeGetSeconds([self.player currentTime]);
        self.leftTimeLabel.text = [self showTime:nowTime];
        self.rightTimeLabel.text = [self showTime:duration];
        if (self.isDragingSlider) {
            
        }else {
            [self.progressSlider setValue:(maxValue - minValue) * nowTime / duration + minValue];
        }
    }
}

- (double)getMediaTotalTime
{
    AVPlayerItem* item = self.player.currentItem;
    if (item.status == AVPlayerItemStatusReadyToPlay) {
        return CMTimeGetSeconds([[item asset] duration]);
    }
    return 0.0f;
}

- (void)autoDismissBottomView:(NSTimer*)timer
{
    //播放状态
    if (self.player.rate == 1.0f) {
        if (self.bottomView.alpha == 1.0) {
          [UIView animateWithDuration:0.25 animations:^{
              self.bottomView.alpha = 0.0;
              self.topView.alpha = 0.0;
              self.closeBtn.alpha = 0.0;
            }];
        }
    }
}

-(void)setState:(MFPlayerState)state
{
    _state = state;
    if (state == MFPlayerStateBuffering) {
        [self.loadingView startAnimating];
    }else if (state ==MFPlayerStatePlaying){
        [self.loadingView stopAnimating];
    }else if (state == MFPlayerStateReadToPlay){
        [self.loadingView stopAnimating];
    }else {
        [self.loadingView stopAnimating];
    }
}

#pragma Public methods
- (void)play
{
    [self playOrPauseAction:self.playOrPauseBtn];
}

- (void)pause
{
    [self playOrPauseAction:self.playOrPauseBtn];
}

- (double)playingTime
{
    return 0.2;
}

- (void)resetMFPlayer
{
    self.currentPlayerItem = nil;
    self.seekTime = 0.0f;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.autoDismissTimer invalidate];
    self.autoDismissTimer = nil;
    [self.player pause];
    [self.playerLayer removeFromSuperlayer];
    [self.player replaceCurrentItemWithPlayerItem:nil];
    self.player = nil;
}

-(void)dealloc
{
    NSLog(@"MFPlayer dealloc");
    [self resetMFPlayer];
}

- (NSString*)version
{
   return @"1.0.0";
}

@end
