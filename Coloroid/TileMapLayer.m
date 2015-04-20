//
//  TileMapLayer.m
//  Coloroid
//
//  Created by Ayan Yenbekbay on 4/18/14.
//  Copyright (c) 2014 Ayan Yenbekbay. All rights reserved.
//

#import "TileMapLayer.h"
#import "Tile.h"

@implementation TileMapLayer {
    BOOL _goal;
}

- (instancetype)initWithGrid:(NSArray *)grid
                      isGoal:(BOOL)goal {
    _goal = goal;
    if (self = [super init]) {
        int sideLength;
        if (!_goal) {
            sideLength = 288 / [grid.firstObject length];
            // TODO: screen height - 356.5
            if (sideLength * grid.count > 235) sideLength = 235 / grid.count;
        } else {
            sideLength = 50 / grid.count;
            if (sideLength * [grid.firstObject length] > 100) sideLength = 100 / [grid.firstObject length];
        }
        _tileSize = CGSizeMake(sideLength, sideLength);
        _gridSize = CGSizeMake([grid.firstObject length], grid.count);
        _layerSize = CGSizeMake(_tileSize.width * _gridSize.width,
                                _tileSize.height * _gridSize.height);
        _array = [NSMutableArray arrayWithCapacity:[grid.firstObject length]];

        for (int row = 0; row < grid.count; row++) {
            NSMutableArray *cols = [NSMutableArray arrayWithCapacity:grid.count];
            [self drawRowTape:row];
            NSString *line = grid[row];
            for(int col = 0; col < line.length; col++) {
                [self drawColTape:col row:row];
                unichar code;
                if (!_goal) {
                    code = 'w';
                } else {
                    code = [line characterAtIndex:col];
                }
                Tile *tile = [[Tile alloc] initWithCoordinates:CGPointMake(col, row)
                                                          code:code
                                                          size:_tileSize];
                tile.position = [self positionForRow:row col:col];
                tile.zPosition = -13;
                [self addChild:tile];
                [cols addObject:tile];
            }
            [_array addObject: cols];
        }
        
        int bevelDepth = 0;
        int bevelWidth = 0;
        if (!_goal) {
            bevelDepth = 15;
            bevelWidth = 5;
            
            [self drawBevelTopLeft:CGPointMake(-bevelWidth, self.layerSize.height - bevelDepth)
                        bottomLeft:CGPointMake(-bevelWidth, -bevelDepth)
                       bottomRight:CGPointZero
                          topRight:CGPointMake(0, self.layerSize.height)
                            darker: NO];
            
            [self drawBevelTopLeft:CGPointMake(self.layerSize.width, self.layerSize.height)
                        bottomLeft:CGPointMake(self.layerSize.width, 0)
                       bottomRight:CGPointMake(self.layerSize.width + bevelWidth, -bevelDepth)
                          topRight:CGPointMake(self.layerSize.width + bevelWidth, self.layerSize.height - bevelDepth)
                             darker: NO];
            
            [self drawBevelTopLeft:CGPointZero
                        bottomLeft:CGPointMake(-bevelWidth, -bevelDepth)
                       bottomRight:CGPointMake(self.layerSize.width + bevelWidth, -bevelDepth)
                          topRight:CGPointMake(self.layerSize.width, 0)
                            darker: YES];
            
        }
        
        [self drawBorder:bevelDepth bevelWidth:bevelWidth];
    }
    return self;
}

- (void)drawRowTape:(NSInteger)row {
    if (row != 0) {
        int width = 1;
        SKColor *color = SKColorWithRGB(85, 85, 85);
        if (!_goal) {
            width = 5;
            color = SKColorWithRGB(253, 241, 112);
        }
        UIBezierPath *path = [UIBezierPath bezierPath];
        [path moveToPoint:CGPointMake(0, self.layerSize.height - row * self.tileSize.height)];
        [path addLineToPoint:CGPointMake(self.layerSize.width,
                                         self.layerSize.height - row * self.tileSize.height)];
        SKShapeNode *tape = [SKShapeNode node];
        tape.path = path.CGPath;
        tape.strokeColor = color;
        tape.lineWidth = width;
        tape.zPosition = -11;
        tape.antialiased = NO;
        [self addChild:tape];
        
        if (!_goal) {
            SKShapeNode *tapeShadow = [SKShapeNode node];
            tapeShadow.path = path.CGPath;
            tapeShadow.strokeColor = SKColorWithRGBA(0, 0, 0, 50);
            tapeShadow.lineWidth = width + 1;
            tapeShadow.zPosition = -12;
            tapeShadow.antialiased = NO;
            tapeShadow.position = CGPointMake(tapeShadow.position.x, tapeShadow.position.y - 1);
            [self addChild:tapeShadow];
        }
    }
}

- (void)drawColTape:(NSInteger)col row:(NSInteger)row {
    if (row == 0) {
        if (col != 0) {
            int width = 1;
            SKColor *color = SKColorWithRGB(85, 85, 85);
            if (!_goal) {
                width = 5;
                color = SKColorWithRGB(253, 241, 112);
            }
            UIBezierPath *path = [UIBezierPath bezierPath];
            [path moveToPoint:CGPointMake(self.layerSize.width - col * self.tileSize.width, 0)];
            [path addLineToPoint:CGPointMake(self.layerSize.width - col * self.tileSize.width,
                                             self.layerSize.height)];
            SKShapeNode *tape = [SKShapeNode node];
            tape.path = path.CGPath;
            tape.strokeColor = color;
            tape.lineWidth = width;
            tape.zPosition = -11;
            tape.antialiased = NO;
            [self addChild:tape];
        }
    }
}

- (void)drawBevelTopLeft:(CGPoint)topLeft bottomLeft:(CGPoint)bottomLeft
             bottomRight:(CGPoint)bottomRight topRight:(CGPoint)topRight
                  darker:(bool)darker {
    SKColor *color;
    if (darker) {
        color = SKColorWithRGB(204, 187, 143);
    } else {
        color = SKColorWithRGB(229, 219, 184);
    }
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:topLeft];
    [path addLineToPoint:bottomLeft];
    [path addLineToPoint:bottomRight];
    [path addLineToPoint:topRight];
    [path closePath];
    SKShapeNode *bevel = [SKShapeNode node];
    bevel.path = path.CGPath;
    bevel.fillColor = color;
    bevel.lineWidth = 0;
    bevel.zPosition = -14;
    [self addChild:bevel];
}

- (void)drawBorder:(int)bevelDepth bevelWidth:(int)bevelWidth {
    SKColor *color = SKColorWithRGB(85, 85, 85);
    if (!_goal) {
        color = SKColorWithRGB(140, 98, 57);
    }
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(-bevelWidth - 1, self.layerSize.height + 1 - bevelDepth)];
    [path addLineToPoint:CGPointMake(-bevelWidth - 1, -bevelDepth - 1)];
    [path addLineToPoint:CGPointMake(self.layerSize.width + bevelWidth + 1, -bevelDepth - 1)];
    [path addLineToPoint:CGPointMake(self.layerSize.width + bevelWidth + 1,
                                     self.layerSize.height + 1 - bevelDepth)];
    [path addLineToPoint:CGPointMake(self.layerSize.width + 1, self.layerSize.height + 1)];
    [path addLineToPoint:CGPointMake(-1, self.layerSize.height + 1)];
    [path closePath];
    SKShapeNode *border = [SKShapeNode node];
    border.path = path.CGPath;
    border.fillColor = color;
    border.lineWidth = 0;
    border.zPosition = -15;
    [self addChild:border];
}

- (Tile *)getTileForLocation:(CGPoint)location {
    return [[_array objectAtIndex:location.y] objectAtIndex:location.x];
}

- (Tile *)getTileForDirection:(NSInteger)direction activeTile:(Tile*)activeTile {
    Tile *newTile = activeTile;
    CGPoint newLocation = activeTile.location;
    if (direction == 0) newLocation = CGPointMake(newLocation.x + 1, newLocation.y);
    if (direction == 90) newLocation = CGPointMake(newLocation.x, newLocation.y - 1);
    if (direction == 180) newLocation = CGPointMake(newLocation.x - 1, newLocation.y);
    if (direction == 270) newLocation = CGPointMake(newLocation.x, newLocation.y + 1);
    if ([self isOnGrid:newLocation]) {
        newTile = [self getTileForLocation:newLocation];
    }
    return newTile;
}

- (BOOL)isOnGrid:(CGPoint)location {
    if (location.x < 0 || location.x > _gridSize.width - 1) return false;
    if (location.y < 0 || location.y > _gridSize.height - 1) return false;
    return true;
}

- (CGPoint)positionForRow:(NSInteger)row col:(NSInteger)col {
    return CGPointMake(col * self.tileSize.width + self.tileSize.width / 2,
                       self.layerSize.height - (row * self.tileSize.height + self.tileSize.height / 2));
}

- (void)reset {
    for (int row = 0; row < _gridSize.height; row++) {
        for (int col = 0; col < _gridSize.width; col++) {
            [[[_array objectAtIndex:row] objectAtIndex:col] setColor:SKColorWithRGB(251, 247, 224)];
        }
    }
}

@end
