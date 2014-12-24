//
//  HUViewModel.h
//  HUDragUpRefreshDemo
//
//  Created by Nova(QQ:422596694 欢迎交流) on 14-12-18.
//  Copyright (c) 2014年 huhuTec. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ReactiveCocoa.h>
@interface HUViewModel : NSObject
@property(strong,nonatomic) RACCommand* upLoadCmd;
@property(strong,nonatomic) RACCommand* downLoadCmd;
@property(strong,nonatomic) NSMutableArray* datasource;
@end
