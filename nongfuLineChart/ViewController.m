//
//  ViewController.m
//  nongfuLineChart
//
//  Created by JooBank on 2018/10/19.
//  Copyright © 2018年 JooBank. All rights reserved.
//

#import "ViewController.h"
#import "SXLineChart.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self showChartView];
}

- (void)showChartView{
    SXLineChart *lineChart = [[SXLineChart alloc] initWithFrame:CGRectMake(7, 100, [UIScreen mainScreen].bounds.size.width - 14, 112) andChartArray:nil];
    [self.view addSubview:lineChart];
}


@end
