//
//  MJKTableView.m
//  MJKTableView
//
//  Created by Ansel on 2017/9/4.
//  Copyright © 2017年 Ansel. All rights reserved.
//

#import "MJKTableView.h"

static const CGFloat DefaultCellHeight = 40.0;

@interface MJKCellInfo : NSObject

@property (nonatomic, strong) NSIndexPath *indexPath;
@property (nonatomic, assign) CGRect frame;

@end

@implementation MJKCellInfo

@end

@interface MJKTableView ()

@property (nonatomic, strong) NSSet<MJKTableViewCell*> *lastVisiableCellSet;
@property (nonatomic, strong) NSMutableSet<MJKTableViewCell*> *cacheCellSet;
@property (nonatomic, strong) NSMutableArray<MJKCellInfo*> *cellInfoArray;

@end

@implementation MJKTableView

@synthesize delegate = _delegate;

- (void)dealloc
{
    self.dataSource = nil;
    self.delegate = nil;
    
    [self removeObserver];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self addObserver];
    }
    
    return self;
}

- (__kindof MJKTableViewCell *)dequeueReusableCellWithIdentifier:(NSString *)identifier forIndexPath:(NSIndexPath *)indexPath
{
    __block MJKTableViewCell *cell = nil;
    //1.先从可见的lastVisiableCellSet取
    [self.lastVisiableCellSet enumerateObjectsUsingBlock:^(MJKTableViewCell * _Nonnull obj, BOOL * _Nonnull stop) {
        if (![obj.reuseIdentifier isEqual:identifier]) {
            return;
        }
        
        if ((obj.indexPath.section ==  indexPath.section) && (obj.indexPath.row ==  indexPath.row)) {
            cell = obj;
            *stop = YES;
        }
    }];
    
    if (cell) {
        return cell;
    }
    
    //2.再从缓存的cacheCellSet取
    [self.cacheCellSet enumerateObjectsUsingBlock:^(MJKTableViewCell * _Nonnull obj, BOOL * _Nonnull stop) {
        if ([obj.reuseIdentifier isEqual:identifier]) {
            cell = obj;
            *stop = YES;
        }
    }];
    
    if (cell) {
        [self.cacheCellSet removeObject:cell];
    }
    
    return cell;
}

- (void)reloadData
{
    //1. 分析CellInfo和计算contentSize
    [self analyzeCellInfosAndCalculateContentSize];
    
    //2. 布局cell
    [self layoutNeedDisplayCells];
}

#pragma mark - Override

- (void)didMoveToSuperview
{
    [super didMoveToSuperview];
    
    [self reloadData];
}

#pragma mark - Property

- (NSMutableSet<MJKTableViewCell *> *)cacheCellSet
{
    if (nil == _cacheCellSet) {
        _cacheCellSet = [[NSMutableSet alloc] init];
    }
    
    return _cacheCellSet;
}

- (NSMutableArray<MJKCellInfo *> *)cellInfoArray
{
    if (nil == _cellInfoArray) {
        _cellInfoArray = [[NSMutableArray alloc] init];
    }
    
    return _cellInfoArray;
}

#pragma mark - Notification

- (void)addObserver
{
    [self addObserver:self forKeyPath:NSStringFromSelector(@selector(contentOffset)) options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
}

- (void)removeObserver
{
    [self removeObserver:self forKeyPath:NSStringFromSelector(@selector(contentOffset))];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    if (![keyPath isEqualToString:NSStringFromSelector(@selector(contentOffset))]) {
        return;
    }
    
    CGPoint contentOffsetOld  = [change[NSKeyValueChangeOldKey] CGPointValue];
    CGPoint contentOffset = [change[NSKeyValueChangeNewKey] CGPointValue];
    if (!CGPointEqualToPoint(contentOffsetOld, contentOffset)) {
        [self layoutNeedDisplayCells];
    }
}

#pragma mark - PrivateMethod

- (void)analyzeCellInfosAndCalculateContentSize
{
    if (!self.delegate) {
        return;
    }
    
    self.cellInfoArray = nil;
    NSInteger sections = 1;
    if ([self.dataSource respondsToSelector:@selector(numberOfSectionsInTableView:)]) {
        sections = [self.dataSource numberOfSectionsInTableView:self];
    }
    
    CGFloat totalHeight = 0.0;
    for (NSInteger section = 0; section < sections; section++) {
        NSInteger rows = [self.dataSource tableView:self numberOfRowsInSection:section];
        for (NSInteger row = 0; row < rows ; row++) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:section];
            CGFloat cellHeight = DefaultCellHeight;
            if ([self.delegate respondsToSelector:@selector(tableView:heightForRowAtIndexPath:)]) {
                cellHeight = [self.delegate tableView:self heightForRowAtIndexPath:indexPath];
            }
            
            //记录每一个Cell的位置
            MJKCellInfo *cellInfo = [[MJKCellInfo alloc] init];
            cellInfo.indexPath = indexPath;
            //当前的cell y就是之前all cell height
            cellInfo.frame = CGRectMake(0, totalHeight, self.frame.size.width, cellHeight);
            [self.cellInfoArray addObject:cellInfo];
            
            totalHeight += cellHeight;
        }
    }
    
    CGSize size = CGSizeMake(self.frame.size.width, totalHeight);
    [self setContentSize:size];
}

- (void)layoutNeedDisplayCells
{
    if (!self.delegate) {
        return;
    }
    
    NSArray<MJKCellInfo*> *needDisplayCellInfoArray = [self getNeedDisplayCellInfoArray];
    if ([needDisplayCellInfoArray count] <= 0) {
        return;
    }
    
    //把之前可见 现在不可见的放入到cacheCellMap后并父视图中移除
    [self.lastVisiableCellSet enumerateObjectsUsingBlock:^(MJKTableViewCell * _Nonnull cell, BOOL * _Nonnull stop) {
        BOOL result = NO;
        for (MJKCellInfo *cellInfo in needDisplayCellInfoArray) {
            if ((cellInfo.indexPath.section == cell.indexPath.section) && (cellInfo.indexPath.row == cell.indexPath.row)) {
                result = YES;
                break;
            }
        }
        
        if (!result) {
            [self.cacheCellSet addObject:cell];
            [cell removeFromSuperview];
        }
    }];
    
    NSMutableSet<MJKTableViewCell*> *currentVisiableCellSet = [[NSMutableSet alloc] init];
    for (MJKCellInfo *cellInfo in needDisplayCellInfoArray) {
        
        MJKTableViewCell *cell = [self.dataSource tableView:self cellForRowAtIndexPath:cellInfo.indexPath];
        cell.indexPath = cellInfo.indexPath;
        [cell setFrame:cellInfo.frame];
        if (![cell superview]) {
            //把cell添加到View上
            [self addSubview:cell];
        }
        
        //把cell标记为可见的cell
        [currentVisiableCellSet addObject:cell];
    }
    
    self.lastVisiableCellSet = currentVisiableCellSet;
}

- (NSArray<MJKCellInfo*> *)getNeedDisplayCellInfoArray
{
    CGFloat beginYOffset = self.contentOffset.y;
    NSInteger beginIndex = [self getIndexForYOffset:beginYOffset startIndex:0 endIndex:[self.cellInfoArray count] -1];
    if (beginIndex < 0) {
        return nil;
    }
    
    CGFloat endYOffset = self.contentOffset.y + self.frame.size.height;
    NSInteger endIndex = [self getEndIndexForYOffset:endYOffset startIndex:beginIndex endIndex:[self.cellInfoArray count] -1];
    if (endIndex < beginIndex) {
        return nil;
    }
    
    NSMutableArray *needDisplayCellInfoArray = @[].mutableCopy;
    for (NSInteger index = beginIndex; index <= endIndex; index++) {
        MJKCellInfo *cellInfo = [self.cellInfoArray objectAtIndex:index];
        [needDisplayCellInfoArray addObject:cellInfo];
    }
    
    return needDisplayCellInfoArray;
}

- (NSInteger)getIndexForYOffset:(CGFloat)yOffset startIndex:(NSInteger)startIndex endIndex:(NSInteger)endIndex
{
    if (endIndex < startIndex) {
        return -1;
    }
    
    NSInteger middleIndex = (startIndex + endIndex) / 2;
    if (middleIndex >= [self.cellInfoArray count]) {
        return -1;
    }
    
    MJKCellInfo *cellInfo = [self.cellInfoArray objectAtIndex:middleIndex];
    if (cellInfo.frame.origin.y <= yOffset  && cellInfo.frame.origin.y + cellInfo.frame.size.height > yOffset) {
        //cell的y小于yOffset 但是cell的bottom一定要大于yOffset
        return middleIndex;
    } else if (cellInfo.frame.origin.y > yOffset ) {
        //cell的y大于yOffset
        return [self getIndexForYOffset:yOffset startIndex:startIndex endIndex:middleIndex - 1 ];
    } else {
        //cell的y小于yOffset 切cell的bottom也要小于yOffset
        return [self getIndexForYOffset:yOffset startIndex:middleIndex + 1 endIndex:endIndex];
    }
}

- (NSInteger)getEndIndexForYOffset:(CGFloat)yOffset startIndex:(NSInteger)startIndex endIndex:(NSInteger)endIndex{
    //当所有cell的高度和都小于屏幕的高度时
    if (self.contentSize.height < self.frame.size.height) {
        return endIndex;
    }
    
    return [self getIndexForYOffset:yOffset startIndex:startIndex endIndex:endIndex];
}

@end
