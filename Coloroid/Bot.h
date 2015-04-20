//
//  Bot.h
//  Coloroid
//
//  Created by Ayan Yenbekbay on 4/19/14.
//  Copyright (c) 2014 Ayan Yenbekbay. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "Tile.h"

@interface Bot : SKNode

@property (nonatomic) CGPoint location;
@property (nonatomic) NSInteger direction;
@property (nonatomic, strong) SKSpriteNode *bucketColor;
@property (nonatomic, readonly) BOOL active;

- (void)turnLeft;
- (void)turnRight;
- (void)activate:(BOOL)reverse;

@end
