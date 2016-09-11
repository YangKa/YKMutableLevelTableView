//
//  ViewController.m
//  MutableLevelTableView
//
//  Created by 杨卡 on 16/9/8.
//  Copyright © 2016年 杨卡. All rights reserved.
//

#import "ViewController.h"
#import "YKMultiLevelTableView.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    CGRect rect = self.view.frame;
    CGRect frame = CGRectMake(20, 20, CGRectGetWidth(rect)-40, CGRectGetHeight(rect)-20);
    YKMultiLevelTableView *mutableTable = [[YKMultiLevelTableView alloc] initWithFrame:frame
                                                                                     nodes:[self returnData]
                                                                                    rootNodeID:@""
                                                                          needPreservation:YES
                                                                               selectBlock:^(YKNodeModel *node) {
                                                                                   NSLog(@"--select node name=%@", node.name);
                                                                                   
    }];
    [self.view addSubview:mutableTable];
    
}

- (NSMutableArray*)returnData{
    YKNodeModel *node1  = [YKNodeModel nodeWithParentID:@"" name:@"Node1" childrenID:@"1" level:1 isExpand:NO];
    
    YKNodeModel *node10 = [YKNodeModel nodeWithParentID:@"1" name:@"Node10" childrenID:@"10" level:2 isExpand:NO];
    YKNodeModel *node11 = [YKNodeModel nodeWithParentID:@"1" name:@"Node11" childrenID:@"11" level:2 isExpand:NO];
    
    YKNodeModel *node100 = [YKNodeModel nodeWithParentID:@"10" name:@"Node100" childrenID:@"100" level:3 isExpand:NO];
    YKNodeModel *node101 = [YKNodeModel nodeWithParentID:@"10" name:@"Node101" childrenID:@"101" level:3 isExpand:NO];
    YKNodeModel *node110 = [YKNodeModel nodeWithParentID:@"11" name:@"Node110" childrenID:@"110" level:3 isExpand:NO];
    YKNodeModel *node111 = [YKNodeModel nodeWithParentID:@"11" name:@"Node111" childrenID:@"111" level:3 isExpand:NO];
    
    YKNodeModel *node1110 = [YKNodeModel nodeWithParentID:@"111" name:@"Node1110" childrenID:@"1110" level:4 isExpand:NO];
    YKNodeModel *node1111 = [YKNodeModel nodeWithParentID:@"111" name:@"Node1111" childrenID:@"1111" level:4 isExpand:NO];
    
    YKNodeModel *node2  = [YKNodeModel nodeWithParentID:@"" name:@"Node2" childrenID:@"2" level:1 isExpand:NO];
    
    YKNodeModel *node20 = [YKNodeModel nodeWithParentID:@"2" name:@"Node20" childrenID:@"20" level:2 isExpand:NO];
    YKNodeModel *node200 = [YKNodeModel nodeWithParentID:@"20" name:@"Node200" childrenID:@"200" level:3 isExpand:NO];
    YKNodeModel *node201 = [YKNodeModel nodeWithParentID:@"20" name:@"Node101" childrenID:@"201" level:3 isExpand:NO];
    YKNodeModel *node202 = [YKNodeModel nodeWithParentID:@"20" name:@"Node202" childrenID:@"202" level:3 isExpand:NO];
    
    YKNodeModel *node21 = [YKNodeModel nodeWithParentID:@"2" name:@"Node21" childrenID:@"21" level:2 isExpand:NO];
    YKNodeModel *node210 = [YKNodeModel nodeWithParentID:@"21" name:@"Node210" childrenID:@"210" level:3 isExpand:NO];
    YKNodeModel *node211 = [YKNodeModel nodeWithParentID:@"21" name:@"Node211" childrenID:@"211" level:3 isExpand:NO];
    YKNodeModel *node212 = [YKNodeModel nodeWithParentID:@"21" name:@"Node212" childrenID:@"212" level:3 isExpand:NO];
    YKNodeModel *node2110 = [YKNodeModel nodeWithParentID:@"211" name:@"Node2110" childrenID:@"2110" level:4 isExpand:NO];
    YKNodeModel *node2111 = [YKNodeModel nodeWithParentID:@"211" name:@"Node2111" childrenID:@"2111" level:4 isExpand:NO];
    
    return [NSMutableArray arrayWithObjects:node1,
                                                node10,
                                                    node100, node101,
                                                        node1110, node1111,
                                                node11,
                                                    node110, node111,
                                            node2,
                                                node20,
                                                    node200, node201, node202,
                                                node21,
                                                    node210, node211,
                                                                node2110, node2111,
                                                    node212,nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
