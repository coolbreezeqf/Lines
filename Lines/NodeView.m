//
//  NodeView.m
//  Lines
//
//  Created by qf on 15/4/30.
//  Copyright (c) 2015年 qf. All rights reserved.
//

#import "NodeView.h"

@interface NodeView ()

@property (nonatomic,strong) UILabel *textLabel;
@end


@implementation NodeView

- (instancetype)initWithFrame:(CGRect)frame andType:(NodeType) type{
	return [self initWithFrame:frame type:type andText:'0'];
}

- (instancetype)initWithFrame:(CGRect)frame type:(NodeType) type andText:(unichar)textString{
	if (self = [super initWithFrame:frame]) {
		_type = type;
		self.layer.borderWidth = 1;
		self.layer.borderColor = [UIColor blackColor].CGColor;
		self.backgroundColor = [UIColor whiteColor];
		if (_type == NodeTypeWithe && textString != '0') {
			_textLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.width)];
			_textLabel.textAlignment = NSTextAlignmentCenter;
			_textLabel.text = [NSString stringWithFormat:@"%c", textString];
			_textLabel.font = [UIFont systemFontOfSize:20];
			_textLabel.textColor = [UIColor blueColor];
			[self addSubview:_textLabel];
		}
	}
	return self;
}

- (instancetype)initWithType:(NodeType) type{
	if (self = [super init]) {
		_type = type;
	}
	return self;
}

- (void)setType:(NodeType)type{
	if (_type != type) {
		_type = type;
		[self setNeedsDisplay];
	}
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
//	CGFloat width = 20;
//	CGRect sr = self.frame;
//	CGFloat halfHeight = CGRectGetHeight(sr) / 2;
//	CGFloat halfWidth = CGRectGetWidth(sr) / 2;
	
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextSetLineWidth(context, 20);
	CGContextSetLineCap(context, kCGLineCapSquare);
	CGContextSetStrokeColorWithColor(context, [UIColor blackColor].CGColor);
	CGContextSetLineJoin(context, kCGLineJoinMiter);
	[[UIColor grayColor] set];
	int x = 30;
	int y = 30;
	if (_type & NodeTypeNorth) {
		CGContextMoveToPoint(context, x, y);
		CGContextAddLineToPoint(context, x, 0);
		CGContextStrokePath(context);
	}
	if (_type & NodeTypeWest) {
		CGContextMoveToPoint(context, x, y);
		CGContextAddLineToPoint(context, 0, y);
		CGContextStrokePath(context);
	}
	if (_type & NodeTypeSouth) {
//		CGRect r = CGRectMake(halfWidth - width / 2, halfHeight, width, halfHeight);
		CGContextMoveToPoint(context, x, y);
		CGContextAddLineToPoint(context, x, y*2);
		CGContextStrokePath(context);
	}
	if (_type & NodeTypeEast) {
//		CGRect r = CGRectMake(halfWidth, halfHeight - width / 2, halfWidth, width);
		CGContextMoveToPoint(context, x, y);
		CGContextAddLineToPoint(context, 2*x, y);
		CGContextStrokePath(context);
	}
}


@end
