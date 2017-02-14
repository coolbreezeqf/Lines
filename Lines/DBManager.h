//
//  DBManager.h
//  Lines
//
//  Created by qf on 15/4/29.
//  Copyright (c) 2015年 qf. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DBManager : NSObject

+ (DBManager *)sharedDBManager;
- (BOOL)openDB;
- (void)selectAllData:(void(^)(NSArray *reslut)) success;
//查询难度为difficult的所有题目
- (void)selectDataWithDifficult:(NSString *)difficult success:(void(^)(NSArray *result)) success;
//查询编号为Num的题目信息
- (void)selectDataWithNum:(NSNumber *)num success:(void(^)(NSDictionary *result)) success;
//更新解决情况
- (void)updateAGameSolvedWithNum:(NSNumber *)num;
//查询难度为difficult 编号Num > number 的第一个题目
- (void)selectDataWithDifficult:(NSString *)difficult andNumLargeThenNum:(NSNumber*)number success:(void (^)(NSDictionary *))success;
//查询难度为difficult的题目数，以及解决数
- (void)selectNumOfDifficult:(NSString *)difficult success:(void (^)(int total,int solved))success;
@end
