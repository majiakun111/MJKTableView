//
//  Cell.m
//  MJKTableView
//
//  Created by Ansel on 2017/9/4.
//  Copyright © 2017年 Ansel. All rights reserved.
//

#import "Cell.h"

@implementation Cell

- (void)dealloc
{
    NSLog(@"---------cell dealloc-----");
}

- (instancetype)initWithReuseIdentifer:(NSString *)reuseIdentifier
{
    NSLog(@"---------cell alloc-----");
    
    self = [super initWithReuseIdentifer:reuseIdentifier];
    if (self) {
        [self setBackgroundColor:[UIColor colorWithRed:(arc4random() % 256 ) / 255.0 green:(arc4random() % 256 ) / 255.0 blue:(arc4random() % 256 ) / 255.0 alpha:1.0]];
    }
    
    return self;
}

@end
