//
//  HUDragDownHeaderView.h
//  HUDragUpRefreshDemo
//
//  Created by Nova(QQ:422596694 欢迎交流) on 14-12-20.
//  Copyright (c) 2014年 huhuTec. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ReactiveCocoa.h>
static const CGFloat PI=3.14159265358979323846264338327950288;
static const NSString* _NormalString=@"下拉可以刷新!!";
static const NSString* _DropString=@"松手开始刷新!";
static const NSString* _LoadingString=@"正在刷新,请稍候...";
static const NSString* _ErrorString=@"出错了,加载失败..";
static const CGFloat _headerViewHeight=50;
@interface HUDragDownHeaderView : UIView
@property(nonatomic,strong) UIImageView* arrow;
@property(nonatomic,strong) UILabel* label;
@property(nonatomic,strong) UILabel* timelabel;
@property(nonatomic,strong) UIActivityIndicatorView* activety;
@property(nonatomic,strong) NSString* labeltxt;
@property(nonatomic,strong) NSString* datakey;
@property(nonatomic,strong) NSDate* lastUpdateTime;
@property(nonatomic,strong) NSString* lastUpdateStr;
@property(nonatomic,assign) BOOL isArrowTrans;
@property(nonatomic,assign) BOOL isLoadingShow;
-(void)bind:(RACSignal*) s;
-(id)initWithFrame:(CGRect)frame;
@end
