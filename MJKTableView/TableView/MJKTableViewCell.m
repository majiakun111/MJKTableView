//
//  MJKTableViewCell.m
//  MJKTableView
//
//  Created by Ansel on 2017/9/4.
//  Copyright © 2017年 Ansel. All rights reserved.
//

#import "MJKTableViewCell.h"

@implementation MJKTableViewCell

- (instancetype)initWithReuseIdentifer:(NSString *)reuseIdentifier
{
    self = [super init];
    if (self) {
        self.reuseIdentifier = reuseIdentifier;
        self.userInteractionEnabled = YES;
    }
    
    return self;
}

@end
