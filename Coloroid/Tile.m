//
//  Tile.m
//  Coloroid
//
//  Created by Ayan Yenbekbay on 4/19/14.
//  Copyright (c) 2014 Ayan Yenbekbay. All rights reserved.
//

#import "Tile.h"

@implementation Tile

- (instancetype)initWithCoordinates:(CGPoint)tileCoordinates
                               code:(unichar)tileCode
                               size:(CGSize)tileSize {
    _location = tileCoordinates;
    self = [super initWithColor:[self colorForCode:tileCode] size:tileSize];
    return self;
}

- (SKColor*)colorForCode:(unichar)tileCode {
    SKColor *color;
    switch ((tileCode)) {
        case 'w':
            color = SKColorWithRGB(251, 247, 224);
            break;
        case 'r':
            color = SKColorWithRGB(238, 35, 63);
            break;
        case 'y':
            color = SKColorWithRGB(255, 227, 25);
            break;
        case 'g':
            color = SKColorWithRGB(91, 185, 65);
            break;
        case 'b':
            color = SKColorWithRGB(38, 115, 192);
            break;
        default:
            color = [SKColor whiteColor];
            break;
    }
    return color;
}

@end
