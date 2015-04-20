//
//  Function.m
//  Coloroid
//
//  Created by Ayan Yenbekbay on 4/24/14.
//  Copyright (c) 2014 Ayan Yenbekbay. All rights reserved.
//

#import "Function.h"
#import "Command.h"

@implementation Function {
    int _capacity;
    int _index;
    SKTextureAtlas *_atlas;
}

- (instancetype)initWithIndex:(int)index {
    _index = index;
    _atlas = [SKTextureAtlas atlasNamed:@"interface"];
    NSString *bgTextureName;
    if (_index == 0) {
        bgTextureName = @"big_function_bg";
        _capacity = 10;
    } else {
        self.name = [NSString stringWithFormat:@"function%ld", (long)_index];
        bgTextureName = @"small_function_bg";
        _capacity = 5;
    }
    _commands = [NSMutableArray arrayWithCapacity:_capacity];
    if (self = [super init]) {
        SKSpriteNode *bg = [SKSpriteNode spriteNodeWithTexture: [_atlas textureNamed: bgTextureName]];
        bg.position = CGPointMake(126 + bg.size.width / 2,
                                  107.5 + bg.size.height / 2 - _index * 10.5 - _index * bg.size.height);
        [self addChild:bg];
        _layerSize = bg.size;
        
        SKSpriteNode *label = [SKSpriteNode spriteNodeWithTexture:
                               [_atlas textureNamed:[NSString stringWithFormat:@"function%ld_label", (long)_index]]];
        label.position = CGPointMake(100 + label.size.width / 2,
                                     bg.position.y + bg.size.height / 2 - label.size.height / 2);
        [self addChild:label];
    }
    [self addBlankCommands:_capacity];
    return self;
}

- (void)addBlankCommands:(int)count {
    for (int i = 0; i < count; i++) {
        Command *command = [[Command alloc] initBlankAtPosition:[self getSpot:i]];
        command.alpha = 0;
        [self addChild:command];
        [_commands addObject:command];
    }
}

- (void)addCommand:(Command*)command {
    Command *newCommand = _commands[_numOfCommands];
    NSString *action = command.action;
    [newCommand setAction:action];
    if ([action hasPrefix:@"fill"]) {
        NSString *hexColor = [action stringByReplacingOccurrencesOfString:@"fill_" withString:@""];
        [newCommand createColorLayerWithColor:hexColor];
        action = @"fill";
    }
    newCommand.type = @"instance";
    newCommand.name = [NSString stringWithFormat:@"instance_command_%@", action];
    [[newCommand bg] setTexture:[_atlas textureNamed:[NSString stringWithFormat:@"command_%@", action]]];
    [[newCommand bg] setColorBlendFactor:0];
    [newCommand setAlpha:1.0];
    _numOfCommands++;
}

- (void)replaceCommand:(Command*)replaceable with:(Command*)new {
    NSString *action = new.action;
    [replaceable setAction:action];
    if ([action hasPrefix:@"fill"]) {
        NSString *hexColor = [action stringByReplacingOccurrencesOfString:@"fill_" withString:@""];
        [replaceable createColorLayerWithColor:hexColor];
        action = @"fill";
    }
    if (![_commands containsObject:new] && [replaceable.type isEqualToString:@"placeholder"]) _numOfCommands++;
    if ([replaceable.type isEqualToString:@"placeholder"]) replaceable.type = @"instance";
    [replaceable setName:[NSString stringWithFormat:@"instance_command_%@", action]];
    [[replaceable bg] setTexture:[_atlas textureNamed:[NSString stringWithFormat:@"command_%@", action]]];
    [[replaceable bg] setColorBlendFactor:0];
    [replaceable setAlpha:1.0];
}

- (CGPoint)getSpot:(int)i {
    int rowIndex = i;
    int verticalOffset;
    if (_index == 0) {
        verticalOffset = 182;
    } else if (_index == 1) {
        verticalOffset = 97;
    } else {
        verticalOffset = 48.5;
    }
    if (i >= 5) {
        rowIndex -= 5;
    }
    return CGPointMake(126 + rowIndex * 36.5 + 19,
                       verticalOffset - i / 5 * 36.5 - 19);
}

- (void)update {
    int num = (int)(_capacity - _commands.count);
    [self addBlankCommands:num];
    for (int i = 0; i < _commands.count; i++) {
        [_commands[i] runAction:[SKAction moveTo:[self getSpot:i] duration:0.2]];
    }
}

- (void)moveTo:(NSString*)dir from:(int)index {
    Command *firstCommand;
    if ([dir isEqualToString:@"right"]) {
        firstCommand = _commands[index];
        for (int i = _numOfCommands-1; i >= index; i--) {
            [self replaceCommand:_commands[i+1] with:_commands[i]];
        }
    } else if ([dir isEqualToString:@"left"]) {
        firstCommand = _commands[_numOfCommands];
        for (int i = index; i < _numOfCommands+1; i++) {
            [self replaceCommand:_commands[i-1] with:_commands[i]];
        }
        firstCommand.alpha = 0;
    }
    firstCommand.type = @"placeholder";
    firstCommand.name = @"placeholder_command_blank";
    [[firstCommand bg] setTexture:[_atlas textureNamed:@"command_blank"]];
}

- (void)clean {
    for (int i = 0; i < _numOfCommands; i++) {
        Command *command = _commands[i];
        if ([command.type isEqualToString:@"placeholder"])
            [self moveTo:@"left" from:i+1];
    }
}

- (void)reset {
    for (Command *command in _commands) {
        [command runAction:[SKAction sequence:@[
                                    [SKAction scaleTo:0.0 duration:0.2],
                                    [SKAction removeFromParent]]]];
    }
    [_commands removeAllObjects];
    _numOfCommands = 0;
    _runningCommand = 0;
    [self addBlankCommands:_capacity];
}


@end