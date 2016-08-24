//
//  MFPlayer.h
//  MFPlayer
//
//  Created by patpat on 16/8/4.
//  Copyright © 2016年 test. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "Masonry.h"
#import "TimeSheetView.h"


@import MediaPlayer;
@import UIKit;
@import Foundation;

typedef enum {
  MFPlayerStateFailed = 0, //播放失败
  MFPlayerStateBuffering = 1,//缓存中
  MFPlayerStateReadToPlay = 2,//将要播放
  MFPlayerStatePlaying = 3,//播放中
  MFPlayerStateStopped = 4,//暂停播放
  MFPlayerStateFinished = 5 //播放完成
}MFPlayerState;

//关闭按钮的类型
typedef enum {
 MFPlayerCloseBtnStylePop = 0, //(->)
 MFPlayerCloseBtnStyleClose = 1 //(X)
}MFPlayerCloseBtnStyle;

typedef enum {
 MFPlayerControlTypeProgress = 0,
 MFPlayerControlTypeVoice = 1,
 MFPlayerControlTypeLight = 2,
 MFPlayerControlTypeNone = 3
}MFPlayerControlType;

@class MFPlayer;

@protocol MFPlayerDelegate <NSObject>

@optional

- (void)mfPlayer:(MFPlayer*)player closeBtn:(UIButton*)btn;

- (void)mfPlayer:(MFPlayer *)player clickFullScreen:(UIButton*)btn;

- (void)mfPlayer:(MFPlayer *)player playFinished:(id)finish;

- (void)mfPlayer:(MFPlayer *)player appDidEnterBackground:(id)backGround;

- (void)mfPlayer:(MFPlayer *)player appWillEnterForeground:(id)backGround;


@end


@interface MFPlayer : UIView

//播放器类
@property (nonatomic,strong) AVPlayer* player;
//修改播放器的视图frame
@property (nonatomic,strong) AVPlayerLayer* playerLayer;
//顶部视图
@property (nonatomic,strong) UIView* topView;
//底部视图
@property (nonatomic,strong) UIView* bottomView;
//touch view
@property (nonatomic,strong) UIView* touchView;
//播放视频的标题
@property (nonatomic,strong) UILabel* titleLbl;
//播放器的状态
@property (nonatomic,assign) MFPlayerState state;
//左上角按钮的样式
@property (nonatomic,assign) MFPlayerCloseBtnStyle style;
//定时器
@property (nonatomic,strong) NSTimer* autoDismissTimer;
//是否全屏
@property (nonatomic,assign) BOOL isFullScreen;
//全屏的按钮
@property (nonatomic,strong) UIButton* fullScreenBtn;
//播放或者暂停的按钮
@property (nonatomic,strong) UIButton* playOrPauseBtn;
//左上角关闭按钮
@property (nonatomic,strong) UIButton* closeBtn;
//loading失败的label
@property (nonatomic,strong) UILabel* loadingFailedLbl;
//当前播放的item
@property (nonatomic,strong) AVPlayerItem* currentPlayerItem;
//菊花（加载框）
@property (nonatomic,strong) UIActivityIndicatorView *loadingView;
//播放视频的网址
@property (nonatomic,strong) NSString* urlString;
//跳到播放的时间点
@property (nonatomic,assign) double seekTime;

@property (nonatomic,assign) id<MFPlayerDelegate> delegate;

@property (nonatomic,assign) MFPlayerControlType controlType; //当前手势控制的进度，声音还是亮度类型

@property (nonatomic,strong) TimeSheetView* timeSheetView; //快进的视图

//播放
- (void)play;
//暂停
- (void)pause;
//获取正在播放的时间点
- (double)playingTime;
//重置播放器
- (void)resetMFPlayer;
//版本号
- (NSString*)version;


@end
