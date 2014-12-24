由于在ReactiveCocoa中,RACCommand很常用,最近项目中要用到上下拉刷新,所以就写了个与RACCommand相配套的上下拉刷新,现开源出来,随便拿去用吧!
用法:
```objective-C
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
```
