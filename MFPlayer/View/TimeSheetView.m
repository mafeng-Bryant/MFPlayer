//
//  TimeSheetView.m
//  MFPlayer
//
//  Created by patpat on 16/8/23.
//  Copyright © 2016年 test. All rights reserved.
//

#import "TimeSheetView.h"
#import "MFPlayer.h"

@implementation TimeSheetView

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
       
        self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
        if (!_sheetStateImageView) {
            _sheetStateImageView = [[UIImageView alloc]init];
            _sheetStateImageView.contentMode = UIViewContentModeScaleAspectFit;
            _sheetStateImageView.image = [UIImage imageNamed:@"progress_icon_l"];
            [self addSubview:_sheetStateImageView];
            [_sheetStateImageView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(12);
                make.width.mas_equalTo(43);
                make.height.mas_equalTo(25);
                make.centerX.equalTo(self);
            }];
        }
        
        if (!_timeLbl) {
            _timeLbl = [[UILabel alloc]init];
            _timeLbl.font = [UIFont systemFontOfSize:13];
            _timeLbl.textColor = [UIColor whiteColor];
            _timeLbl.textAlignment = NSTextAlignmentCenter;
            [self addSubview:_timeLbl];
            [_timeLbl mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(_sheetStateImageView.mas_bottom);
                make.width.mas_equalTo(118);
                make.height.mas_equalTo(20);
                make.centerX.equalTo(self);
            }];
        }
    }
    return self;
}

@end
