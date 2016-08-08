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
    //进度条的点击事件
    [self.progressSlider addTarget:self action:@selector(updateProgress:) forControlEvents:UIControlEventTouchUpInside];
    [self.bottomView addSubview:self.progressSlider];
     self.progressSlider.backgroundColor = [UIColor clearColor];
     //给进度条添加单击手势
    self.tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapGesture:)];
    self.tap.delegate = self;
    [self.progressSlider addGestureRecognizer:self.tap];
    
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
- (void)appwillResignActive:(NSNotification *)note
{
    NSLog(@"appwillResignActive");
}
- (void)appBecomeActive:(NSNotification *)note
{
    NSLog(@"appBecomeActive");
}

- (void)appDidEnterBackground:(NSNotification *)note
{
    NSLog(@"appDidEnterBackground");
}
- (void)appWillEnterForeground:(NSNotification *)note
{
    NSLog(@"appWillEnterForeground");
}

- (void)handleSingleTap:(UITapGestureRecognizer*)tap
{


    
}

- (void)colseTheVideo:(UIButton*)btn
{
 

}

- (void)tapGesture:(UITapGestureRecognizer*)tap
{
   
   
}

- (void)fullScreenBtnAction:(UIButton*)btn
{


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


    
}

- (void)updateProgress:(UISlider*)slider
{
 
    
    
}

- (void)PlayOrPause:(UIButton *)sender{
    
    
    
    


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


}

- (double)playingTime
{
    return 0.2;

}

- (void)resetMFPlayer
{


}

- (NSString*)version
{
   return @"";
}

@end
