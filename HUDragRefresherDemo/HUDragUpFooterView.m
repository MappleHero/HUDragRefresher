//
//  HUDragUpFooterView.m
//  testConstraints
//
//  Created by Nova on 14-11-16.
//  Copyright (c) 2014年 huhuTec. All rights reserved.
//

#import "HUDragUpFooterView.h"
#import <extobjc.h>
@interface HUDragUpFooterView()
@property(nonatomic,assign) float viewheight;
@end
@implementation HUDragUpFooterView

- (id)initWithFrame:(CGRect)frame 
{
    self = [super initWithFrame:frame];
    if (self) {
        //设置一下自身的大小
        self.viewheight=_footerheight;
        self.backgroundColor=[UIColor clearColor];
        frame.size.height=self.viewheight;
        frame.origin.x=0;
        self.frame=frame;
        //添加活动指示图
        self.activety=[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        self.activety.hidden=YES;
        CGRect c=self.activety.bounds;
        c.origin.x=frame.size.width/4.0;
        c.origin.y=(frame.size.height-self.activety.frame.size.height)/2.0;
        self.activety.frame=c;
        //添加提示label
        self.label=[[UILabel alloc] init];
        self.label.text=[_NormalString copy];
        [self.label sizeToFit];
        self.label.font=[UIFont systemFontOfSize:12.0];
        self.label.textColor=[UIColor grayColor];
        CGRect l=self.label.bounds;
        l.origin.x=c.origin.x+c.size.width+10;
        l.origin.y=(frame.size.height-self.label.frame.size.height)/2.0;
        self.label.frame=l;
        
        //添加arrow
        NSString *path = [[NSBundle mainBundle]  pathForResource:@"arrow-big-04" ofType:@"png"];
        UIImage *im = [[UIImage alloc] initWithContentsOfFile:path];
        self.arrow=[[UIImageView alloc] initWithImage:im];
        self.arrow.center=self.activety.center;
        self.arrow.transform = CGAffineTransformMakeRotation(PI);
        
        [self addSubview:self.arrow];
        [self addSubview:self.label];
        [self addSubview:self.activety];
    }
    return self;
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
                 self.arrow.transform = CGAffineTransformMakeRotation(PI);
            }];
        }
      
        if(arrowstatus.intValue==2)
        {
            [UIView animateWithDuration:0.2 animations:^{
                 self.arrow.transform = CGAffineTransformIdentity;
            }];
        }
        
        if(loadingstatus.intValue==1)
            [self.activety startAnimating];
        
        return info;
     }] subscribeNext:^(NSString* text){
         @strongify(self);
         self.label.text=text;
         [self setNeedsDisplay];
    }];
}

@end
