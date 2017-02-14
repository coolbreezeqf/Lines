//
//  NodeView.h
//  Lines
//
//  Created by qf on 15/4/30.
//  Copyright (c) 2015年 qf. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, NodeType) {
	NodeTypeWithe = 0,		//display a int value
	NodeTypeWest = 1 << 0,	//a western line
	NodeTypeEast = 1 << 1,	//a eastern line
	NodeTypeNorth = 1 << 2, //a northern line
	NodeTypeSouth = 1 << 3, //a southern line
//	NodeTypeWE = 1,		//a western and eastern line     1 << 0 | 1 << 2
//	NodeTypeWN = 2,		//a western and northern line
//	NodeTypeWS = 3,		//a western and southern line
//	NodeTypeEN = 4,		//a eastern and northern line
//	NodeTypeES = 5,		//a eastern and southern line
//	NodeTypeNS = 6,		//a northern and southern line
};

@interface NodeView : UIView

@property (nonatomic,assign) NodeType type;

- (instancetype)initWithType:(NodeType) type;
- (instancetype)initWithFrame:(CGRect)frame andType:(NodeType) type;
- (instancetype)initWithFrame:(CGRect)frame type:(NodeType) type andText:(unichar)textString;
@end
