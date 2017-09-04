//
//  MJKTableView.h
//  MJKTableView
//
//  Created by Ansel on 2017/9/4.
//  Copyright © 2017年 Ansel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MJKTableViewCell.h"

@class MJKTableView;

@protocol MJKTableViewDataSource <NSObject>

@required
- (NSInteger)tableView:(MJKTableView *)tableView numberOfRowsInSection:(NSInteger)section;

- (__kindof MJKTableViewCell *)tableView:(MJKTableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;

@optional
- (NSInteger)numberOfSectionsInTableView:(MJKTableView *)tableView;

@end

@protocol MJKTableViewDelegate <NSObject, UIScrollViewDelegate>

@optional
- (CGFloat)tableView:(MJKTableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)tableView:(MJKTableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;

@end

@interface MJKTableView : UIScrollView

@property (nonatomic, weak) id<MJKTableViewDataSource> dataSource;
@property (nonatomic, weak) id<MJKTableViewDelegate> delegate;

- (__kindof MJKTableViewCell *)dequeueReusableCellWithIdentifier:(NSString *)identifier;

- (void)reloadData;

@end
