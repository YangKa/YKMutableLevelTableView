//
//  YKMutableLevelTableView.h
//  MutableLevelTableView
//
//  Created by 杨卡 on 16/9/8.
//  Copyright © 2016年 杨卡. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YKNodeModel.h"

typedef void(^YKSelectBlock)(YKNodeModel *node);

@interface YKMultiLevelTableView : UITableView

- (id)initWithFrame:(CGRect)frame nodes:(NSArray*)nodes rootNodeID:(NSString*)rootID needPreservation:(BOOL)need selectBlock:(YKSelectBlock)block;
@end
