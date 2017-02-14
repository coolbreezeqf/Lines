//
//  ViewController.m
//  Lines
//
//  Created by qf on 15/4/29.
//  Copyright (c) 2015年 qf. All rights reserved.
//

#import "ViewController.h"
#import "DBManager.h"
#import "GameViewController.h"
#import "GameListTableViewController.h"
@interface ViewController ()<UITableViewDelegate,UITableViewDataSource>{
	NSArray *difficult;
}

@property (nonatomic,strong) UITableView *tableView;

@end

@implementation ViewController

- (void)initData{
	difficult = @[@"All", @"Super easy", @"Easy", @"Medium", @"Hard", @"Very Hard"];
//	DBManager *manager = [DBManager sharedDBManager];
//	[manager openDB];
//	[manager selectAllData:^(NSArray *reslut) {
//		
//	}];
}

- (void)viewDidLoad {
	[super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
	[self initData];
	
	self.title = @"Select Difficult";
//	self.navigationController.navigationBar.barTintColor = [UIColor blackColor];
	_tableView = [[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStyleGrouped];
	_tableView.delegate = self;
	_tableView.dataSource = self;
	[self.view addSubview:_tableView];
	
//	[self.navigationController pushViewController:[[GameViewController alloc] initWithGameData:nil] animated:YES];
}

- (void)viewWillAppear:(BOOL)animated{
	[_tableView reloadData];
}

#pragma mark - tableView delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
	return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
	if (section == 0) {
		return [difficult count];
	}else{
		return 1;
	}
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
	UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"DifficultCell"];
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	if (indexPath.section == 0) {
		DBManager *db = [DBManager sharedDBManager];
		[db selectNumOfDifficult:difficult[indexPath.row] success:^(int total, int solved) {
			cell.textLabel.text = difficult[indexPath.row];
			cell.detailTextLabel.text = [NSString stringWithFormat:@"%d/%d",solved, total];
		}];
	}else{
		cell.textLabel.text = @"How to play!";
	}
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
	if (indexPath.section == 1) {
		DBManager *db = [DBManager sharedDBManager];
		[db selectDataWithNum:[NSNumber numberWithInt:1] success:^(NSDictionary *result) {
			GameViewController *htpGame = [[GameViewController alloc] initWithGameData:result];
			[self.navigationController pushViewController:htpGame animated:YES];
			[htpGame showSolution];
		}];
		return;
	}
	DBManager *db = [DBManager sharedDBManager];
	[db selectDataWithDifficult:difficult[indexPath.row] success:^(NSArray *result) {
		GameListTableViewController *gamelist = [[GameListTableViewController alloc] initWithStyle:UITableViewStylePlain];
		gamelist.gameList = result;
		gamelist.identity = difficult[indexPath.row];
		[self.navigationController pushViewController:gamelist animated:YES];
	}];
}



- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

@end
