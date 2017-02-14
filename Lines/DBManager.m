//
//  DBManager.m
//  Lines
//
//  Created by qf on 15/4/29.
//  Copyright (c) 2015年 qf. All rights reserved.
//

#import "DBManager.h"
#import <sqlite3.h>
@interface DBManager (){
	sqlite3 *_sqldb;
}

@end

@implementation DBManager

static DBManager *sharedManager = nil;

//获取document目录并返回数据库目录
- (NSString *)dataFilePath{
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
	NSLog(@"=======%@",documentsDirectory);
	NSString *filePath = [documentsDirectory stringByAppendingPathComponent:@"games.db"];
	
	if (![fileManager fileExistsAtPath:filePath]) {
		//不存在就创建
		NSString *dbPath = [[NSBundle mainBundle] pathForResource:@"games" ofType:@"sqlite"];
		NSError *error = nil;
		[fileManager copyItemAtPath:dbPath toPath:filePath error:&error];
		if (error) {
			NSLog(@"%@",error);
		}
	}
	
	return filePath;
}

//打开数据库
- (BOOL)openDB{
	NSString *dbPath = [self dataFilePath];
	if (dbPath) {
		int result = sqlite3_open([dbPath UTF8String], &_sqldb);
		if (result == SQLITE_OK) {
			NSLog(@"数据库连接成功");
			return YES;
		}else{
			NSLog(@"数据库连接出错！");
			sqlite3_close(_sqldb);
			return NO;
		}
	}else{
		NSLog(@"未找到数据库");
		return NO;
	}
	return NO;
}

//for test
- (void)selectAllData:(void(^)(NSArray *result)) success{
	NSString *query = @"select * from games where num < 40";
	printf("%s\n",[query UTF8String]);
	//用于操作sql语句的结果
	sqlite3_stmt *statement;
	//判断语句是否合法
	int legal = sqlite3_prepare_v2(_sqldb, [query UTF8String], -1, &statement, NULL);
	NSLog(@"%d",legal);
	if (legal == SQLITE_OK){
		while (sqlite3_step(statement) == SQLITE_ROW) {
			NSNumber *num = [[NSNumber alloc] initWithInt:sqlite3_column_int(statement, 0)];
			NSString *diff = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 1)];
			NSString *question = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 2)];
			NSString *solution = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 3)];
			int solved = sqlite3_column_int(statement, 4);
			NSLog(@"select %@ %@ %@ %@ %d\n",num,diff, question, solution,solved);
		}
	}else{
		NSLog(@"sql语句语法错误或无法连接到数据库");
	}
}

//查询难度为difficult的所有题目
- (void)selectDataWithDifficult:(NSString *)difficult success:(void(^)(NSArray *result)) success{
//	if ([self openDB]) {
		NSString *query;
		if (![difficult isEqualToString: @"All"]) {
			query = [NSString stringWithFormat:@"select num, difficult, solved from games where difficult = '%@'", difficult];
		}else{
			query = @"select num, difficult, solved from games order by num asc";
		}
		
		sqlite3_stmt *statement;
		int legal = sqlite3_prepare_v2(_sqldb, [query UTF8String], -1, &statement, NULL);
		if (legal == SQLITE_OK) {
			NSMutableArray *arr = [[NSMutableArray alloc] initWithCapacity:42];
			while (sqlite3_step(statement) == SQLITE_ROW) {
				NSNumber *num = [[NSNumber alloc] initWithInt:sqlite3_column_int(statement, 0)];
				NSString *diff = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 1)];
				NSNumber *solved = [[NSNumber alloc] initWithInt: sqlite3_column_int(statement, 2)];
				NSDictionary *dic = @{@"num": num,
									  @"difficult": diff,
									  @"solved": solved
									  };
				[arr addObject:dic];
			}
			success(arr);
		}else{
			NSLog(@"sql语句语法错误或无法连接到数据库");
		}
		sqlite3_close(_sqldb);
//	}
	
}

//查询编号为Num的题目信息
- (void)selectDataWithNum:(NSNumber *)num success:(void(^)(NSDictionary *result)) success{
//	if ([self openDB]) {
		NSString *query = [NSString stringWithFormat:@"select * from games where num = %@",num];
		NSDictionary *result = nil;
		//用于操作sql语句的结果
		sqlite3_stmt *statement;
		//判断语句是否合法
		int legal = sqlite3_prepare_v2(_sqldb, [query UTF8String], -1, &statement, NULL);
		if (legal == SQLITE_OK){
			while (sqlite3_step(statement) == SQLITE_ROW) {
				NSNumber *num = [[NSNumber alloc] initWithInt:sqlite3_column_int(statement, 0)];
				NSString *diff = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 1)];
				NSString *question = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 2)];
				NSString *solution = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 3)];
				NSNumber *solved = [[NSNumber alloc] initWithInt: sqlite3_column_int(statement, 4)];
				result = @{@"num": num,
						   @"difficult": diff,
						   @"question": question,
						   @"solution": solution,
						   @"solved": solved
						   };
				success(result);
			}
		}else{
			NSLog(@"sql语句语法错误或无法连接到数据库");
		}
		sqlite3_close(_sqldb);
//	}
}

//查询难度为difficult 编号Num > number 的第一个题目
- (void)selectDataWithDifficult:(NSString *)difficult andNumLargeThenNum:(NSNumber*)number success:(void (^)(NSDictionary *))success{
//	if ([self openDB]) {
		NSString *query = [NSString stringWithFormat:@"select * from games where difficult = '%@' and num > %@ order by num limit 1", difficult, number];
		sqlite3_stmt *statement;
		NSDictionary *result = nil;
		int legal = sqlite3_prepare_v2(_sqldb, [query UTF8String], -1, &statement, NULL);
		if (legal == SQLITE_OK) {
			if (sqlite3_step(statement) == SQLITE_ROW) {
				NSNumber *num = [[NSNumber alloc] initWithInt:sqlite3_column_int(statement, 0)];
				NSString *diff = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 1)];
				NSString *question = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 2)];
				NSString *solution = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 3)];
				NSNumber *solved = [[NSNumber alloc] initWithInt: sqlite3_column_int(statement, 4)];
				result = @{@"num": num,
						   @"difficult": diff,
						   @"question": question,
						   @"solution": solution,
						   @"solved": solved
						   };
			}
		}
		success(result);
		sqlite3_close(_sqldb);
//	}
	
}


//更新解决情况
- (void)updateAGameSolvedWithNum:(NSNumber *)num{
//	if ([self openDB]) {
		NSString *query = [NSString stringWithFormat:@"update games set solved = 1 where num = %@",num ];
		NSLog(@"sql: %@",query);
		//用于操作sql语句的结果
		sqlite3_stmt *statement;
		//判断语句是否合法
		int legal = sqlite3_prepare_v2(_sqldb, [query UTF8String], -1, &statement, NULL);
		if (legal == SQLITE_OK){
			if (sqlite3_step(statement) == SQLITE_DONE){
				NSLog(@"修改成功");
				sqlite3_close(_sqldb);
			}else{
				NSLog(@"修改失败");
				sqlite3_close(_sqldb);
			}
		}
//	}
}

//查询难度为difficult的题目数，以及解决数
- (void)selectNumOfDifficult:(NSString *)difficult success:(void (^)(int,int))success{
	NSString *query = @"select count(*) from games ";
	NSString *query2 = nil;
	if (![difficult isEqualToString:@"All"]) {
		query = [query stringByAppendingFormat:@"where difficult = '%@'",difficult];
		query2 = [query stringByAppendingString:@"and solved = 1"];
	}else{
		query2 = [query stringByAppendingString:@"where solved = 1"];
	}
	NSLog(@"sql: %@",query);
	NSLog(@"sql: %@",query2);
	sqlite3_stmt *statement;
	int totalCnt = 0,solvedCnt = 0;
	int legal = sqlite3_prepare_v2(_sqldb, [query UTF8String], -1, &statement, NULL);
	if (legal == SQLITE_OK) {
		if (sqlite3_step(statement) == SQLITE_ROW) {
			totalCnt = sqlite3_column_int(statement, 0);
		}
	}
	legal = sqlite3_prepare_v2(_sqldb, [query2 UTF8String], -1, &statement, NULL);
	if (legal == SQLITE_OK) {
		if (sqlite3_step(statement) == SQLITE_ROW) {
			solvedCnt = sqlite3_column_int(statement, 0);
		}
	}
	success(totalCnt,solvedCnt);
}


+ (DBManager *)sharedDBManager{
	@synchronized(self){
		if (sharedManager == nil) {
			sharedManager = [[DBManager alloc] init];
		}
	}
	return sharedManager;
}

- (id)copyWithZone:(NSZone *)zone{
	return self;
}
@end
