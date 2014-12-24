//
//  UIScrollView+_HuRefresh.m
//  ImageMultiPicker
//
//  Created by Nova(QQ:422596694 欢迎交流) on 14-12-18.
//  Copyright (c) 2014年 huhuTec. All rights reserved.
//

#import "UIScrollView+HuRefresh.h"
#import <extobjc.h>
#import <objc/runtime.h>
static char __footer_;
static char __header_;
//UIScrollView的一个分类,主要是用来方便取得其子类UIScrollview以及UICollectionView的父UIScrollView
@implementation UIScrollView (HuRefresh)
-(void)addFooterRefreshWithCmd:(RACCommand*) runcommand{
    self.alwaysBounceVertical=YES;
    HUDragFooterRefresh* footre=[[HUDragFooterRefresh alloc] initWith:runcommand inView:self];
    objc_setAssociatedObject(self, &__footer_, footre, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(void)addHeaderRefreshWithCmd:(RACCommand*) runcommand{
    self.alwaysBounceVertical=YES;
    HUDragHeaderRefresh* headre=[[HUDragHeaderRefresh alloc] initWith:runcommand inView:self];
    objc_setAssociatedObject(self, &__header_, headre, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


-(RACSubject*)dragUpSuccessSignal{
    return self.footerRefresh.dragUpSuccessSignal;
}

-(RACSubject*)dragDownSuccessSignal{
    return self.headerRefresh.dragDownSucessSignal;
}

-(HUDragFooterRefresh*)footerRefresh{
    return (HUDragFooterRefresh*)objc_getAssociatedObject(self,&__footer_);
}

-(HUDragHeaderRefresh*)headerRefresh{
    return (HUDragHeaderRefresh*)objc_getAssociatedObject(self,&__header_);
}

-(void)startFooterLoading{
    [self.footerRefresh startLoading];
}

-(void)startHeaderLoading{
    [self.headerRefresh startLoading];
}
@end
