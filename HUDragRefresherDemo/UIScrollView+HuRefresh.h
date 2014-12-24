//
//  UIScrollView+_HuRefresh.h
//  ImageMultiPicker
//
//  Created by Nova(QQ:422596694 欢迎交流) on 14-12-18.
//  Copyright (c) 2014年 huhuTec. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ReactiveCocoa.h>
#import "HUDragFooterRefresh.h"
#import "HUDragHeaderRefresh.h"
@interface UIScrollView (HuRefresh)
@property(nonatomic,strong,readonly) RACReplaySubject* dragUpSuccessSignal;
@property(nonatomic,strong,readonly) RACReplaySubject* dragDownSuccessSignal;
@property(nonatomic,strong,readonly) HUDragFooterRefresh* footerRefresh;
@property(nonatomic,strong,readonly) HUDragHeaderRefresh* headerRefresh;
-(void)startFooterLoading;
-(void)startHeaderLoading;
-(void)addFooterRefreshWithCmd:(RACCommand*) runcommand;
-(void)addHeaderRefreshWithCmd:(RACCommand*) runcommand;
@end
