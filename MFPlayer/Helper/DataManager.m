//
//  DataManager.m
//  MFPlayer
//
//  Created by patpat on 16/8/4.
//  Copyright © 2016年 test. All rights reserved.
//

#import "DataManager.h"

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

- (void)getSidArrayWithUrl:(NSString*)url success:(onSuccess)success failed:(onFailed)failed
{

    
    
    

}


- (void)getVideoListUrl:(NSString*)url listId:(NSString*)listId success:(onSuccess)success failed:(onFailed)failed
{
 
    
    
    
    

}



@end
