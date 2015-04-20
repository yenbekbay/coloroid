//
//  Tile.h
//  Coloroid
//
//  Created by Ayan Yenbekbay on 4/19/14.
//  Copyright (c) 2014 Ayan Yenbekbay. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface Tile : SKSpriteNode

@property (nonatomic, readonly) CGPoint location;

- (instancetype)initWithCoordinates:(CGPoint)tileCoordinates
                               code:(unichar)tileCode
                               size:(CGSize)tileSize;

@end
