//
//  GameRule.m
//  Lines
//
//  Created by qf on 15/4/30.
//  Copyright (c) 2015年 qf. All rights reserved.
//

#import "GameRule.h"
#import "DBManager.h"
@interface GameRule (){
	NSInteger typeOfNodes[25];
}

@end

@implementation GameRule

- (instancetype)initWithDictionary:(NSDictionary *)dic{
	if (self = [super init]) {
		_num = dic[@"num"];
		_difficult = dic[@"difficult"];
		_question = dic[@"question"];
		_solution = dic[@"solution"];
		_sloved = [dic[@"sloved"] boolValue];
	}
	return self;
}

- (BOOL)changeNodeTypeOfIndex:(NSInteger)index type:(NSInteger )type{
	typeOfNodes[index] = type;
	return NO;
}

+ (NSInteger)transitionType:(char)type{
	NSInteger transition;
	switch (type) {
		case '0':transition = 0;break;
		case '1':transition = 3;break;
		case '2':transition = 5;break;
		case '3':transition = 9;break;
		case '4':transition = 6;break;
		case '5':transition = 10;break;
		case '6':transition = 12;break;
		default:break;
	}
	return transition;
}

- (char)transitionType:(NSInteger)type{
	char transition;
	switch (type) {
		case 0:transition = '0' + 0; break;
		case 3:transition = '0' + 1; break;
		case 5:transition = '0' + 2; break;
		case 9:transition = '0' + 3; break;
		case 6:transition = '0' + 4; break;
		case 10:transition = '0' + 5; break;
		case 12:transition = '0' + 6; break;
		default:transition = '0' + 0;break;
	}
	return transition;
}

- (BOOL)isSuccessed{
	//判断当前状态是否和solution一样，一样则完成
	//其实应该自己判断的链接是否正确。
	char transitionType[26];
	transitionType[25] = '\0';
	for (int i = 0; i < 25; i++) {
		transitionType[i] = [self transitionType:typeOfNodes[i]];
	}
	if ([_solution isEqualToString:[NSString stringWithUTF8String:transitionType]]) {
		DBManager *db = [DBManager sharedDBManager];
		[db updateAGameSolvedWithNum:_num];
		return YES;
	}
	return NO;
}

@end
