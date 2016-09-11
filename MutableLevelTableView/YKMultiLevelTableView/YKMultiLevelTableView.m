//
//  YKMutableLevelTableView.m
//  MutableLevelTableView
//
//  Created by 杨卡 on 16/9/8.
//  Copyright © 2016年 杨卡. All rights reserved.
//

#import "YKMultiLevelTableView.h"
#import "YKNodeModel.h"


@interface YKNodeCell : UITableViewCell<UIContentContainer>

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

    CGFloat indentationX = 0;
    CGFloat rgbValue = 0;
    for (int i = 1; i<node.level;i++) {
        indentationX += leftMargin;
        rgbValue += 50;
    }
    //set indentation
    [self moveNode:indentationX];
    
    _nodeLabel.textColor  = RGB(rgbValue, rgbValue, rgbValue, 1.0);
    _nodeLabel.text = node.name;
    
    if (node.isExpand || node.isLeaf) {
        _leftImage.image = [UIImage imageNamed:@"YK_minus"];
    }else{
        _leftImage.image = [UIImage imageNamed:@"YK_plus"];
    }
    
    //_leftImage.hidden = node.isLeaf;//hidden left log for leaf node or not
}

- (void)moveNode:(CGFloat)indentationX{
    
    CGFloat cellHeight = _rect.size.height;
    CGFloat cellWidth  = _rect.size.width;
    
    CGRect frame = CGRectMake(leftMargin, 0, cellWidth-leftMargin, cellHeight);
    frame.origin.x = leftMargin+indentationX;
    _nodeLabel.frame = frame;
    
    CGRect frame1 = CGRectMake(0, (cellHeight-leftMargin)/2, leftMargin, leftMargin);
    frame1.origin.x = indentationX;
    _leftImage.frame = frame1;
    
    CGRect frame2 = CGRectMake(0, cellHeight-1, cellWidth, 1);
    frame2.origin.x = indentationX;
    _line.frame = frame2;
}
@end


//_______________________________________________________________________________________________________________
#pragma mark 
#pragma mark YKMultiLevelTableView
@interface YKMultiLevelTableView ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) NSString *rootID;

@property (nonatomic, strong) NSMutableArray *nodes;

//show the last status all child nodes keep when yes, or just show next level child nodes
@property (nonatomic, assign ,getter=isPreservation) BOOL preservation;

@property (nonatomic, strong) NSMutableArray *tempNodes;

@property (nonatomic, strong) NSMutableArray *reloadArray;

@property (nonatomic, copy) YKSelectBlock block;

@end

static CGFloat const cellHeight = 45.0;
@implementation YKMultiLevelTableView

- (id)initWithFrame:(CGRect)frame nodes:(NSArray*)nodes rootNodeID:(NSString*)rootID needPreservation:(BOOL)need selectBlock:(YKSelectBlock)block{
    self = [self initWithFrame:frame];
    if (self) {
        self.rootID = (!rootID) ? @"" : rootID;
        self.preservation = need;
        self.nodes = [nodes mutableCopy];
        self.block = block;
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

- (void)setNodes:(NSMutableArray *)nodes{
    _nodes = nodes;

    BOOL hasDepth = YES;
    for (int i = 0 ; i<nodes.count;i++) {
        YKNodeModel *node = nodes[i];
        
        //judge have set depth or not
        if (node.level<=0) {
            hasDepth = NO;
        }

        //judge leaf node and root node
        BOOL isLeaf = YES;
        BOOL isRoot = YES;
        for (YKNodeModel *tempNode in nodes) {
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
        
        
        // add parent nodes on the upper level
        if ([node.parentID isEqualToString:_rootID]) {
            [_tempNodes addObject:node];
        }
    }
    
    //set depath for all nodes
    if (!hasDepth) {
        [self setDepth:1 parentIDs:@[_rootID] childrenNodes:_nodes];
    }
    
    [self reloadData];
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
    
    [_reloadArray removeAllObjects];
    [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    
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

//fold
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

//expand
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
