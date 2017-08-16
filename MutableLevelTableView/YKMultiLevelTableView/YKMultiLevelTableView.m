//
//  YKMutableLevelTableView.m
//  MutableLevelTableView
//
//  Created by 杨卡 on 16/9/8.
//  Copyright © 2016年 杨卡. All rights reserved.
//

#import "YKMultiLevelTableView.h"
#import "YKNodeModel.h"


@interface YKNodeCell : UITableViewCell

@property (nonatomic, strong) YKNodeModel *node;

@property (nonatomic, strong) UIImageView *leftImage;

@property (nonatomic, strong) UILabel *nodeLabel;

@property (nonatomic, strong) UIView *line;

@property (nonatomic, assign) CGRect rect;

@end


#define RGB(r, g, b, a)         [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:(a)]
#define  RandomColor RGB(arc4random_uniform(255), arc4random_uniform(255), arc4random_uniform(255), 1.0)

static CGFloat const leftMargin = 30.0; //left indentation
@implementation YKNodeCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;

        _leftImage = [[UIImageView alloc] initWithFrame:CGRectZero];
        [self  addSubview:_leftImage];
        
        _nodeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _nodeLabel.font  =[UIFont systemFontOfSize:16];
        [self addSubview:_nodeLabel];
        
        _line = [[UIView alloc] initWithFrame:CGRectZero];
        _line.backgroundColor = [UIColor lightGrayColor];
        [self addSubview:_line];
    }
    return self;
}

- (void)setNode:(YKNodeModel *)node{
    _node = node;

    //set indentation
    CGFloat indentationX = (node.level-1)*leftMargin;
    [self moveNode:indentationX];
    
    //text color
    CGFloat rgbValue = (node.level-1)*50;
    _nodeLabel.textColor  = RGB(rgbValue, rgbValue, rgbValue, 1.0);
    
    
    _nodeLabel.text = node.name;
    if (node.isExpand || node.isLeaf) {
        _leftImage.image = [UIImage imageNamed:@"YK_minus"];
    }else{
        _leftImage.image = [UIImage imageNamed:@"YK_plus"];
    }
    
    //hidden left log for leaf node or not
   // _leftImage.hidden = node.isLeaf;
}

- (void)moveNode:(CGFloat)indentationX{
    
    CGFloat cellHeight = _rect.size.height;
    CGFloat cellWidth  = _rect.size.width;
    
    CGRect frame1 = CGRectMake(0, (cellHeight-leftMargin)/2, leftMargin, leftMargin);
    frame1.origin.x = indentationX;
    _leftImage.frame = frame1;
    
    CGRect frame = CGRectMake(leftMargin, 0, cellWidth-leftMargin, cellHeight);
    frame.origin.x = leftMargin+indentationX;
    _nodeLabel.frame = frame;
    
    CGRect frame2 = CGRectMake(0, cellHeight-1, cellWidth, 1);
    frame2.origin.x = indentationX;
    _line.frame = frame2;
}
@end


//_______________________________________________________________________________________________________________
#pragma mark 
#pragma mark YKMultiLevelTableView
@interface YKMultiLevelTableView ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, copy) NSString *rootID;

//all nodes
@property (nonatomic, copy) NSMutableArray *nodes;

//show the last status all child nodes keep when yes, or just show next level child nodes
@property (nonatomic, assign ,getter=isPreservation) BOOL preservation;

@property (nonatomic, strong) NSMutableArray *tempNodes;

@property (nonatomic, strong) NSMutableArray *reloadArray;

@property (nonatomic, copy) YKSelectBlock block;

@end

static CGFloat const cellHeight = 45.0;
@implementation YKMultiLevelTableView

#pragma mark
#pragma mark life cycle
- (id)initWithFrame:(CGRect)frame nodes:(NSArray*)nodes rootNodeID:(NSString*)rootID needPreservation:(BOOL)need selectBlock:(YKSelectBlock)block{
    self = [self initWithFrame:frame];
    if (self) {
        self.rootID = rootID ?: @"";
        self.preservation = need;
        self.nodes = [nodes copy];
        self.block = [block copy];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = [UIColor whiteColor];
        _tempNodes = [NSMutableArray array];
        _reloadArray = [NSMutableArray array];
        self.delegate = self;
        self.dataSource = self;
        self.separatorStyle =UITableViewCellSeparatorStyleNone;
    }
    return self;
}

#pragma mark
#pragma mark set node's leaf and root propertys ,and level
- (void)setNodes:(NSMutableArray *)nodes{
    _nodes = nodes;

    [self judgeLeafAndRootNodes];
    
    [self updateNodesLevel];
    
    [self addFirstLoadNodes];
    
    [self reloadData];
}

- (void)addFirstLoadNodes{
    // add parent nodes on the upper level
    for (int i = 0 ; i<_nodes.count;i++) {
        
    	YKNodeModel *node = _nodes[i];
        if (node.isRoot) {
            [_tempNodes addObject:node];
            
            if (node.isExpand) {
                [self expandNodesForParentID:node.childrenID insertIndex:[_tempNodes indexOfObject:node]];
            }
        }
    }
    [_reloadArray removeAllObjects];
}

//judge leaf node and root node
- (void)judgeLeafAndRootNodes{
    for (int i = 0 ; i<_nodes.count;i++) {
        YKNodeModel *node = _nodes[i];
        
        
        BOOL isLeaf = YES;
        BOOL isRoot = YES;
        for (YKNodeModel *tempNode in _nodes) {
            if ([tempNode.parentID isEqualToString:node.childrenID]) {
                isLeaf = NO;
            }
            if ([tempNode.childrenID isEqualToString:node.parentID]) {
                isRoot = NO;
            }
            if (!isRoot && !isLeaf) {
                break;
            }
        }
        node.leaf = isLeaf;
        node.root = isRoot;
    }
}

//set depath for all nodes
- (void)updateNodesLevel{
    [self setDepth:1 parentIDs:@[_rootID] childrenNodes:_nodes];
}

- (void)setDepth:(NSUInteger)level parentIDs:(NSArray*)parentIDs childrenNodes:(NSMutableArray*)childrenNodes{
    
    NSMutableArray *newParentIDs = [NSMutableArray array];
     NSMutableArray *leftNodes = [childrenNodes  mutableCopy];
    
    for (YKNodeModel *node in childrenNodes) {
        if ([parentIDs containsObject:node.parentID]) {
            node.level = level;
            [leftNodes removeObject:node];
            [newParentIDs addObject:node.childrenID];
        }
    }

    if (leftNodes.count>0) {
        level += 1;
        [self setDepth:level parentIDs:[newParentIDs copy] childrenNodes:leftNodes];
    }
}

#pragma mark
#pragma mark UITableView delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _tempNodes.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return cellHeight;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"cell";
    YKNodeCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[YKNodeCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    cell.rect  =CGRectMake(0, 0, CGRectGetWidth(self.frame), cellHeight);
    cell.node = [_tempNodes objectAtIndex:indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    YKNodeModel *currentNode = [_tempNodes objectAtIndex:indexPath.row];
    if (currentNode.isLeaf) {
        self.block(currentNode);
        return;
    }else{
        currentNode.expand = !currentNode.expand;
    }
    
    [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    
    [_reloadArray removeAllObjects];
    if (currentNode.isExpand) {
        //expand
        [self expandNodesForParentID:currentNode.childrenID insertIndex:indexPath.row];
        [tableView insertRowsAtIndexPaths:_reloadArray withRowAnimation:UITableViewRowAnimationNone];
    }else{
        //fold
        [self foldNodesForLevel:currentNode.level currentIndex:indexPath.row];
         [tableView deleteRowsAtIndexPaths:_reloadArray withRowAnimation:UITableViewRowAnimationNone];
    }
}

#pragma mark
#pragma mark fold and expand
- (void)foldNodesForLevel:(NSUInteger)level currentIndex:(NSUInteger)currentIndex{
    
    if (currentIndex+1<_tempNodes.count) {
        NSMutableArray *tempArr = [_tempNodes copy];
        for (NSUInteger i = currentIndex+1 ; i<tempArr.count;i++) {
            YKNodeModel *node = tempArr[i];
            if (node.level <= level) {
                break;
            }else{
                [_tempNodes removeObject:node];
                [_reloadArray addObject:[NSIndexPath indexPathForRow:i inSection:0]];//need reload nodes
            }
        }
    }
}

- (NSUInteger)expandNodesForParentID:(NSString*)parentID insertIndex:(NSUInteger)insertIndex{
   
    for (int i = 0 ; i<_nodes.count;i++) {
        YKNodeModel *node = _nodes[i];
        if ([node.parentID isEqualToString:parentID]) {
            if (!self.isPreservation) {
                node.expand = NO;
            }
            insertIndex++;
            [_tempNodes insertObject:node atIndex:insertIndex];
            [_reloadArray addObject:[NSIndexPath indexPathForRow:insertIndex inSection:0]];//need reload nodes
            
            if (node.isExpand) {
               insertIndex = [self expandNodesForParentID:node.childrenID insertIndex:insertIndex];
            }
        }
    }
    
    return insertIndex;
}



@end
