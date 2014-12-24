//
//  HUDragFooterRefresh.h
//  ImageMultiPicker
//
//  Created by Nova(QQ:422596694 欢迎交流) on 14-12-18.
//  Copyright (c) 2014年 huhuTec. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ReactiveCocoa.h>
@interface HUDragFooterRefresh : NSObject
@property(nonatomic,strong) RACSubject* dragUpSuccessSignal;
-(void)startLoading;
-initWith:(RACCommand*) com inView:(UIScrollView*) x ;
@end
