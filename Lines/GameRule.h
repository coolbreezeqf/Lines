//
//  GameRule.h
//  Lines
//
//  Created by qf on 15/4/30.
//  Copyright (c) 2015年 qf. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GameRule : NSObject

@property (nonatomic,strong) NSNumber *num;
@property (nonatomic,strong) NSString *difficult;
@property (nonatomic,strong) NSString *question;
@property (nonatomic,strong) NSString *solution;
@property (nonatomic) BOOL sloved;

+ (NSInteger)transitionType:(char)type;

- (instancetype)initWithDictionary:(NSDictionary *)dic;
- (BOOL)changeNodeTypeOfIndex:(NSInteger)index type:(NSInteger )type;
- (BOOL)isSuccessed; //解题成功
@end
