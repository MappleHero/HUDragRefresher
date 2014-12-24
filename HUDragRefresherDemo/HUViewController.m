//
//  HUViewController.m
//  HUDragRefresherDemo
//
//  Created by Nova(QQ:422596694 欢迎交流) on 14-12-24.
//  Copyright (c) 2014年 huhuTec. All rights reserved.
//

#import "HUViewController.h"
#import "HUViewModel.h"
#import "UIScrollView+HuRefresh.h"
#import <extobjc.h>
@interface HUViewController ()
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property(nonatomic,strong) HUViewModel* viewModel;
@end

@implementation HUViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.viewModel=[[HUViewModel alloc] init];
    self.tableView.dataSource=self;
    self.tableView.delegate=self;
    //添加上拉刷新
    [self.tableView addFooterRefreshWithCmd:self.viewModel.upLoadCmd];
    //添加下拉刷新
    [self.tableView addHeaderRefreshWithCmd:self.viewModel.downLoadCmd];
    @weakify(self);
    
    //订阅上拉刷新成功信号
    [self.tableView.dragUpSuccessSignal subscribeNext:^(id x){
        @strongify(self);
        [self.tableView reloadData];
    }];
    //订阅下拉刷新成功信号
    [self.tableView.dragDownSuccessSignal subscribeNext:^(id x){
        @strongify(self);
        [self.tableView reloadData];
    }];
    
    [self.tableView startHeaderLoading];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - UITableView Datasource

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    NSLog(@"%@",scrollView);
}



- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    UIViewController* v=[[UIViewController alloc] init];
    [self.navigationController pushViewController:v animated:YES];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.viewModel.datasource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if(cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    cell.textLabel.text =[self.viewModel.datasource objectAtIndex:indexPath.row];
    
    return cell;
}

#pragma mark - UITableView Delegate methods

@end
