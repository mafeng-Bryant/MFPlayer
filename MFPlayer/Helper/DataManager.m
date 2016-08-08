//
//  DataManager.m
//  MFPlayer
//
//  Created by patpat on 16/8/4.
//  Copyright © 2016年 test. All rights reserved.
//

#import "DataManager.h"
#import "VideoModel.h"
#import "SidModel.h"

@implementation DataManager

+ (DataManager*)shareManager
{
    static DataManager* manager = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        manager = [[[self class] alloc] init];
    });
    return manager;
}

- (void)getSidArrayWithUrl:(NSString*)URLString success:(onSuccess)success failed:(onFailed)failed
{
    dispatch_queue_t global_t = dispatch_get_global_queue(0, 0);
    dispatch_async(global_t, ^{
        NSURL *url = [NSURL URLWithString:URLString];
        NSMutableArray *sidArray = [NSMutableArray array];
        NSMutableArray *videoArray = [NSMutableArray array];
        NSURLSession* session = [NSURLSession sharedSession];
        NSURLSessionDataTask* dataTask = [session dataTaskWithRequest:[NSURLRequest requestWithURL:url] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            if (error) {
                NSLog(@"错误%@",error);
                failed(error);
            }else {
                NSDictionary * dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
                for (NSDictionary * video in [dict objectForKey:@"videoList"]) {
                    VideoModel * model = [[VideoModel alloc] init];
                    [model setValuesForKeysWithDictionary:video];
                    [videoArray addObject:model];
                }
    
                self.videosArray = [NSArray arrayWithArray:videoArray];
                // 加载头标题
                for (NSDictionary *d in [dict objectForKey:@"videoSidList"]) {
                    SidModel *model= [[SidModel alloc] init];
                    [model setValuesForKeysWithDictionary:d];
                    [sidArray addObject:model];
                }
                self.sidArray = [NSArray arrayWithArray:sidArray];
                
                success(sidArray,videoArray);

            }
        }];
        [dataTask resume];
    });
}


- (void)getVideoListUrl:(NSString*)URLString listId:(NSString*)listId success:(onSuccess)success failed:(onFailed)failed
{
    dispatch_queue_t global_t = dispatch_get_global_queue(0, 0);
    dispatch_async(global_t, ^{
        NSURL *url = [NSURL URLWithString:URLString];
        NSMutableArray *listArray = [NSMutableArray array];
        NSURLSession* session = [NSURLSession sharedSession];
        NSURLSessionDataTask* dataTask = [session dataTaskWithRequest:[NSURLRequest requestWithURL:url] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            if (error) {
                NSLog(@"错误%@",error);
                failed(error);
            }else {
                NSDictionary * dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
                NSArray *videoList = [dict objectForKey:listId];
                for (NSDictionary * video in videoList) {
                    VideoModel * model = [[VideoModel alloc] init];
                    [model setValuesForKeysWithDictionary:video];
                    [listArray addObject:model];
                }
            }
            success(listArray,nil);
        }];
        
        [dataTask resume];
    });
}

@end
