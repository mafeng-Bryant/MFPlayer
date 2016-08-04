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

@interface MFPlayer()
{



}

@property (nonatomic,strong) UISlider* lightSlider; //亮度的进度条，和屏幕的亮度一样

@end


@implementation MFPlayer
{
    UISlider* _systemSlider;

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
    [self.topView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).with.offset(0);
        make.left.equalTo(self).with.offset(0);
        make.right.equalTo(self).with.offset(0);
        make.height.mas_equalTo(40);
    }];
    
    //bottomView
    self.bottomView = [[UIView alloc]init];
    self.bottomView.backgroundColor = [UIColor colorWithWhite:0.4 alpha:0.4];
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
    
    //
    
    
    
    
    
    
    
}

#pragma mark Private methods

- (void)playOrPauseAction:(UIButton*)btn
{
    
    
    
    


}

#pragma Public methods
- (void)play
{


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
