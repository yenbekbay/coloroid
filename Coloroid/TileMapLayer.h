//
//  TileMapLayer.h
//  Coloroid
//
//  Created by Ayan Yenbekbay on 4/18/14.
//  Copyright (c) 2014 Ayan Yenbekbay. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "Tile.h"

@interface TileMapLayer : SKNode

@property (nonatomic, readonly) CGSize tileSize;
@property (nonatomic, readonly) CGSize gridSize;
@property (nonatomic, readonly) CGSize layerSize;
@property (nonatomic, readonly, strong) NSMutableArray *array;

- (instancetype)initWithGrid:(NSArray *)grid
                      isGoal:(BOOL)goal;
- (Tile *)getTileForLocation:(CGPoint)location;
- (Tile *)getTileForDirection:(NSInteger)direction activeTile:(Tile*)activeTile;
- (void)reset;

@end
