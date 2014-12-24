//
//  HUViewModel.h
//  HUDragUpRefreshDemo
//
//  Created by Nova on 14-12-9.
//  Copyright (c) 2014年 huhuTec. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ReactiveCocoa.h>
@interface HUViewModel : NSObject
@property(strong,nonatomic) RACCommand* upLoadCmd;
@property(strong,nonatomic) RACCommand* downLoadCmd;
@property(strong,nonatomic) NSMutableArray* datasource;
@end
