//
//  Color.m
//  Coloroid
//
//  Created by Ayan Yenbekbay on 4/26/14.
//  Copyright (c) 2014 Ayan Yenbekbay. All rights reserved.
//

#import "Color.h"

@implementation Color {
    SKTextureAtlas *_atlas;
    SKSpriteNode *_bg;
}

- (instancetype)initWithColor:(NSString*)hexColor type:(NSString*)type position:(CGPoint)position {
    _hexCode = hexColor;
    _type = type;
    _atlas = [SKTextureAtlas  atlasNamed:@"interface"];
    SKColor *color = [Color colorOfHex:hexColor];
    if (self = [super init]) {
        self.position = position;
        if (![hexColor isEqualToString:@"ffffff"]) {
            _bg = [SKSpriteNode spriteNodeWithTexture: [_atlas textureNamed: @"circle_bg"]];
            _bg.color = color;
            _bg.colorBlendFactor = 1.0;
            SKSpriteNode *light = [SKSpriteNode spriteNodeWithTexture:
                                   [_atlas textureNamed:@"circle_light"]];
            light.zPosition = 2;
            [self addChild:light];
        } else {
            _bg = [SKSpriteNode spriteNodeWithTexture: [_atlas textureNamed:@"circle_white"]];
            _bg.color = color;
            _bg.colorBlendFactor = 0;
        }
        _bg.zPosition = 1;
        [self addChild:_bg];
        self.name = [NSString stringWithFormat:@"%@_color_%@", type, hexColor];
        if ([type isEqualToString:@"instance"]) self.zPosition = 100;
    }
    return self;
}

+ (SKColor*)colorOfHex:(NSString*)string {
    NSScanner *scanner = [NSScanner scannerWithString:string];
    unsigned hex;
    if (![scanner scanHexInt:&hex]) return nil;
    
    int r = (hex >> 16) & 0xFF;
    int g = (hex >> 8) & 0xFF;
    int b = (hex) & 0xFF;
    
    return SKColorWithRGB(r, g, b);
}

+ (NSString*)hexOfColor:(SKColor*)color {
    const CGFloat *components = CGColorGetComponents(color.CGColor);
    CGFloat r = components[0];
    CGFloat g = components[1];
    CGFloat b = components[2];
    NSString *hex = [NSString stringWithFormat:@"%02X%02X%02X",
                         (int)(r * 255), (int)(g * 255), (int)(b * 255)];
    return hex;
}

- (void)setColor:(SKColor*)color {
    _bg.color = color;
}

- (SKColor*)getColor {
    return _bg.color;
}

+ (SKColor*)blend:(SKColor*)c1 :(SKColor*)c2 {
    CGFloat r1, g1, b1, a1, r2, g2, b2, a2;
    [c1 getRed:&r1 green:&g1 blue:&b1 alpha:&a1];
    [c2 getRed:&r2 green:&g2 blue:&b2 alpha:&a2];
    CGFloat r = (r1 * a1 + r2 * a2) * 255 / 2;
    CGFloat g = (g1 * a1 + g2 * a2) * 255 / 2;
    CGFloat b = (b1 * a1 + b2 * a2) * 255 / 2;
    return SKColorWithRGB(r, g, b);
}

@end
