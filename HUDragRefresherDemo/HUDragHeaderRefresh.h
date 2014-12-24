//
//  HUDragHeaderRefresh.h
//  HUDragUpRefreshDemo
//
//  Created by Nova(QQ:422596694 欢迎交流) on 14-12-20.
//  Copyright (c) 2014年 huhuTec. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ReactiveCocoa.h>
@interface HUDragHeaderRefresh : NSObject
@property(nonatomic,strong) RACSubject* dragDownSucessSignal;
-(void)startLoading;
-initWith:(RACCommand*) com inView:(UIScrollView*) x ;
@end
