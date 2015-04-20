//
//  Command.m
//  Coloroid
//
//  Created by Ayan Yenbekbay on 4/25/14.
//  Copyright (c) 2014 Ayan Yenbekbay. All rights reserved.
//

#import "Command.h"
#import "Color.h"

@implementation Command {
    SKTextureAtlas *_atlas;
}

- (instancetype)initWithAction:(NSString*)action type:(NSString*)type position:(CGPoint)position {
    NSString *bgName = action;
    _atlas = [SKTextureAtlas atlasNamed:@"interface"];
    if (self = [super init]) {
        self.position = position;
        NSString *hexColor;
        if ([action hasPrefix:@"fill"]) {
            hexColor = [action stringByReplacingOccurrencesOfString:@"fill_" withString:@""];
            bgName = @"fill";
        }
        _bg = [SKSpriteNode spriteNodeWithTexture: [_atlas textureNamed: [NSString stringWithFormat:@"command_%@", bgName]]];
        _bg.color = SKColorWithRGB(182, 220, 122);
        [self addChild:_bg];
        _action = action;
        _type = type;
        if ([action hasPrefix:@"fill"]) {
            [self createColorLayerWithColor:hexColor];
        }
        if ([type isEqualToString:@"instance"]) self.zPosition = 100;
        if ([action isEqualToString:@"palette"]) {
            self.name = action;
        } else {
            self.name = [NSString stringWithFormat:@"%@_command_%@", type, action];
        }
    }
    return self;
}

- (instancetype)initBlankAtPosition:(CGPoint)position {
    Command *blank = [self initWithAction:@"blank" type:@"placeholder" position:position];
    return blank;
}

- (void)createColorLayerWithColor:(NSString*)hexColor {
    SKColor *color = [Color colorOfHex:hexColor];
    _bg.zPosition = 1;
    _fillColor = [SKSpriteNode spriteNodeWithTexture:
                               [_atlas textureNamed:@"command_blank"]];
    _fillColor.color = color;
    _fillColor.colorBlendFactor = 1.0;
    _fillColor.position = _bg.position;
    [self addChild:_fillColor];
}

- (void)resetFill {
    _fillColor.color = SKColorWithRGB(125, 125, 125);
    self.name = @"toolbox_command_fill_7d7d7d";
}

- (void)setAction:(NSString*)action {
    _action = action;
}

@end
