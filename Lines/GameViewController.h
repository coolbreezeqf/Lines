//
//  GameViewController.h
//  Lines
//
//  Created by qf on 15/4/30.
//  Copyright (c) 2015年 qf. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GameViewController : UIViewController

@property (nonatomic,strong) NSString *identity;
- (instancetype)initWithGameData:(NSDictionary *)game;
- (void)showSolution;
@end
