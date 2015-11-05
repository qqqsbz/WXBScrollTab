//
//  ViewController.m
//  ScrollTab
//
//  Created by coder on 15/11/5.
//  Copyright © 2015年 coder. All rights reserved.
//

#import "ViewController.h"
#import "TSTView.h"
#import "UIColor+Util.h"
#import "LDRefreshFooterView.h"
#import "LDRefreshHeaderView.h"
#import "UIScrollView+LDRefresh.h"
@interface ViewController ()<TSTViewDataSource,TSTViewDelegate,UITableViewDataSource>
{
    UITableView          *previousTableView;
    NSInteger rows;
}

@property (strong, nonatomic) TSTView *tstView;
@property (strong, nonatomic) NSArray *titleDatas;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    if ([self respondsToSelector:@selector(automaticallyAdjustsScrollViewInsets)]) {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
    rows = 10;
    self.titleDatas = [NSArray arrayWithObjects:@"娱乐",@"头条",@"热点",@"广州",@"晒货",@"体育",@"财经",@"科技",@"图片",@"跟贴",@"直播",@"段子",@"军事",@"汽车",@"情动一刻",@"历史",@"彩票",@"移动互联",@"家居",@"原创",@"游戏",@"画报",@"健康",@"时尚",@"房产",@"政务",nil];
    //self.titleDatas = [NSArray arrayWithObjects:@"关注",@"广场",@"求助",@"专栏", nil];
    self.tstView = [[TSTView alloc] initWithFrame:CGRectMake(0, 20, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame))];
    self.tstView.dataSource = self;
    self.tstView.delegate = self;
    self.tstView.autoAverageSort = NO;//栏目数大于4时 不能为YES
    self.tstView.shadowTitleEqualWidth = NO;//下划线是否与tab标题同宽
    [self.tstView reloadData];
    [self.view addSubview:self.tstView];
}

#pragma mark -- TSTView data source
- (NSInteger)numberOfTabsInTSTView:(TSTView *)tstview
{
    return self.titleDatas.count;
}

- (NSString *)tstview:(TSTView *)tstview titleForTabAtIndex:(NSInteger)tabIndex
{
    return self.titleDatas[tabIndex];
}

- (UIView *)tstview:(TSTView *)tstview viewForSelectedTabIndex:(NSInteger)tabIndex
{
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    tableView.dataSource = self;
    tableView.tag = tabIndex;
    [self addRefreshView:tableView];
    return tableView;
}

#pragma mark -- Table View refresh

- (void)addRefreshView:(UITableView *)tableView
{
    __block UITableView *contentView = tableView;
    //下拉刷新
    tableView.refreshHeader = [tableView addRefreshHeaderWithHandler:^ {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            rows += 10;
            [contentView reloadData];
            [contentView.refreshHeader endRefresh];
            contentView.refreshFooter.loadMoreEnabled = YES;
        });
    }];
    
    //上拉加载更多
    tableView.refreshFooter = [tableView addRefreshFooterWithHandler:^ {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            rows += 10;
            [contentView reloadData];
            [contentView.refreshFooter endRefresh];
            contentView.refreshFooter.loadMoreEnabled = YES;
        });

    }];
}

#pragma mark -- TSTView delegate

- (UIColor *)highlightColorForTSTView:(TSTView *)tstview
{
    return [UIColor colorWithHexString:@"#E0375C"];
}

- (UIColor *)normalColorForTSTView:(TSTView *)tstview
{
    return [UIColor grayColor];
}

- (UIColor *)normalColorForSeparatorInTSTView:(TSTView *)tstview
{
    return [UIColor grayColor];
}

- (UIColor *)normalColorForShadowViewInTSTView:(TSTView *)tstview
{
    return [UIColor colorWithHexString:@"#E0375C"];
}

#pragma mark -- UITableView data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return rows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *reuseIdentifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    }
    cell.textLabel.text = [NSString stringWithFormat:@"%@ %ld",self.titleDatas[tableView.tag],(long)indexPath.row];
    return cell;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
