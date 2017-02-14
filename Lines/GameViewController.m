//
//  GameViewController.m
//  Lines
//
//  Created by qf on 15/4/30.
//  Copyright (c) 2015年 qf. All rights reserved.
//

#import "GameViewController.h"
#import "NodeView.h"
#import "GameRule.h"
#import "DBManager.h"
#define KNodeWidth 60

typedef struct {
	NSInteger row;		/* row */
	NSInteger col;		/* column */
} IndexDiv;

IndexDiv IndexDivMake(NSInteger row, NSInteger col){
	IndexDiv index;
	index.row = row;
	index.col = col;
	return index;
}

@interface GameViewController ()<UIAlertViewDelegate>{
	CGPoint beganTouchPoint;
	IndexDiv lastIndexDiv; //row , col
	NSInteger moves[25];
}

@property (nonatomic,strong) GameRule *rule;
@property (nonatomic,strong) NSDictionary *game;
@property (nonatomic,strong) NSMutableArray *nodes; //of NodeView
@property (nonatomic,strong) UIView *backgroundGrid;
@end

@implementation GameViewController

- (instancetype)initWithGameData:(NSDictionary *)game{
	if (self = [super init]) {
		_game = game;
		_nodes = [[NSMutableArray alloc] initWithCapacity:25];
		self.view.backgroundColor = [UIColor cyanColor];
	}
	return self;
}

- (void)loadGame{
	_rule = [[GameRule alloc] initWithDictionary:_game];

	NSString *game = _rule.question;
	NSString *title = [NSString stringWithFormat:@"NO. %@ %@",_rule.num, _rule.difficult];
	self.title = title;
	
	[_nodes makeObjectsPerformSelector:@selector(removeFromSuperview)];
	[_nodes removeAllObjects];
	for (int i = 0; i < 25; i++) {
		NodeView *node = [[NodeView alloc] initWithFrame:CGRectMake(i % 5 * 60, i / 5 * 60, KNodeWidth, KNodeWidth) type:NodeTypeWithe andText:[game characterAtIndex:i]];
		[self.backgroundGrid addSubview:node];
		[_nodes addObject:node];
		//		node.type = [GameRule transitionType:[solution characterAtIndex:i]];
	}
}

- (void)reloadGame:(NSDictionary *)gameDic{
	if(gameDic){
		_game = gameDic;
		_rule = [[GameRule alloc] initWithDictionary:gameDic];
		[self loadGame];
	}else{
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Contratulation" message:@"You have completed all questions" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
		[alert show];
	}
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
	
	NSInteger x = self.view.frame.size.width / 2 - 150;
	NSInteger y = self.view.frame.size.height / 2 - 150;
	_backgroundGrid = [[UIView alloc] initWithFrame:CGRectMake(x, y, KNodeWidth * 5, KNodeWidth*5)];
	_backgroundGrid.layer.borderWidth = 2;
	_backgroundGrid.layer.borderColor = [UIColor blackColor].CGColor;
	[self.view addSubview:_backgroundGrid];
	
//	UINavigationItem *item = [[UINavigationItem alloc] initWithTitle:@"题号"];
	
	UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:@"Restart" style:UIBarButtonItemStylePlain target:self action:@selector(loadGame)];
//	item.rightBarButtonItem = rightButton;
//	[self.navigationController.navigationBar pushNavigationItem:item animated:YES];
	self.navigationItem.rightBarButtonItem = rightButton;
	self.navigationController.navigationBar.barTintColor = [UIColor blueColor];
	UIButton *doneButton = [[UIButton alloc] initWithFrame:CGRectMake(_backgroundGrid.frame.origin.x, _backgroundGrid.frame.origin.y + _backgroundGrid.frame.size.height, _backgroundGrid.frame.size.width, 40)];
	doneButton.backgroundColor = [UIColor redColor];
	[doneButton setTitle:@"DONE" forState:UIControlStateNormal];
	[doneButton addTarget:self action:@selector(gameOver) forControlEvents:UIControlEventTouchDown];
	[self.view addSubview:doneButton];
	[self loadGame];
}

- (void)gameOver{
	if ([_rule isSuccessed]){

		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"success" message:@"Success! Go to next question" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:@"Next", nil];
		[alert show];
	}else{
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"failure" message:@"restart game" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alert show];
	}
}

- (void)nextGame{
	DBManager *db = [DBManager sharedDBManager];
	NSNumber *num = [NSNumber numberWithInt:[_game[@"num"] intValue] + 1];
	if ([_identity isEqualToString:@"All"]) {
		[db selectDataWithNum:num success:^(NSDictionary *result) {
			[self reloadGame:result];
		}];

	}else{
		[db selectDataWithDifficult:_rule.difficult andNumLargeThenNum:_rule.num success:^(NSDictionary *result) {
			[self reloadGame:result];
		}];
	}
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//the location of _backgroundGrid
- (IndexDiv)indexDivOfNodeBy:(CGPoint)location{
	NSInteger col = location.x / 60;
	NSInteger row = location.y / 60;
	return IndexDivMake(row, col);
}

- (void)showSolution{
	const char *solution = [_rule.solution UTF8String];
	for (int i = 0; i < [_nodes count]; i++) {
		NodeView *node = _nodes[i];
		if (solution[i] != '0') {
			node.type = [GameRule transitionType:solution[i]];
		}
	}
}



#pragma mark - touch event
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
	CGPoint location = [(UITouch *)[touches anyObject] locationInView:_backgroundGrid];
	if (location.x >= 0 && location.x <= CGRectGetWidth(_backgroundGrid.frame) &&
		location.y >= 0 && location.y <= CGRectGetHeight(_backgroundGrid.frame)) {
		beganTouchPoint = location;
		lastIndexDiv = [self indexDivOfNodeBy:location];
	}
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
	CGPoint loc = [(UITouch *)[touches anyObject] locationInView:_backgroundGrid];
	if (!(loc.x >= 0 && loc.x <= CGRectGetWidth(_backgroundGrid.frame) &&
		loc.y >= 0 && loc.y <= CGRectGetHeight(_backgroundGrid.frame))) {
		return;
	}
	IndexDiv curIndexDiv = [self indexDivOfNodeBy:loc];
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:1];
	if (curIndexDiv.col != lastIndexDiv.col		|| curIndexDiv.row != lastIndexDiv.row) {
		NSInteger li = lastIndexDiv.col + lastIndexDiv.row * 5;
		NSInteger ci = curIndexDiv.col + curIndexDiv.row * 5;
		if (ci >= 25) {
			return;
		}
		NodeView *lastNode = [_nodes objectAtIndex:li];
		NodeView *curNode = [_nodes objectAtIndex:ci];
		if (lastIndexDiv.row == curIndexDiv.row) {
			if (lastIndexDiv.col > curIndexDiv.col) {
				//move to left
				lastNode.type = lastNode.type | NodeTypeWest;
				curNode.type = curNode.type | NodeTypeEast;
			}else if(lastIndexDiv.col < curIndexDiv.col){
				//move to right
				lastNode.type = lastNode.type | NodeTypeEast;
				curNode.type = curNode.type | NodeTypeWest;
			}
		}else if(lastIndexDiv.col == curIndexDiv.col){
			if (lastIndexDiv.row > curIndexDiv.row) {
				//upwards
				lastNode.type = lastNode.type | NodeTypeNorth;
				curNode.type = curNode.type | NodeTypeSouth;
			}else{
				//downwards
				lastNode.type = lastNode.type | NodeTypeSouth;
				curNode.type = curNode.type | NodeTypeNorth;
			}
		}
		[_rule changeNodeTypeOfIndex:li type:lastNode.type];
		[_rule changeNodeTypeOfIndex:ci type:curNode.type];
		lastIndexDiv = curIndexDiv;
	}
	[UIView commitAnimations];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
	
}

#pragma mark - alert delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
	if (buttonIndex == 1) {
		[self nextGame];
	}
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
