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
@property (nonatomic,strong) UISlider* lightSlider;
@property (nonatomic,strong) UISlider* volumeSlider;
@property (nonatomic,strong) MPVolumeView* volumeView;
@property (nonatomic,strong) UISlider* progressSlider;
@property (nonatomic,strong) UITapGestureRecognizer* tap;
@property (nonatomic,strong) UIProgressView* loadingProgress;
@property (nonatomic,strong) UILabel*  leftTimeLabel;
@property (nonatomic,strong) UILabel*  rightTimeLabel;
@property (nonatomic,strong) NSDateFormatter *dateFormatter;
@property (nonatomic,strong) UISlider* systemSlider;
@property (nonatomic,strong) UITapGestureRecognizer* singleTap;
@property (nonatomic,strong) id playObserve;

@end

@implementation MFPlayer

#pragma mark cicyle

- (instancetype)init
{
    self = [super init];
    if (self) {
      [self setUp];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setUp];
    }
    return self;
}

#pragma mark Private methods

- (void)setUp
{
    self.seekTime = 0.0;
    self.backgroundColor = [UIColor blackColor];
    //loadingView
    [self addSubview:self.loadingView];
    //topview
    [self addSubview:self.topView];
    //bottomView
    [self addSubview:self.bottomView];
    //自动适应尺寸
    [self setAutoresizesSubviews:NO];
    //playOrPausebtn
    [self.bottomView addSubview:self.playOrPauseBtn];
    //slider
    [self addSubview:self.lightSlider];
    //system slider
    [self addSubview:self.systemSlider];
    //slider change
    [self addSubview:self.volumeSlider];
    [self.bottomView addSubview:self.progressSlider];
    [self.bottomView addSubview:self.loadingProgress];
    [self.bottomView sendSubviewToBack:self.loadingProgress];
    //fullScreenbtn
    [self.bottomView addSubview:self.fullScreenBtn];
    //left time label
    [self.bottomView addSubview:self.leftTimeLabel];
    //right time label
    [self.bottomView addSubview:self.rightTimeLabel];
    //closeBtn
    [self.topView addSubview:self.closeBtn];
    //titleLabel
    [self.topView addSubview:self.titleLbl];
    [self addSubview:self.loadingFailedLbl];
    [self bringSubviewToFront:self.loadingView];
    [self bringSubviewToFront:self.bottomView];
    [self addGestureRecognizer:self.singleTap];
    [self addConstraints];
    [self addNotification];
}

- (void)addConstraints
{
    //all view add constraints
    [self.loadingView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self);
    }];
    [self.topView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).with.offset(0);
        make.left.equalTo(self).with.offset(0);
        make.right.equalTo(self).with.offset(0);
        make.height.mas_equalTo(40);
    }];
    [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).with.offset(0);
        make.right.equalTo(self).with.offset(0);
        make.bottom.equalTo(self).with.offset(0);
        make.height.mas_equalTo(40);
    }];
    [self.playOrPauseBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(40);
        make.height.mas_equalTo(40);
        make.left.equalTo(self.bottomView).with.offset(0);
        make.bottom.equalTo(self.bottomView).with.offset(0);
    }];
    [self.progressSlider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.bottomView).with.offset(45);
        make.right.equalTo(self.bottomView).with.offset(-45);
        make.center.equalTo(self.bottomView);
    }];
    [self.loadingProgress mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.progressSlider);
        make.right.equalTo(self.progressSlider);
        make.center.equalTo(self.progressSlider);
    }];
    [self.fullScreenBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.bottomView).with.offset(0);
        make.bottom.equalTo(self.bottomView).with.offset(0);
        make.width.mas_equalTo(40);
        make.height.mas_equalTo(40);
    }];
    [self.leftTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.bottomView).with.offset(45);
        make.right.equalTo(self.bottomView).with.offset(-45);
        make.height.mas_equalTo(20);
        make.bottom.equalTo(self.bottomView).with.offset(0);
    }];
    [self.rightTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.bottomView).with.offset(45);
        make.right.equalTo(self.bottomView).with.offset(-45);
        make.height.mas_equalTo(20);
        make.bottom.equalTo(self.bottomView).with.offset(0);
    }];
    [self.closeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.topView).with.offset(5);
        make.height.mas_equalTo(30);
        make.top.equalTo(self.topView).with.offset(5);
        make.width.mas_equalTo(30);
    }];
    [self.titleLbl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.topView).with.offset(45);
        make.right.equalTo(self.topView).with.offset(-45);
        make.center.equalTo(self.topView);
        make.top.equalTo(self.topView).with.offset(0);
    }];
    [self.loadingFailedLbl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self);
        make.width.equalTo(self);
        make.height.equalTo(@30);
    }];
}

- (void)addNotification
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
}

//设置跳转到某一时间
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

//获取视频播放的总时长
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

//跳转到某一时间播放
- (void)seekToTime:(CGFloat)seconds
{
    if (self.state ==MFPlayerStateStopped) {
        return;
    }
    seconds = MAX(0, seconds);
    seconds = MIN(seconds, [self getMediaTotalTime]);
    [self.player pause];
    [self.player seekToTime:CMTimeMakeWithSeconds(seconds, NSEC_PER_SEC) completionHandler:^(BOOL finished) {
        [self.player play];
        if (!self.currentPlayerItem.isPlaybackLikelyToKeepUp) {
            self.state = MFPlayerStateBuffering;
            [self.loadingView startAnimating];
        }
    }];
}

//更新进度条的时间
- (void)updateCurrentTime:(CGFloat)time
{
    NSDate* date = [NSDate dateWithTimeIntervalSince1970:time];
    if (time /3600 > 1) {
        [[self dateFormatter] setDateFormat:@"HH:mm:ss"];
    }else {
        [[self dateFormatter] setDateFormat:@"mm:ss"];
    }
    self.leftTimeLabel.text = [[self dateFormatter] stringFromDate:date];
}


#pragma mark Event Response
//单击视频处理
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

//关闭视频播放
- (void)colseTheVideo:(UIButton*)btn
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(mfPlayer:closeBtn:)]) {
        [self.delegate mfPlayer:self closeBtn:btn];
    }
}

//全屏视频播放
- (void)fullScreenBtnAction:(UIButton*)btn
{
    btn.selected = !btn.selected;
    if (self.delegate && [self.delegate respondsToSelector:@selector(mfPlayer:clickFullScreen:)]) {
        [self.delegate mfPlayer:self clickFullScreen:btn];
    }
}

//播放或者暂停播放
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

//开始拖曳进度条
- (void)startDragSlider:(UISlider*)slider
{
    [self updateCurrentTime:slider.value];
}

//进度条改变响应
- (void)startChangeSlider:(UISlider*)slider
{
    [self seekToTime:slider.value];
    [self updateCurrentTime:slider.value];
}

//更新系统声音
- (void)updateSystemVolumeValue:(UISlider*)slider
{
    
}

//缓冲调用方法
- (void)loadTimeRanges
{
    self.state = MFPlayerStateBuffering;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self play];
        [self.loadingView stopAnimating];
    });
}

//获取缓存的进度
- (NSTimeInterval)avaliableDuration
{
    NSArray* loadedTimeRanges = [_currentPlayerItem loadedTimeRanges];
    CMTimeRange timeRange = [loadedTimeRanges.firstObject CMTimeRangeValue];//本次缓冲时间范围
    float startSeconds = CMTimeGetSeconds(timeRange.start);
    float durationSeconds = CMTimeGetSeconds(timeRange.duration);
    NSTimeInterval totalBuffer = startSeconds + durationSeconds;
    return totalBuffer;
}

//跳到某一时间播放视频
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

//获取当前播放资源的总时间
- (CMTime)playItemDuration
{
    AVPlayerItem* playItem = _currentPlayerItem;
    if (playItem.status == AVPlayerItemStatusReadyToPlay) {
        return [playItem duration];
    }
    return (kCMTimeInvalid);
}

//显示播放的时间
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

//监听播放器的播放状态，每隔一秒会调用
- (void)observePlayer
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

//不断更新进度条以及时间的变化
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
        [self.progressSlider setValue:(maxValue - minValue) * nowTime / duration + minValue];
    }
}

//获取当前播放视频的总时间
- (double)getMediaTotalTime
{
    AVPlayerItem* item = self.player.currentItem;
    if (item.status == AVPlayerItemStatusReadyToPlay) {
        return CMTimeGetSeconds([[item asset] duration]);
    }
    return 0.0f;
}

//隐藏视频头部和底部的视图
- (void)autoDismissBottomView:(NSTimer*)timer
{
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

//重置播放器
- (void)resetMFPlayer
{
    self.seekTime = 0.0f;
    self.currentPlayerItem = nil;
    [self.autoDismissTimer invalidate];
    self.autoDismissTimer = nil;
    [self.player pause];
    [self.playerLayer removeFromSuperlayer];
    [self.player replaceCurrentItemWithPlayerItem:nil];
    self.player = nil;
}

#pragma mark NSNotification method

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

//进入后台
- (void)appDidEnterBackground:(NSNotification *)notification
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(mfPlayer:appDidEnterBackground:)]) {
        [self.delegate mfPlayer:self appDidEnterBackground:notification];
    }
}

//将要进入前台
- (void)appWillEnterForeground:(NSNotification *)notification
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(mfPlayer:appWillEnterForeground:)]) {
        [self.delegate mfPlayer:self appWillEnterForeground:notification];
    }
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
                    [self observePlayer];
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

#pragma mark Public methods

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

- (NSString*)version
{
   return @"1.0.0";
}

#pragma mark set and get method

-(UIActivityIndicatorView *)loadingView
{
    if (!_loadingView) {
        _loadingView = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    }
    return _loadingView;
}

-(UIView *)topView
{
    if (!_topView) {
        _topView = [[UIView alloc]init];
        _topView.backgroundColor = [UIColor colorWithWhite:0.4 alpha:0.4];
    }
    return _topView;
}

-(UIView *)bottomView
{
    if (!_bottomView) {
        _bottomView = [[UIView alloc]init];
        _bottomView.backgroundColor = [UIColor colorWithWhite:0.4 alpha:0.4];
    }
    return _bottomView;
}

-(UIButton *)playOrPauseBtn
{
    if (!_playOrPauseBtn) {
        _playOrPauseBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _playOrPauseBtn.showsTouchWhenHighlighted = YES;
        [_playOrPauseBtn addTarget:self action:@selector(playOrPauseAction:) forControlEvents:UIControlEventTouchUpInside];
        [_playOrPauseBtn setImage:[UIImage imageNamed:MFPlayerSrcName(@"pause")] forState:UIControlStateNormal];
        [_playOrPauseBtn setImage:[UIImage imageNamed:MFPlayerSrcName(@"play")] forState:UIControlStateSelected];
    }
    return _playOrPauseBtn;
}

-(UISlider *)lightSlider
{
    if (!_lightSlider) {
        _lightSlider = [[UISlider alloc]init];
        _lightSlider.frame = CGRectMake(0, 0, 0, 0);
        _lightSlider.minimumValue = 0.0;
        _lightSlider.maximumValue = 1.0;
        _lightSlider.hidden = YES;
        _lightSlider.value = [UIScreen mainScreen].brightness;
    }
    return _lightSlider;
}

-(MPVolumeView *)volumeView
{
    if (!_volumeView) {
        _volumeView = [[MPVolumeView alloc]init];
        _volumeView.backgroundColor = [UIColor clearColor];
        _volumeView.frame = CGRectMake(-10000, -100, 100, 100);
        _volumeView.hidden = YES;
        [_volumeView sizeToFit];
    }
    return _volumeView;
}

-(UISlider *)systemSlider
{
    if (!_systemSlider) {
        _systemSlider = [[UISlider alloc]init];
        _systemSlider.backgroundColor = [UIColor clearColor];
        for (UIView* view in self.volumeView.subviews) {
            if ([NSStringFromClass(view.classForCoder)  isEqualToString: @"MPVolumeSlider"]) {
                _systemSlider = (UISlider*)view;
            }
        }
        _systemSlider.autoresizesSubviews = NO;
        _systemSlider.autoresizingMask = UIViewAutoresizingNone;
        _systemSlider.hidden = YES;
    }
    return _systemSlider;
}

-(UISlider *)volumeSlider
{
    if (!_volumeSlider) {
        _volumeSlider = [[UISlider alloc]initWithFrame:CGRectZero];
        _volumeSlider.tag = 1000;
        _volumeSlider.hidden = YES;
        _volumeSlider.minimumValue = _systemSlider.minimumValue;
        _volumeSlider.maximumValue = _systemSlider.maximumValue;
        _volumeSlider.value = _systemSlider.value;
        [_volumeSlider addTarget:self action:@selector(updateSystemVolumeValue:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _volumeSlider;
}

-(UISlider *)progressSlider
{
    if (!_progressSlider) {
        _progressSlider = [[UISlider alloc]init];
        _progressSlider.minimumValue = 0.0;
        [_progressSlider setThumbImage:[UIImage imageNamed:MFPlayerSrcName(@"dot")] forState:UIControlStateNormal];
        _progressSlider.minimumTrackTintColor = [UIColor greenColor];
        _progressSlider.maximumTrackTintColor = [UIColor clearColor];
        _progressSlider.value = 0.0;
        //进度条拖曳事件
        [_progressSlider addTarget:self action:@selector(startDragSlider:) forControlEvents:UIControlEventValueChanged];
        [_progressSlider addTarget:self action:@selector(startChangeSlider:) forControlEvents:UIControlEventTouchUpInside];
        [_progressSlider addTarget:self action:@selector(startChangeSlider:) forControlEvents:UIControlEventTouchUpOutside];
        [_progressSlider addTarget:self action:@selector(startChangeSlider:) forControlEvents:UIControlEventTouchCancel];
        _progressSlider.backgroundColor = [UIColor clearColor];
    }
    return _progressSlider;
}

-(UIProgressView *)loadingProgress
{
    if (!_loadingProgress) {
        _loadingProgress = [[UIProgressView alloc]initWithProgressViewStyle:UIProgressViewStyleDefault];
        _loadingProgress.progressTintColor = [UIColor clearColor];
        _loadingProgress.trackTintColor = [UIColor lightGrayColor];
        [_loadingProgress setProgress:0.0 animated:NO];
    }
    return _loadingProgress;
}

-(UIButton *)fullScreenBtn
{
    if (!_fullScreenBtn) {
        _fullScreenBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _fullScreenBtn.showsTouchWhenHighlighted = YES;
        [_fullScreenBtn addTarget:self action:@selector(fullScreenBtnAction:) forControlEvents:UIControlEventTouchUpInside];
        [_fullScreenBtn setImage:[UIImage imageNamed:MFPlayerSrcName(@"fullscreen")] forState:UIControlStateNormal];
        [_fullScreenBtn setImage:[UIImage imageNamed:MFPlayerSrcName(@"nonfullscreen")] forState:UIControlStateSelected];
    }
    return _fullScreenBtn;
}

-(UILabel *)leftTimeLabel
{
    if (!_leftTimeLabel) {
        _leftTimeLabel = [[UILabel alloc]init];
        _leftTimeLabel.textAlignment = NSTextAlignmentLeft;
        _leftTimeLabel.textColor = [UIColor whiteColor];
        _leftTimeLabel.backgroundColor = [UIColor clearColor];
        _leftTimeLabel.font = [UIFont systemFontOfSize:11];
    }
    return _leftTimeLabel;
}

-(UILabel *)rightTimeLabel
{
    if (!_rightTimeLabel) {
        _rightTimeLabel = [[UILabel alloc]init];
        _rightTimeLabel.textAlignment = NSTextAlignmentRight;
        _rightTimeLabel.textColor = [UIColor whiteColor];
        _rightTimeLabel.backgroundColor = [UIColor clearColor];
        _rightTimeLabel.font = [UIFont systemFontOfSize:11];
    }
    return _rightTimeLabel;
}

-(UIButton *)closeBtn
{
    if (!_closeBtn) {
        _closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _closeBtn.showsTouchWhenHighlighted = YES;
        [_closeBtn addTarget:self action:@selector(colseTheVideo:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _closeBtn;
}

-(UILabel *)titleLbl
{
    if (!_titleLbl) {
        _titleLbl = [[UILabel alloc]init];
        _titleLbl.textAlignment = NSTextAlignmentCenter;
        _titleLbl.textColor = [UIColor whiteColor];
        _titleLbl.backgroundColor = [UIColor clearColor];
        _titleLbl.font = [UIFont systemFontOfSize:17.0];
    }
    return _titleLbl;
}

-(UITapGestureRecognizer *)singleTap
{
    if (!_singleTap) {
        _singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
        _singleTap.numberOfTapsRequired = 1; // 单击
        _singleTap.numberOfTouchesRequired = 1;
    }
    return _singleTap;
}

-(UILabel *)loadingFailedLbl
{
    if (!_loadingFailedLbl) {
        _loadingFailedLbl = [[UILabel alloc]init];
        _loadingFailedLbl.textColor = [UIColor whiteColor];
        _loadingFailedLbl.textAlignment = NSTextAlignmentCenter;
        _loadingFailedLbl.text = @"视频加载失败";
        _loadingFailedLbl.hidden = YES;
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

-(void)setUrlString:(NSString *)urlString
{
    _urlString = urlString;
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

-(void)dealloc
{
    NSLog(@"%@ dealloc",NSStringFromClass([self class]));
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_currentPlayerItem removeObserver:self forKeyPath:kStatus];
    [_currentPlayerItem removeObserver:self forKeyPath:kLoadtimeRangesKey];
    [_currentPlayerItem removeObserver:self forKeyPath:kPlaybackBufferEmpty];
    [_currentPlayerItem removeObserver:self forKeyPath:kPlaybackLikelyToKeepUp];
    [self resetMFPlayer];
}


@end
