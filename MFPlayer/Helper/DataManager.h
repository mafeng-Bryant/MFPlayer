//
//  DataManager.h
//  MFPlayer
//
//  Created by patpat on 16/8/4.
//  Copyright © 2016年 test. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^onSuccess)(NSArray* sidArray,NSArray* videosArray);
typedef void(^onFailed)(NSError* error);

@interface DataManager : NSObject
@property (nonatomic,strong) NSArray* sidArray;
@property (nonatomic,strong) NSArray* videosArray;

+ (DataManager*)shareManager;

- (void)getSidArrayWithUrl:(NSString*)URLString success:(onSuccess)success failed:(onFailed)failed;

- (void)getVideoListUrl:(NSString*)URLString listId:(NSString*)listId success:(onSuccess)success failed:(onFailed)failed;

@end
