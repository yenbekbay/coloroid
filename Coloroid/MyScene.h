//
//  MyScene.h
//  Coloroid
//

//  Copyright (c) 2014 Ayan Yenbekbay. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "Tile.h"

@interface MyScene : SKScene

@property (nonatomic, strong) SKColor *activeColor;
@property (nonatomic, strong) Tile *activeTile;

@end
