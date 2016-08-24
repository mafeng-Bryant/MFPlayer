//
//  systemLightView.m
//  MFPlayer
//
//  Created by patpat on 16/8/23.
//  Copyright © 2016年 test. All rights reserved.
//

#import "systemLightView.h"

@interface systemLightView()

@property (nonatomic,strong) UIImageView* backImageView;
@property (nonatomic,strong) UILabel* titleLbl;
@property (nonatomic,strong) UIView* longView;
@property (nonatomic,strong) NSMutableArray* tipArray;
@property (nonatomic,assign) BOOL orientationDidChange;
@property (nonatomic,strong) NSTimer* timer;

@end


@implementation systemLightView

+ (instancetype)sharedInstance
{
    static systemLightView * instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[systemLightView alloc]init];
        [[UIApplication sharedApplication].keyWindow addSubview:instance];
        [instance mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(155);
            make.height.mas_equalTo(155);
            make.centerX.equalTo([UIApplication sharedApplication].keyWindow);
            make.centerY.equalTo([UIApplication sharedApplication].keyWindow).offset(-5);
        }];
    });
    return instance;
}


-(instancetype)init
{
    self = [super init];
    if (self) {

        self.layer.cornerRadius = 10.0;
        self.layer.masksToBounds = YES;
        //毛玻璃
        UIToolbar* toolBar = [[UIToolbar alloc]initWithFrame:self.bounds];
        toolBar.alpha = 0.97;
        [self addSubview:toolBar];
        
        self.backImageView = ({
            UIImageView* imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 79, 76)];
            imageView.image = [UIImage imageNamed:@"icon_brightness"];
            [self addSubview:imageView];
            imageView;
        });
        
        self.titleLbl = ({
            UILabel* lbl = [[UILabel alloc]initWithFrame:CGRectMake(0, 5, self.bounds.size.width, 30)];
            lbl.font = [UIFont systemFontOfSize:16];
            lbl.textColor     = [UIColor colorWithRed:0.25f green:0.22f blue:0.21f alpha:1.00f];
            lbl.textAlignment = NSTextAlignmentCenter;
            lbl.text          = @"亮度";
            [self addSubview:lbl];
            lbl;
         });
     
        self.longView = ({
            UIView* longView = [[UIView alloc]initWithFrame:CGRectMake(13, 132, self.bounds.size.width, 7)];
            longView.backgroundColor = [UIColor colorWithRed:0.25f green:0.22f blue:0.21f alpha:1.00f];
            [self addSubview:longView];
            longView;
       });
       
        [self createTips];
        [self addNotification];
        [self addObserve];
        
        self.alpha = 0.0;
        
    }
    return self;
}

- (void)createTips
{
    self.tipArray = [NSMutableArray arrayWithCapacity:16];
    
    CGFloat tipW = (self.longView.bounds.size.width - 17) / 16;
    CGFloat tipH = 5;
    CGFloat tipY = 1;
    
    for (int i = 0; i < 16; i++) {
        CGFloat tipX = i * (tipW + 1) +1;
        UIImageView* imageView = [[UIImageView alloc]init];
        imageView.backgroundColor = [UIColor whiteColor];
        imageView.frame = CGRectMake(tipX, tipY, tipW, tipH);
        [self.longView addSubview:imageView];
        [self.tipArray addObject:imageView];
   }
    [self updateLongView:[UIScreen mainScreen].brightness];
}

- (void)updateLongView:(CGFloat)sound
{
    CGFloat stage = 1 / 15.0;
    NSInteger level = sound / stage;
    for (int i = 0; i < self.tipArray.count; i++) {
        UIImageView* imageView = self.tipArray[i];
        if (i<=level) {
            imageView.hidden = NO;
        }else {
            imageView.hidden = YES;
        }
    }
}

- (void)addNotification
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateLayer:) name:UIDeviceOrientationDidChangeNotification object:nil];
}

- (void)updateLayer:(NSNotification*)noti
{
    self.orientationDidChange = YES;
    [self resertSubViews];
}

- (void)addObserve
{
     [[UIScreen mainScreen] addObserver:self forKeyPath:@"brightness" options:NSKeyValueObservingOptionNew context:NULL];
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    CGFloat sound = [change[@"new"] floatValue];
    [self appearSoundView];
    [self updateLongView:sound];
}

- (void)disAppearSoundView
{
    if (self.alpha == 1.0) {
        [UIView animateWithDuration:0.8 animations:^{
            self.alpha = 0.0;
        } completion:^(BOOL finished) {
            
        }];
    }
}

- (void)appearSoundView
{
    if (self.alpha ==0.0) {
        self.alpha = 1.0;
        [self updateTimer];
    }
}

- (void)updateTimer
{
    [self removeTimer];
    [self addTimer];
}

- (void)addTimer
{
   if (self.timer) {
        return;
    }
    
    self.timer = [NSTimer timerWithTimeInterval:3 target:self selector:@selector(disAppearSoundView) userInfo:nil repeats:NO];
    [[NSRunLoop mainRunLoop] addTimer:self.timer forMode:NSDefaultRunLoopMode];
}

- (void)removeTimer
{
    if (self.timer) {
        [self.timer invalidate];
        self.timer = nil;
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self resertSubViews];

}

- (void)resertSubViews
{
    self.backImageView.center = CGPointMake(155*0.5, 155*0.5);

}

-(void)dealloc
{
    [[UIScreen mainScreen] removeObserver:self forKeyPath:@"brightness"];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
