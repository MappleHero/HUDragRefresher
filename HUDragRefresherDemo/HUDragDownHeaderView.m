//
//  HUDragDownHeaderView.m
//  HUDragUpRefreshDemo
//
//  Created by Nova(QQ:422596694 欢迎交流) on 14-12-20.
//  Copyright (c) 2014年 huhuTec. All rights reserved.
//

#import "HUDragDownHeaderView.h"
#import <extobjc.h>
@interface HUDragDownHeaderView()
@property(assign,nonatomic) CGFloat viewheight;
@end

@implementation HUDragDownHeaderView
- (id)initWithFrame:(CGRect)frame 
{
    self = [super initWithFrame:frame];
    if (self) {
        self.datakey=NSStringFromClass([self class]);
        //设置一下自身的大小
        self.viewheight=_headerViewHeight;
        self.backgroundColor=[UIColor clearColor];
        frame.size.height=self.viewheight;
        frame.origin.x=0;
        frame.origin.y=-self.viewheight;
        self.frame=frame;
        
        //添加活动指示图
        self.activety=[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        self.activety.hidden=YES;
        CGRect c=self.activety.bounds;
        c.origin.x=frame.size.width/4.0;
        c.origin.y=(frame.size.height-self.activety.frame.size.height)/3.0;
        self.activety.frame=c;
        
        //添加提示label
        self.label=[[UILabel alloc] init];
        self.label.text=[_NormalString copy];
        [self.label sizeToFit];
        self.label.font=[UIFont systemFontOfSize:12.0];
        self.label.textColor=[UIColor grayColor];
        CGRect l=self.label.bounds;
        l.origin.x=c.origin.x+c.size.width+10;
        l.origin.y=(frame.size.height-self.label.frame.size.height)/3.0;
        self.label.frame=l;
        
        //日期label
        self.timelabel=[[UILabel alloc] init];
        RAC(self.timelabel,text)=RACObserve(self, lastUpdateStr);
        self.timelabel.text=[self getLastUpdateTimeFromCache];
        self.timelabel.font=[UIFont systemFontOfSize:12.0];
        [self.timelabel sizeToFit];
        self.timelabel.textColor=[UIColor grayColor];
        CGRect tr=self.timelabel.frame;
        tr.origin.y+=l.origin.y+l.size.height+5;
        tr.origin.x=(self.frame.size.width-tr.size.width)/2;
        self.timelabel.frame=tr;
        
        //添加arrow
        NSString *path = [[NSBundle mainBundle]  pathForResource:@"arrow-big-04" ofType:@"png"];
        UIImage *im = [[UIImage alloc] initWithContentsOfFile:path];
        self.arrow=[[UIImageView alloc] initWithImage:im];
        self.arrow.center=self.activety.center;
        [[RACObserve(self, lastUpdateTime) skip:1] subscribeNext:^(NSDate* date){
            if(date!=nil){
               NSUserDefaults* d=[NSUserDefaults standardUserDefaults];
                [d setObject:date forKey:self.datakey];
                [d synchronize];
            }
        }];
        [self addSubview:self.arrow];
        [self addSubview:self.label];
        [self addSubview:self.activety];
        [self addSubview:self.timelabel];
    }
    return self;
}

-(NSString*)getDateTimeStr:(NSDate*) date{
    NSCalendar* cal=[NSCalendar currentCalendar];
    NSUInteger unit= NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitHour|NSCalendarUnitMinute;
    NSDateComponents* s=[cal components:unit fromDate:date];
    NSDateComponents* s1=[cal components:unit fromDate:[NSDate date]];
    NSString* datestr;
    NSString* minFormater;
    if(s.minute<10)
    {
       minFormater=@"0%d";
    }
    else{
       minFormater=@"%d";
    }
    
    if(s.day==s1.day){
        datestr=[NSString stringWithFormat:[@"今天 %d:" stringByAppendingString:minFormater],s.hour,s.minute];
    }
    else if(s.month==s1.month){
        datestr=[NSString stringWithFormat:[@"本月%d日 %d:" stringByAppendingString:minFormater],s.day,s.hour,s.minute];
    }
    else if(s.year==s1.year){
        datestr=[NSString stringWithFormat:[@"今年%d月%d日 %d:" stringByAppendingString:minFormater] ,s.month,s.day,s.hour,s.minute];
    }
    else
        datestr=[NSString stringWithFormat:[@"%d年%d月%d日 %d:" stringByAppendingString:minFormater] ,s.year,s.month,s.day,s.hour,s.minute];
    
    return [@"上次刷新: " stringByAppendingString:datestr];
}


-(NSString*)getLastUpdateTimeFromCache{
   NSUserDefaults* d=[NSUserDefaults standardUserDefaults];
   NSDate* date=[d objectForKey:self.datakey];
   if(date==nil)
   {
       self.lastUpdateTime=[NSDate dateWithTimeIntervalSince1970:0];
       return @"首次刷新...";
   }
   else
   {
       _lastUpdateTime=date;
       return [self getDateTimeStr:date];
   }
}



-(void)bind:(RACSignal*) s{
    @weakify(self);
    //根据接收到的信号不同分别改变label,arrow,activity的状态
    [[s reduceEach:^(NSNumber* arrowstatus,NSNumber* loadingstatus,NSString* info){
        @strongify(self);
        if(arrowstatus.intValue==0)
        {
            self.arrow.hidden=YES;
        }
        if(arrowstatus.intValue>0)
        {
            [self.activety stopAnimating];
            self.arrow.hidden=NO;
        }
        
        if(arrowstatus.intValue==1){
            [UIView animateWithDuration:0.4 animations:^{
                self.arrow.transform = CGAffineTransformIdentity;
            }];
        }
        
        if(arrowstatus.intValue==2)
        {
            [UIView animateWithDuration:0.2 animations:^{
                self.arrow.transform =CGAffineTransformMakeRotation(PI) ;
            }];
        }
        //加载完成
        if(loadingstatus.intValue==2)
        {
            self.lastUpdateTime=[NSDate date];
            self.timelabel.text=[self getDateTimeStr:self.lastUpdateTime];
            [self.timelabel sizeToFit];
            CGRect tr=self.timelabel.frame;
            tr.origin.x=(self.frame.size.width-tr.size.width)/2;
            self.timelabel.frame=tr;
        }
        
        if(loadingstatus.intValue==1){
                [self.activety startAnimating];
        }
        
        return info;
    }] subscribeNext:^(NSString* text){
        @strongify(self);
        self.label.text=text;
        [self setNeedsDisplay];
    }];
}
@end
