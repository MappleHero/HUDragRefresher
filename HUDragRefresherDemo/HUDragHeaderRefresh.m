//
//  HUDragHeaderRefresh.m
//  HUDragUpRefreshDemo
//
//  Created by Nova(QQ:422596694 欢迎交流) on 14-12-20.
//  Copyright (c) 2014年 huhuTec. All rights reserved.
//

#import "HUDragHeaderRefresh.h"
#import "HUDragDownHeaderView.h"
#import <extobjc.h>
@interface HUDragHeaderRefresh()
@property(nonatomic,assign) BOOL isLoading;
@property(nonatomic,weak) UIScrollView* scrollView;
@property(nonatomic,strong) RACCommand* runCommand;
@property(nonatomic,strong) RACSignal* dragDidSignal;
@property(nonatomic,assign) NSInteger contentHeight;
@property(nonatomic,strong) RACSubject* tempSignal;
@property(nonatomic,assign) BOOL isError;
@property(nonatomic,assign) BOOL isToRefresh;
@property(nonatomic,assign) BOOL isVisible;
@property(nonatomic,assign) BOOL isDragged;
@property(nonatomic,strong) RACSubject* loadSucess;
@property(nonatomic,strong) RACSubject* temprefresh;
@property(nonatomic,strong) RACSignal* loaderror;
@property(nonatomic,strong) RACSignal* loadingsignal;
@property(nonatomic,strong) RACSignal* releaseHandeTipSignal;
@property(nonatomic,strong) RACSignal* noreleaseHandeTipSignal;
@property(nonatomic,strong) HUDragDownHeaderView* headerview;
@property(nonatomic,strong) RACSignal* dragDownRefreshSignal;
@property(nonatomic,assign) UIEdgeInsets originalInset;
@property(nonatomic,weak) id target;
@end
@implementation HUDragHeaderRefresh
-initWith:(RACCommand*) com inView:(UIScrollView*) x {
    self=[super init];
    if(self==nil) return nil;
    self.scrollView=x;
    self.originalInset=self.scrollView.contentInset;
    _loadSucess=[RACSubject subject];
    _runCommand=com;
    _isError=NO;
    _isVisible=YES;
    _isToRefresh=NO;
    _isDragged=NO;
    //当前是否在加载
    _isLoading=YES;
    //是否已经加载完全部数据
    _temprefresh=[RACSubject subject];
    //消除对订阅先后顺序的信赖
    _dragDownSucessSignal=[RACReplaySubject replaySubjectWithCapacity:1];
    
    @weakify(self)
    self.dragDownRefreshSignal=[RACSignal merge:@[self.temprefresh]];
    [self.dragDownRefreshSignal subscribeNext:^(id x){
        @strongify(self);
        [self startLoading];
    }];
    
    //正在请求数据时...
    self.loadingsignal =[[[_runCommand.executing ignore:@0] mapReplace:[RACTuple tupleWithObjects:@0,@1,_LoadingString,nil]] doNext:^(id x){
        @strongify(self);
        //在刷新的时候,可以显示完整的headerview
        self.scrollView.contentInset=UIEdgeInsetsMake(_headerViewHeight, 0, 0, 0);
    }];
    
    
    //出错了...
    self.loaderror=[_runCommand.errors mapReplace:[RACTuple tupleWithObjects:@1,@0,_ErrorString, nil]];
    
    //加载错误时的副作用
    [_runCommand.errors subscribeNext:^(id x){
        @strongify(self);
        self.isError=YES;
        self.isToRefresh=YES;
    }];
    
    
    //拉到临界点以下了的信号
    RACSignal* linpoint=[[RACObserve(self.scrollView,contentOffset) distinctUntilChanged] filter:^(id value){
        CGPoint offset = [value CGPointValue];
        @strongify(self);
        if(self.scrollView.isDragging&&self.isVisible&&!self.isLoading&&offset.y<-_headerViewHeight)
        {
            self.isToRefresh=YES;
            return YES;
        }
        return NO;
    }];
    
    
    //拉到临界点以上了的信号
    RACSignal* withdrop=[RACObserve(self.scrollView,contentOffset) filter:^(id value){
        CGPoint offset = [value CGPointValue];
        @strongify(self);
        if(!self.isLoading&&offset.y>-_headerViewHeight)
        {
            //如果拉到临界点以上没有松手的话.
            if(self.scrollView.isDragging)
                self.isToRefresh=NO;
            return YES;
        }
        return NO;
    }];
    
    //拉到临界点以下了,还没松手,就提示松手
    self.releaseHandeTipSignal=[[linpoint filter:^BOOL(id x){
        @strongify(self);
        if(self.scrollView.isDragging) return YES;
        else
            return NO;
    }] mapReplace:[RACTuple tupleWithObjects:@2,@0,_DropString, nil]];
    
    //拉到临界点以上了,还没松手,就还原状态
    self.noreleaseHandeTipSignal=[withdrop map:^id(id value){
     if(self.isError)
        return [RACTuple tupleWithObjects:@1,@0,_ErrorString, nil];
        else
        return [RACTuple tupleWithObjects:@1,@0,_NormalString, nil];
    }];
    
    //发出刷新信号
    [RACObserve(self.scrollView,contentOffset) subscribeNext:^(id x){
        @strongify(self);
        if(!self.isLoading&&!self.scrollView.isDragging&&self.isToRefresh)
        {
            self.isToRefresh=NO;
            self.isLoading=YES;
            [self.temprefresh sendNext:@1];
        }
        
    }];
    
    self.headerview=[[HUDragDownHeaderView alloc] initWithFrame:self.scrollView.bounds] ;
    
    //收集一下上面所发出的信号,来统一处理headerview的显示状态
    [self.headerview bind:[[[[RACSignal
                              merge:@[self.releaseHandeTipSignal,self.noreleaseHandeTipSignal,self.loadSucess,self.loaderror,self.loadingsignal]]
                             startWith:[RACTuple tupleWithObjects:@1,@0,_NormalString, nil]]
                            takeUntil:self.scrollView.rac_willDeallocSignal]
                           distinctUntilChanged
                           ]];
    [self.scrollView addSubview:self.headerview];
    
    //设置当前是否正在加载的状态,主要是为了,让加载时,不再接收用户的上拉信号.
    [_runCommand.executing subscribeNext:^(NSNumber* n){
        @strongify(self);
        self.isLoading=n.boolValue;
    }];
    
    
    //加载结束时,处理相应的状态
    [[[_runCommand.executing ignore:@1] skip:1] subscribeNext:^(id x){
        @strongify(self);
        self.isToRefresh=NO;
        [self repositionFooterView];
    }];
    
    //这样可以在viewWillAppear中也可以刷新了.
    [[RACObserve(self.scrollView,contentSize) distinctUntilChanged]  subscribeNext:^(id x){
        @strongify(self);
        if(!self.isLoading&&!self.isError)
            [self repositionFooterView];
    }];
    return self;
}



-(void)startLoading{
    _isLoading=YES;
    RACSignal* exeSignal=[_runCommand execute:(self.headerview.lastUpdateTime)];
    //数据请求完毕...
    @weakify(self);
    [exeSignal subscribeCompleted:^(void){
        @strongify(self);
        self.isToRefresh=NO;
        [self.loadSucess sendNext:[RACTuple tupleWithObjects:@1,@2,_NormalString, nil]];
        [self.dragDownSucessSignal sendNext:@1];
        self.isError=NO;
    }];
}



-(void) repositionFooterView{
    //加载结束了,就重新设置一下footview的位置.
    if(self.isError)
        self.scrollView.contentInset=UIEdgeInsetsMake(_headerViewHeight, 0, 0, 0);
    else
        self.scrollView.contentInset=self.originalInset;
    CGRect c=self.scrollView.bounds;
    c.origin.y=-_headerViewHeight;
    if(!CGRectEqualToRect(self.headerview.frame, c))
        self.headerview.frame=c;
}
@end
