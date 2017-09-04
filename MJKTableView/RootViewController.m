//
//  ViewController.m
//  MJKTableView
//
//  Created by Ansel on 2017/9/4.
//  Copyright © 2017年 Ansel. All rights reserved.
//

#import "RootViewController.h"
#import "MJKTableView.h"
#import "Cell.h"

@interface RootViewController () <MJKTableViewDelegate, MJKTableViewDataSource>

@property (nonatomic, strong) MJKTableView *tableView;

@end

@implementation RootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self buildUI];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - PrivateMethod

- (void)buildUI
{
    [self setAutomaticallyAdjustsScrollViewInsets:NO];
    [self.view setBackgroundColor:[UIColor redColor]];
    
    [self.view addSubview:self.tableView];
}

#pragma mark - Property

- (MJKTableView *)tableView
{
    if (nil == _tableView) {
        _tableView = [[MJKTableView alloc] initWithFrame:self.view.bounds];
        [_tableView setBackgroundColor:[UIColor blueColor]];
        _tableView.delegate = self;
        _tableView.dataSource = self;
    }
    
    return _tableView;
}

#pragma mark - MJKTableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(MJKTableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(MJKTableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 20;
}

- (MJKTableViewCell *)tableView:(MJKTableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * const cellIdentifer = @"Cell";
    Cell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifer];
    if (!cell) {
        cell = [[Cell alloc] initWithReuseIdentifer:cellIdentifer];
    }
    
    return cell;
}

#pragma mark - MJKTableViewDelegate

- (CGFloat)tableView:(MJKTableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 120;
}

@end
