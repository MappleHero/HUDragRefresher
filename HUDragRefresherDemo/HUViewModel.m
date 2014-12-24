//
//  HUViewModel.m
//  HUDragUpRefreshDemo
//
//  Created by Nova(QQ:422596694 欢迎交流) on 14-12-18.
//  Copyright (c) 2014年 huhuTec. All rights reserved.
//

#import "HUViewModel.h"

@implementation HUViewModel
-(id)init{
    self=[super init];
    if(self==nil) return nil;
    self.datasource=[[NSMutableArray alloc] init];
    //对于上拉刷新信号,参数input的值为 页码
    self.upLoadCmd=[[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input){
        NSLog(@"append loading....");
        //模拟延时3秒钟获取数据
        return [[RACSignal defer:^{
            for(int i=0;i<13;i++){
                [self.datasource addObject:[NSString stringWithFormat:@"down--data---%d", arc4random_uniform(1000000)]];
            }
            return [RACSignal empty];
        }] delay:3];
    }];
    //对于下拉刷新信号,参数input的值为 上次刷新的时间 
    self.downLoadCmd=[[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input){
        NSLog(@"insert loading....");
        //模拟延时3秒钟获取数据
        return [[RACSignal defer:^{
            for(int i=0;i<13;i++){
                [self.datasource insertObject:[NSString stringWithFormat:@"up--data---%d", arc4random_uniform(1000000)] atIndex:0];
            }
            return [RACSignal empty];
        }] delay:3];
    }];
    return self;
}
@end
