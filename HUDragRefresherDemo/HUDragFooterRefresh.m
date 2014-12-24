//
//  HUDragFooterRefresh.m
//  ImageMultiPicker
//
//  Created by Nova(QQ:422596694 欢迎交流) on 14-12-18.
//  Copyright (c) 2014年 huhuTec. All rights reserved.
//

#import "HUDragFooterRefresh.h"
#import "HUDragUpFooterView.h"
#import <extobjc.h>
@interface HUDragFooterRefresh()
@property(nonatomic,assign) BOOL isLoading;
@property(nonatomic,weak) UIScrollView* scrollView;
@property(nonatomic,strong) RACCommand* runCommand;
@property(nonatomic,strong) RACSignal* dragDidSignal;
@property(nonatomic,assign) NSInteger contentHeight;
@property(nonatomic,strong) RACSubject* tempSignal;
@property(nonatomic,assign) NSInteger curpage;
@property(nonatomic,assign) NSInteger latestPage;
@property(nonatomic,assign) BOOL isError;
@property(nonatomic,assign) BOOL isToRefresh;
@property(nonatomic,assign) BOOL isVisible;
@property(nonatomic,assign) BOOL isFinal;
@property(nonatomic,assign) BOOL isDragged;
@property(nonatomic,strong) RACSubject* loadSucess;
@property(nonatomic,strong) RACSubject* temprefresh;
@property(nonatomic,strong) RACSignal* loaderror;
@property(nonatomic,strong) RACSignal* loadingsignal;
@property(nonatomic,strong) RACSignal* releaseHandeTipSignal;
@property(nonatomic,strong) RACSignal* noreleaseHandeTipSignal;
@property(nonatomic,strong) HUDragUpFooterView* footerview;
@property(nonatomic,strong) RACSignal* dragUpRefreshSignal;
@property(nonatomic,assign) UIEdgeInsets originalInset;
@end
@implementation HUDragFooterRefresh
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
    _isFinal=NO;
    //拖动过程中的信号,主要是用来获取对应的scrollView
    _curpage=1;
    //保存最近一次已加载的页面,用于错误恢复.
    _latestPage=1;
    _temprefresh=[RACSubject subject];
    //消除对订阅先后顺序的信赖
    _dragUpSuccessSignal=[RACReplaySubject replaySubjectWithCapacity:1];
    self.dragUpRefreshSignal=[RACSignal merge:@[self.temprefresh]];
    [self.dragUpRefreshSignal subscribeNext:^(id x){
        [self startLoading];
    }];
    @weakify(self)
    //正在请求数据时...
    self.loadingsignal =[[[_runCommand.executing ignore:@0] mapReplace:[RACTuple tupleWithObjects:@0,@1,_LoadingString,nil]] doNext:^(id x){
        @strongify(self);
        //在刷新的时候,可以显示footerview
        _footerview.hidden=NO;
        self.scrollView.contentInset=UIEdgeInsetsMake(0, 0, _footerheight, 0);
    }];
    
    //出错了...
    self.loaderror=[_runCommand.errors mapReplace:[RACTuple tupleWithObjects:@1,@0,_ErrorString, nil]];
    
    //加载错误时的副作用
    [_runCommand.errors subscribeNext:^(id x){
        @strongify(self);
        self.isError=YES;
        self.isToRefresh=YES;
        //如果数据加载错误,则上拉时始终发出最近一次错误的页面信息.
        self.latestPage=self.curpage;
    }];
    
    //拉到临界点以上了的信号
    RACSignal* linpoint=[[RACObserve(self.scrollView,contentOffset) distinctUntilChanged] filter:^(id value){
        CGPoint offset = [value CGPointValue];
        @strongify(self);
        if(self.scrollView.isDragging&&self.isVisible&&!self.isLoading&&offset.y+self.scrollView.frame.size.height-self.scrollView.contentSize.height>=40&&!self.isFinal)
        {
            self.isToRefresh=YES;
            return YES;
        }
        return NO;
    }];
    
    
    //拉到临界点以下了的信号
    RACSignal* withdrop=[RACObserve(self.scrollView,contentOffset) filter:^(id value){
        CGPoint offset = [value CGPointValue];
        @strongify(self);
        if(!self.isLoading&&offset.y+self.scrollView.frame.size.height-self.scrollView.contentSize.height<40&&!self.isFinal)
        {
            if(self.scrollView.isDragging)
                self.isToRefresh=NO;
            return YES;
        }
        return NO;
    }];
    
    //拉到临界点以上了,还没松手,就提示松手
    self.releaseHandeTipSignal=[[linpoint filter:^BOOL(id x){
        @strongify(self);
        if(self.scrollView.isDragging) return YES;
        else
            return NO;
    }] mapReplace:[RACTuple tupleWithObjects:@2,@0,_DropString, nil]];
    
    //拉到临界点以下了,还没松手,就还原状态
    self.noreleaseHandeTipSignal=[[withdrop filter:^BOOL(id x){
        @strongify(self);
        return !self.isError; //在没有出错的情况下.
    }] mapReplace:[RACTuple tupleWithObjects:@1,@0,_NormalString, nil]];
    
    //发出刷新信号
    [RACObserve(self.scrollView,contentOffset) subscribeNext:^(id x){
        @strongify(self);
        if(!self.isLoading&&!self.scrollView.isDragging&&self.isToRefresh)
        {
            self.isToRefresh=NO;
            self.isLoading=YES;
            self.curpage=self.latestPage;
            [self.temprefresh sendNext:@(self.curpage)];
        }
        
    }];
    
    self.footerview=[[HUDragUpFooterView alloc] initWithFrame:self.scrollView.bounds] ;
    CGRect c=self.scrollView.bounds;
    c.origin.y=self.scrollView.contentSize.height;
    [self.scrollView addSubview:self.footerview];
    self.footerview.hidden=YES;
    
    //收集一下上面所发出的信号,来统一处理footerview的显示状态
    [self.footerview bind:[[[[RACSignal
                              merge:@[self.releaseHandeTipSignal,self.noreleaseHandeTipSignal,self.loadSucess,self.loaderror,self.loadingsignal]]
                             startWith:[RACTuple tupleWithObjects:@1,@0,_NormalString, nil]]
                            takeUntil:self.scrollView.rac_willDeallocSignal]
                           distinctUntilChanged
                           ]];
    
    
    
    //设置当前是否正在加载的状态,主要是为了,让加载时,不再接收用户的上拉信号.
    [_runCommand.executing subscribeNext:^(NSNumber* n){
        @strongify(self);
        self.isLoading=n.boolValue;
    }];
    
    
    //加载结束时,处理相应的状态
    [[[_runCommand.executing ignore:@1] skip:1] subscribeNext:^(id x){
        @strongify(self);
        self.isToRefresh=NO;
        self.scrollView.contentInset=self.originalInset;
        [self repositionFooterView];
    }];
    
    
    //这样可以在viewWillAppear中也可以刷新了.
    [[RACObserve(self.scrollView,contentSize) distinctUntilChanged]  subscribeNext:^(id x){
        @strongify(self);
        if([x CGSizeValue].height>0)
        self.footerview.hidden=NO;
        
        if(!self.isLoading)
            [self repositionFooterView];
    }];
    return self;
}



-(void)startLoading{
    _isLoading=YES;
    @weakify(self);
   RACSignal* exeSignal= [_runCommand execute:(@(_curpage))];
    //数据请求完毕...
    [exeSignal subscribeCompleted:^(void){
        @strongify(self);
        self.latestPage++;
        self.isToRefresh=NO;
        [self.loadSucess sendNext:[RACTuple tupleWithObjects:@1,@0,_NormalString, nil]];
        [self.dragUpSuccessSignal sendNext:@1];
        self.isError=NO;
    }];
}



-(void) repositionFooterView{
    //加载结束了,就重新设置一下footview的位置.
    self.scrollView.contentInset=self.originalInset;
    CGRect c=self.scrollView.bounds;
    c.origin.y=self.scrollView.contentSize.height;
    if(!CGRectEqualToRect(self.footerview.frame, c))
        self.footerview.frame=c;
}
@end
