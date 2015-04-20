//
//  Function.h
//  Coloroid
//
//  Created by Ayan Yenbekbay on 4/24/14.
//  Copyright (c) 2014 Ayan Yenbekbay. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "Command.h"

@interface Function : SKNode

@property (nonatomic, strong) NSMutableArray *commands;
@property (nonatomic, readonly) CGSize layerSize;
@property (nonatomic) int numOfCommands;
@property (nonatomic) int runningCommand;

- (instancetype)initWithIndex:(int)index;
- (void)addCommand:(Command*)command;
- (void)replaceCommand:(Command*)replaceable with:(Command*)new;
- (CGPoint)getSpot:(int)i;
- (void)update;
- (void)moveTo:(NSString*)dir from:(int)index;
- (void)clean;
- (void)reset;

@end
