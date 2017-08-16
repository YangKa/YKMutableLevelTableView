//
//  YKNodeModel.m
//  MutableLevelTableView
//
//  Created by 杨卡 on 16/9/8.
//  Copyright © 2016年 杨卡. All rights reserved.
//

#import "YKNodeModel.h"

@implementation YKNodeModel

+ (instancetype)nodeWithParentID:(NSString *)parentID name:(NSString *)name childrenID:(NSString *)childrenID isExpand:(BOOL)bol{
    return [self nodeWithParentID:parentID name:name childrenID:childrenID level:-1 isExpand:bol];
}

+ (instancetype)nodeWithParentID:(NSString*)parentID name:(NSString*)name childrenID:(NSString*)childrenID level:(NSUInteger)level isExpand:(BOOL)bol{
    
    YKNodeModel *node = [[YKNodeModel alloc] init];
    node.parentID = parentID;
    node.name = name;
    node.childrenID = childrenID;
    node.level = level;
    node.expand = bol;
    
    return node;
}

@end
