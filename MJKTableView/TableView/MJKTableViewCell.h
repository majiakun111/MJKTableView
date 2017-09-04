//
//  MJKTableViewCell.h
//  MJKTableView
//
//  Created by Ansel on 2017/9/4.
//  Copyright © 2017年 Ansel. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MJKTableViewCell : UIView

@property (nonatomic, copy) NSString *reuseIdentifier;
@property (nonatomic, strong) NSIndexPath *indexPath;

- (instancetype)initWithReuseIdentifer:(NSString *)reuseIdentifier;

@end
