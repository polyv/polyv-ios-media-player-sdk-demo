//
//  PLVVodMediaFeedDataManager.m
//  PolyvIOSMediaPlayerDemo
//
//  Created by Dhan on 2023/9/7.
//

#import "PLVVodMediaFeedDataManager.h"
#import <PolyvMediaPlayerSDK/PolyvMediaPlayerSDK.h>

@interface PLVVodMediaFeedDataManager ()

@property (nonatomic, strong) dispatch_semaphore_t dataOperationLock; // 确保数组数据多线程操作安全
@property (nonatomic, strong) NSMutableArray *muData;

@end

@implementation PLVVodMediaFeedDataManager

#pragma mark 【Life Cycle】

- (instancetype)init {
    self = [super init];
    if (self) {
        _dataOperationLock = dispatch_semaphore_create(1);
        _muData = [[NSMutableArray alloc] init];
    }
    return self;
}

#pragma mark 【Public Method】

- (void)refreshWithData:(NSArray *)data {
    if (![PLVVodMediaFdUtil checkArrayUseable:data]) {
        return;
    }
    
    NSMutableArray *muArray = [[NSMutableArray alloc] initWithCapacity:[data count]];
    for (id object in data) {
        [muArray addObject:object];
    }
    if ([muArray count] == 0) {
        return;
    }
    
    LOCK(self.dataOperationLock);
    [self.muData removeAllObjects];
    [self.muData addObjectsFromArray:muArray];
    UNLOCK(self.dataOperationLock);
}

- (void)appendWithData:(NSArray *)data {
    if (![PLVVodMediaFdUtil checkArrayUseable:data]) {
        return;
    }
    NSMutableArray *muArray = [[NSMutableArray alloc] initWithCapacity:[data count]];
    
    for (id object in data) {
        [muArray addObject:object];
    }
    if ([muArray count] == 0) {
        return;
    }
    
    LOCK(self.dataOperationLock);
    [self.muData addObjectsFromArray:muArray];
    UNLOCK(self.dataOperationLock);
}

- (id)objectAtIndex:(NSInteger)index {
    if (![PLVVodMediaFdUtil checkArrayUseable:self.currentData]) {
        return nil;
    }
    
    if (self.currentData.count > index) {
         return self.currentData[index];
     }
     return nil;
}

- (void)addObject:(id)object {
    LOCK(self.dataOperationLock);
    [self.muData addObject:object];
    UNLOCK(self.dataOperationLock);
}

/// 移除所有数据
- (void)removeAll{
    LOCK(self.dataOperationLock);
    [self.muData removeAllObjects];
    UNLOCK(self.dataOperationLock);
}

- (NSArray *)currentData {
    LOCK(self.dataOperationLock);
    NSArray *currentData = [self.muData copy];
    UNLOCK(self.dataOperationLock);
    
    return currentData;
}


@end
