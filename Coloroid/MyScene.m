//
//  MyScene.m
//  Coloroid
//
//  Created by Ayan Yenbekbay on 4/18/14.
//  Copyright (c) 2014 Ayan Yenbekbay. All rights reserved.
//

#import "MyScene.h"
#import "TileMapLayer.h"
#import "TileMapLayerLoader.h"
#import "Bot.h"
#import "Tile.h"
#import "Function.h"
#import "Command.h"
#import "Color.h"

@implementation MyScene {
    SKTextureAtlas *_interface;
    SKNode *_canvas;
    SKNode *_topBar;
    SKSpriteNode *_menuButton;
    SKSpriteNode *_resetButton;
    SKSpriteNode *_playButton;
    SKNode *_toolbox;
    SKNode *_colorChooser;
    SKNode *_mixArea;
    SKSpriteNode *_mixAreaBg;
    NSMutableArray *_colorsToMix;
    Color *_mixedColor;
    Command *_fillCommand;
    Function *_mainFunction;
    Function *_function1;
    Function *_function2;
    TileMapLayer *_goal;
    TileMapLayer *_tiles;
    Bot *_bot;
    NSInteger _direction;
    SKNode *_selectedNode;
    Command *_selectedCommand;
    Command *_replaceableCommand;
    BOOL _functionMoved;
    Color *_selectedColor;
    NSInteger _commandSideLength;
    NSTimer *_functionTimer;
    Function *_activeFunction;
    BOOL _commandAnimated;
}

- (id)initWithSize:(CGSize)size {
    if(self = [super initWithSize:size]) {
        [self createInterface];
        [self createToolbox];
        [self createColorchooser];
        [self createCanvas];
        [self createBot];
    }
    return self;
}

- (void)createInterface {
    // Add background
    self.backgroundColor = [SKColor whiteColor];
    SKSpriteNode *bg = [SKSpriteNode spriteNodeWithImageNamed:@"blueprint"];
    bg.position = CGPointMake(self.size.width / 2, self.size.height / 2);
    bg.zPosition = -100;
    [self addChild:bg];
    
    _interface = [SKTextureAtlas atlasNamed:@"interface"];
    
    // Add top bar
    _topBar = [SKNode node];
    SKSpriteNode *barBg = [SKSpriteNode spriteNodeWithTexture:[_interface textureNamed:@"topbar"]];
    barBg.anchorPoint = CGPointMake(0, 1);
    barBg.position = CGPointMake(0, self.size.height);
    barBg.zPosition = -100;
    [_topBar addChild:barBg];
    
    // Add goal
    _goal = [TileMapLayerLoader tileMapLayerFromFileNamed:@"level-1.txt" isGoal:YES];
    _goal.position = CGPointMake(self.size.width / 2 - _goal.layerSize.width / 2,
                                 self.size.height - _goal.layerSize.height - 20);
    [_topBar addChild:_goal];
    
    SKCropNode *cropTexure = [SKCropNode node];
    SKSpriteNode *pencilTexture = [SKSpriteNode spriteNodeWithTexture:
                                [_interface textureNamed:@"pencil_mask"]];
    pencilTexture.position = CGPointMake(_goal.position.x + _goal.layerSize.width / 2,
                                         _goal.position.y + _goal.layerSize.height / 2);
    pencilTexture.alpha = 0.3;
    pencilTexture.size = _goal.layerSize;
    [cropTexure addChild:pencilTexture];
    
    // Add pin
    SKSpriteNode *pin = [SKSpriteNode spriteNodeWithTexture:[_interface textureNamed:@"pin"]];
    pin.position = CGPointMake(self.size.width / 2, self.size.height - pin.size.height / 2 - 2.5);
    pin.zPosition = 2;
    [_topBar addChild:pin];
    
    SKSpriteNode *goalShadow = [SKSpriteNode spriteNodeWithTexture:
                                [_interface textureNamed:@"goal_shadow"]];
    goalShadow.size = CGSizeMake(_goal.layerSize.width + 15, goalShadow.size.height);
    goalShadow.position = CGPointMake(self.size.width / 2, _goal.position.y + 2.5);
    goalShadow.zPosition = -20;
    [_topBar addChild:goalShadow];
    
    // Add buttons
    SKNode *menuButtonNode = [SKNode node];
    menuButtonNode.name = @"button_menu";
    _menuButton = [SKSpriteNode spriteNodeWithTexture:
                                  [_interface textureNamed:@"button_menu"]];
    _menuButton.position = CGPointMake(10 + _menuButton.size.width / 2,
                                       self.size.height - 8.5 - _menuButton.size.height / 2);
    _menuButton.name = @"bg";
    [menuButtonNode addChild:_menuButton];
    [_topBar addChild:menuButtonNode];
    
    SKNode *resetButtonNode = [SKNode node];
    resetButtonNode.name = @"button_reset";
    _resetButton = [SKSpriteNode spriteNodeWithTexture:
                   [_interface textureNamed:@"button_reset"]];
    _resetButton.position = CGPointMake(15 + 1.5 * _menuButton.size.width,
                                       self.size.height - 8.5 - _menuButton.size.height / 2);
    _resetButton.name = @"bg";
    [resetButtonNode addChild:_resetButton];
    [_topBar addChild:resetButtonNode];
    
    SKNode *playButtonNode = [SKNode node];
    playButtonNode.name = @"button_play";
    _playButton = [SKSpriteNode spriteNodeWithTexture:
                                  [_interface textureNamed:@"button_play"]];
    _playButton.position = CGPointMake(self.size.width - 10 - _playButton.size.width / 2,
                                       self.size.height - 8.5 - _playButton.size.height / 2);
    _playButton.name = @"bg";
    _playButton.alpha = 0.5;
    [playButtonNode addChild:_playButton];
    [_topBar addChild:playButtonNode];
    
    [self addChild:_topBar];
}

- (void)createToolbox {
    // Add toolbox
    _toolbox = [SKNode node];
    SKSpriteNode *toolboxBg = [SKSpriteNode spriteNodeWithTexture:[_interface textureNamed:@"toolbox"]];
    toolboxBg.anchorPoint = CGPointZero;
    toolboxBg.position = CGPointZero;
    [_toolbox addChild:toolboxBg];
    
    // Add commands
    _commandSideLength = 35;
    Command *forwardCommand = [[Command alloc] initWithAction:@"forward" type:@"toolbox"
                                                   position:CGPointMake(10 + _commandSideLength / 2,
                                                                        toolboxBg.size.height - 27.5 - _commandSideLength / 2)];
    [_toolbox addChild:forwardCommand];
    _fillCommand = [[Command alloc] initWithAction:@"fill_7d7d7d" type:@"toolbox"
                                        position:CGPointMake(15 + 1.5 * _commandSideLength,
                                                             toolboxBg.size.height - 27.5 - _commandSideLength / 2)];
    [_toolbox addChild:_fillCommand];
    Command *turnRightCommand = [[Command alloc] initWithAction:@"turn_right" type:@"toolbox"
                                                     position:CGPointMake(10 + _commandSideLength / 2,
                                                                          toolboxBg.size.height - 32.5 - 1.5 * _commandSideLength)];
    [_toolbox addChild:turnRightCommand];
    Command *turnLeftCommand = [[Command alloc] initWithAction:@"turn_left" type:@"toolbox"
                                                    position:CGPointMake(15 + 1.5 * _commandSideLength,
                                                                         toolboxBg.size.height - 32.5 - 1.5 * _commandSideLength)];
    [_toolbox addChild:turnLeftCommand];
    Command *function1Command = [[Command alloc] initWithAction:@"function1" type:@"toolbox"
                                                     position:CGPointMake(10 + _commandSideLength / 2,
                                                                          toolboxBg.size.height - 37.5 - 2.5 * _commandSideLength)];
    [_toolbox addChild:function1Command];
    Command *function2Command = [[Command alloc] initWithAction:@"function2" type:@"toolbox"
                                                     position:CGPointMake(15 + 1.5 * _commandSideLength,
                                                                          toolboxBg.size.height - 37.5 - 2.5 * _commandSideLength)];
    [_toolbox addChild:function2Command];
    Command *paletteButton = [[Command alloc] initWithAction:@"palette" type:@"toolbox"
                                                  position:CGPointMake(10 + 34.5,
                                                                       toolboxBg.size.height - 46.5 - 3 * _commandSideLength - 47.5 / 2)];
    [_toolbox addChild:paletteButton];
    
    [self addChild:_toolbox];
    
    // Add functions
    _mainFunction = [[Function alloc] initWithIndex: 0];
    [self addChild:_mainFunction];
    _function1 = [[Function alloc] initWithIndex: 1];
    [self addChild:_function1];
    _function2 = [[Function alloc] initWithIndex: 2];
    [self addChild:_function2];
}

- (void)createColorchooser {
    // Add colorchooser
    _colorChooser = [SKNode node];
    _colorChooser.name = @"inactive";
    _colorChooser.alpha = 0;
    _colorChooser.zPosition = 100;
    SKSpriteNode *colorChooserBg = [SKSpriteNode spriteNodeWithTexture:[_interface textureNamed:@"color_chooser_bg"]];
    colorChooserBg.position = CGPointMake(88 + colorChooserBg.size.width / 2,
                                          97 - colorChooserBg.size.height / 2);
    [_colorChooser addChild:colorChooserBg];
    
    // Add colors
    Color *redColor = [[Color alloc] initWithColor:@"ee233f" type:@"chooser"
                                          position:CGPointMake(colorChooserBg.position.x - (colorChooserBg.size.width) / 2 + 35, colorChooserBg.position.y + colorChooserBg.size.height / 2 - 23.5)];
    [_colorChooser addChild:redColor];
    Color *yellowColor = [[Color alloc] initWithColor:@"ffe319" type:@"chooser"
                                             position:CGPointMake(colorChooserBg.position.x - (colorChooserBg.size.width) / 2 + 74.5, colorChooserBg.position.y + colorChooserBg.size.height / 2 - 23.5)];
    [_colorChooser addChild:yellowColor];
    Color *greenColor = [[Color alloc] initWithColor:@"5bb941" type:@"chooser"
                                            position:CGPointMake(colorChooserBg.position.x - (colorChooserBg.size.width) / 2 + 35, colorChooserBg.position.y - colorChooserBg.size.height / 2 + 23.5)];
    [_colorChooser addChild:greenColor];
    Color *blueColor = [[Color alloc] initWithColor:@"2673c0" type:@"chooser"
                                           position:CGPointMake(colorChooserBg.position.x - (colorChooserBg.size.width) / 2 + 74.5, colorChooserBg.position.y - colorChooserBg.size.height / 2 + 23.5)];
    [_colorChooser addChild:blueColor];
    Color *whiteColor = [[Color alloc] initWithColor:@"ffffff" type:@"chooser"
                                            position:CGPointMake(colorChooserBg.position.x - (colorChooserBg.size.width) / 2 + 114, colorChooserBg.position.y)];
    [_colorChooser addChild:whiteColor];
    
    // Add mix area
    _mixArea = [SKNode node];
    
    _mixAreaBg = [SKSpriteNode spriteNodeWithTexture:[_interface textureNamed:@"mix_area_bg"]];
    _mixAreaBg.position = CGPointMake(colorChooserBg.position.x + (colorChooserBg.size.width) / 2 - 6 - _mixAreaBg.size.width / 2, colorChooserBg.position.y);
    [_mixArea addChild:_mixAreaBg];
    
    SKSpriteNode *mixAreaBorder = [SKSpriteNode spriteNodeWithTexture:[_interface textureNamed:@"mix_area_border"]];
    mixAreaBorder.position = _mixAreaBg.position;
    [_mixArea addChild:mixAreaBorder];
    
    [_colorChooser addChild:_mixArea];
    
    _colorChooser.position = CGPointMake(_colorChooser.position.x - 10, _colorChooser.position.y);
    _colorsToMix = [NSMutableArray arrayWithCapacity:3];
}

- (void)createCanvas {
    _canvas = [SKNode node];
    _tiles = [TileMapLayerLoader tileMapLayerFromFileNamed:@"level-1.txt" isGoal:NO]; // Load grid setup from the level file
    [_canvas addChild:_tiles];
    _canvas.position = CGPointMake(self.size.width / 2 - _tiles.layerSize.width / 2,
                                 self.size.height - 120 - _tiles.layerSize.height);
    [self addChild:_canvas];
}

- (void)createBot {
    _bot = [Bot node];
    _activeTile = [_tiles getTileForLocation:CGPointZero]; // Put the bot in the zero location
    _bot.position = CGPointMake(_activeTile.position.x, _activeTile.position.y + 35);
    _direction = 270; // Reset direction
    [_canvas addChild:_bot];
}

- (void)resetBot {
    _activeTile = [_tiles getTileForLocation:CGPointZero];
    [_bot runAction:[SKAction moveTo:CGPointMake(_activeTile.position.x, _activeTile.position.y + 35) duration:0.3] completion:^{
        if (_direction == 0) {
           [_bot turnRight];
        } else if (_direction == 90) {
            [_bot turnRight];
            [_bot turnRight];
        } else if (_direction == 180) {
            [_bot turnLeft];
        }
        if (_bot.active) [_bot activate:YES];
        _bot.bucketColor.color = SKColorWithRGB(125, 125, 125);
        _direction = 270;
    }];
}

- (void)resetFunctions {
    [_mainFunction reset];
    [_function1 reset];
    [_function2 reset];
}

- (void)runFunction:(Function*)function {
    _activeFunction = function;
    if (!_bot.active) {
        [_bot activate:NO];
        double delayInSeconds = 1.5;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [self runTimer];
        });
    } else {
        [self runTimer];
    }
}

- (void)runTimer {
    if (_activeFunction == _function1 || _activeFunction == _function2) {
        _activeFunction.runningCommand = 0;
    }
    _functionTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                      target:self
                                                    selector:@selector(animateCommands:)
                                                    userInfo:nil
                                                     repeats:YES];}

- (void)animateCommands:(NSTimer*)timer {
    NSInteger index = _activeFunction.runningCommand;
    NSString *action = [_activeFunction.commands[index] action];
    SKNode *icon = [_activeFunction.commands[index] bg];
    SKAction *colorize = [SKAction colorizeWithColor:SKColorWithRGB(182, 220, 122)
                                    colorBlendFactor:0.5 duration:0];
    SKAction *uncolorize = [SKAction colorizeWithColorBlendFactor:0 duration:0];
    [icon runAction:[SKAction sequence:@[colorize, [SKAction waitForDuration:0.3], uncolorize]]];
    if ([action isEqualToString:@"forward"]) {
        [self botMoveForward];
    } else if ([action hasPrefix:@"fill"]) {
        NSString *hexColor = [action stringByReplacingOccurrencesOfString:@"fill_" withString:@""];
        [self fillActiveTileWithColor:hexColor];
    } else if ([action isEqualToString:@"turn_right"]) {
        [_bot turnRight];
        _direction = [_bot direction];
    } else if ([action isEqualToString:@"turn_left"]) {
        [_bot turnLeft];
        _direction = [_bot direction];
    } else if ([action isEqualToString:@"function1"]) {
        _activeFunction.runningCommand++;
        [_functionTimer invalidate];
        [self runFunction:_function1];
        return;
    } else if ([action isEqualToString:@"function2"]) {
        _activeFunction.runningCommand++;
        [_functionTimer invalidate];
        [self runFunction:_function2];
        return;
    }
    if (index == _activeFunction.numOfCommands - 1) {
       [_functionTimer invalidate];
        if ((_activeFunction == _function1 || _activeFunction == _function2) &&
            _mainFunction.runningCommand != _mainFunction.numOfCommands) {
            [self runFunction:_mainFunction];
        } else {
            [self checkGame];
            [_selectedNode setName:@"button_play"];
            [_playButton setTexture:[_interface textureNamed:@"button_play"]];
        }
    } else {
        _activeFunction.runningCommand++;
    }
}

- (void)checkGame {
    double delayInSeconds = 1.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        BOOL win = YES;
        for (int row = 0; row < _tiles.gridSize.height; row++) {
            for (int col = 0; col < _tiles.gridSize.width; col++) {
                SKColor *canvasColor = [[[_tiles.array objectAtIndex:row] objectAtIndex:col] color];
                SKColor *goalColor = [[[_goal.array objectAtIndex:row] objectAtIndex:col] color];
                if(![canvasColor isEqual:goalColor]) {
                    win = NO;
                }
            }
        }
        NSString *title;
        NSString *message;
        if (win) {
            title = @"Congratulations!";
            message = @"You are awesome!";
        } else {
            title = @"You lost :(";
            message = @"Try again, you will get it!";
        }
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:title
                              message:message
                              delegate:nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil];
        [alert show];
        [_tiles reset];
        [self resetBot];
        [_fillCommand resetFill];
    });
}

- (void)botMoveForward {
    Tile *newTile = [_tiles getTileForDirection:_direction activeTile:_activeTile];
    if (newTile == _activeTile) {
        // Wiggle the bot if he can't move
        SKAction *moveBack = [SKAction moveTo:_bot.position duration:0.05];
        SKAction *rightWiggle = [SKAction moveByX:2 y:0 duration:0.05];
        SKAction *leftWiggle = [rightWiggle reversedAction];
        SKAction *upWiggle = [SKAction moveByX:0 y:2 duration:0.05];
        SKAction *downWiggle = [upWiggle reversedAction];
        SKAction *sequence;
        if (_direction == 0 || _direction == 180) {
            _bot.position = CGPointMake(_bot.position.x - 5, _bot.position.y);
            sequence = [SKAction sequence:@[rightWiggle, moveBack, leftWiggle, moveBack]];
        } else {
            _bot.position = CGPointMake(_bot.position.x, _bot.position.y - 5);
            sequence = [SKAction sequence:@[upWiggle, moveBack, downWiggle, moveBack]];
        }
        [_bot runAction:[SKAction repeatAction:sequence count:3]];
    } else {
        _activeTile = newTile;
        [_bot runAction:[SKAction moveTo:CGPointMake(_activeTile.position.x, _activeTile.position.y + 35) duration:0.3]];
    }
}

- (void)fillActiveTileWithColor:(NSString*)hexColor {
    SKColor *color = [Color colorOfHex:hexColor];
    SKTextureAtlas *atlas = [SKTextureAtlas atlasNamed:@"splatter"];
    SKSpriteNode *splatter = [SKSpriteNode spriteNodeWithTexture:[atlas textureNamed:@"splatter1"]
                                                            size:[_tiles tileSize]];
    NSMutableArray *textures = [NSMutableArray arrayWithCapacity:10];
    for (int i = 2; i <= 10; i++) {
        SKTexture *texture = [atlas textureNamed: [NSString stringWithFormat:@"splatter%d", i]];
        [textures addObject:texture];
    }
    _bot.bucketColor.color = color;
    splatter.color = color;
    splatter.colorBlendFactor = 1.0;
    SKAction *action = [SKAction animateWithTextures:textures timePerFrame:0.03];
    [_activeTile addChild:splatter];
    [splatter runAction:action completion:^{
        [splatter removeFromParent];
        _activeTile.color = color;
    }];
}

-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint touchLocation = [touch locationInNode:self];
    _selectedNode = [[self nodeAtPoint:touchLocation] parent];
    NSString *name = _selectedNode.name;
    if ([name hasPrefix:@"toolbox_command_"] && !_commandAnimated) { // If command from toolbox is touched
        [self createCopyOfCommand:NO]; // create an instance
    } else if ([name hasPrefix:@"instance_command_"] && !_commandAnimated) { // If command from function is touched
        [self createCopyOfCommand:YES]; //  create a new copy
        Function *parentFunction = [self getFunctionForNode:_selectedNode];
        Command *commandToRemove = [self getCommandForNode:_selectedNode function:parentFunction];
        [parentFunction.commands removeObject:commandToRemove];
        [_selectedNode removeFromParent];
        parentFunction.numOfCommands--;
    } else if ([name hasPrefix:@"chooser_color"]) {
        [self createCopyOfColor];
    } else if ([name hasPrefix:@"button"]) {
        NSString *textureName = [NSString stringWithFormat:@"%@_hover", name];
        if ([[_selectedNode name] isEqualToString:@"button_play"] && _mainFunction.numOfCommands != 0) {
            [_playButton setTexture:[_interface textureNamed:textureName]];
        } else if ([[_selectedNode name] isEqualToString:@"button_menu"]) {
            [_menuButton setTexture:[_interface textureNamed:textureName]];
        } else if ([[_selectedNode name] isEqualToString:@"button_reset"]) {

            [_resetButton setTexture:[_interface textureNamed:textureName]];
        }
    } else if ([name isEqualToString:@"palette"] && ![_colorChooser.name isEqualToString:@"animated"]) {
        [self animateColorChooser];
    }
}
    
- (void)animateColorChooser {
    if ([_colorChooser.name isEqualToString:@"inactive"]) {
        if (_mixAreaBg.alpha < 1.0) _mixAreaBg.alpha = 1.0;
        [self addChild:_colorChooser];
        _colorChooser.name = @"animated";
        [_colorChooser runAction:[SKAction group:@[[SKAction fadeInWithDuration:0.3],
                                                   [SKAction moveByX:10 y:0 duration:0.3]]]
                      completion:^{
                          [_colorChooser setName:@"active"];
                      }];
    } else {
        _colorChooser.name = @"animated";
        [_colorChooser runAction:[SKAction sequence:@[
                                        [SKAction group:@[[SKAction fadeOutWithDuration:0.3],
                                        [SKAction moveByX:-10 y:0 duration:0.3]]],
                                 [SKAction removeFromParent]]]
                      completion:^{
                          [_colorChooser setName:@"inactive"];
                      }];
        if (_colorsToMix.count != 0) {
            [_colorsToMix removeAllObjects];
            [_mixedColor removeFromParent];
        }
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    if ((_selectedCommand && !_commandAnimated) || _selectedColor) {
        UITouch *touch = [touches anyObject];
        CGPoint positionInScene = [touch locationInNode:self];
        CGPoint currentPosition = [touch previousLocationInNode:self];
        CGPoint translation = CGPointMake(positionInScene.x - currentPosition.x, positionInScene.y - currentPosition.y);
        
        [self panForTranslation:translation];
        
        if (_selectedColor && [_mixArea containsPoint:positionInScene] && _mixAreaBg.alpha == 1.0) {
            [_mixAreaBg runAction:[SKAction fadeOutWithDuration:0.1]];
        }
        
        if (_selectedCommand) {
            [self checkForReplacement:positionInScene];
        }
    }
}

- (void)checkForReplacement:(CGPoint)position {
    Function *selectedFunction = [self getFunctionForNode:_selectedCommand];
    Function *function = selectedFunction;
    if (function) {
        if (function.numOfCommands < function.commands.count) {
            for (int i = 0; i < function.numOfCommands; i++) {
                Command *thisCommand = function.commands[i];
                NSInteger commandWidth = thisCommand.bg.size.width;
                if (![_selectedNode containsPoint:position]) {
                    [function update];
                }
                if ([thisCommand containsPoint:position]) {
                    if ([thisCommand.type isEqualToString:@"instance"]) {
                        if ((position.x <= thisCommand.position.x - commandWidth / 6 &&
                            position.x >= thisCommand.position.x - commandWidth / 2) ||
                            (position.x >= thisCommand.position.x + commandWidth / 6 &&
                             position.x <= thisCommand.position.x + commandWidth / 2)) {
                                if (!_functionMoved) {
                                    if (_replaceableCommand) _replaceableCommand.bg.colorBlendFactor = 0;
                                    int index = (int)[function.commands indexOfObject:thisCommand];
                                    if (position.x > thisCommand.position.x) index++;
                                    [function moveTo: @"right" from:index];
                                    _replaceableCommand = function.commands[index];
                                    _replaceableCommand.bg.colorBlendFactor = 1.0;
                                    _functionMoved = YES;
                                }
                        } else {
                            _replaceableCommand = thisCommand;
                            _replaceableCommand.bg.colorBlendFactor = 0.5;
                            if (_functionMoved) {
                                [function clean];
                                [function update];
                                _functionMoved = NO;
                            }
                        }
                        _selectedCommand.replacing = _replaceableCommand;
                    }
                } else if (_replaceableCommand == thisCommand) {
                    _replaceableCommand.bg.colorBlendFactor = 0;
                    _selectedCommand.replacing = nil;
                    _replaceableCommand = nil;
                    if (_functionMoved) {
                        [function clean];
                        [function update];
                        _functionMoved = NO;
                    }
                }
            }
        }
    } else {
        if (_replaceableCommand) {
            _replaceableCommand.bg.colorBlendFactor = 0;
            _selectedCommand.replacing = nil;
            _replaceableCommand = nil;
            if (_functionMoved) {
                [function clean];
                [function update];
                _functionMoved = NO;
            }
        }
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    if (_selectedCommand && !_commandAnimated) {
        [self touchesEndedForCommand];
    } else if(_selectedColor) {
        [self touchesEndedForColor];
    } else if ([[_selectedNode name] hasPrefix:@"button"]) {
        [self touchesEndedForButton];
    }
}

- (void)touchesEndedForCommand {
    _functionMoved = NO;
    _replaceableCommand = nil;
    
    Command *command = _selectedCommand;
    CGPoint currentPosition = command.position;
    CGPoint initialPosition = _selectedNode.position;
    CGPoint destination = initialPosition;
    Function *initialFunction = [self getFunctionForNode:_selectedNode];
    Function *selectedFunction = [self getFunctionForNode:command];
    if (CGPointEqualToPoint(currentPosition, initialPosition) && !initialFunction) { // If clicked on a command in toolbox
        selectedFunction = _mainFunction;
        destination = [selectedFunction getSpot:selectedFunction.numOfCommands]; // move to main function
    } else { // If moved to somewhere
        if (selectedFunction) { // to function
            if (command.replacing) { // If command is replacing another command
                if (!initialFunction) initialFunction.numOfCommands--;
                destination = command.replacing.position; // move to the replaced command
            } else { // If command is appended to function
                [selectedFunction update];
                destination = [selectedFunction getSpot:selectedFunction.numOfCommands]; // move to the end
            }
        } else { // outside function
            destination = initialPosition; // return to toolbox
        }
    }
    
    SKAction *move = [SKAction moveTo:destination duration:0.2];
    SKAction *remove = [SKAction sequence:@[
                                            [SKAction scaleTo:0.0 duration:0.1],
                                            [SKAction removeFromParent]]];
    move.timingMode = SKActionTimingEaseOut;
    //NSLog(@"%d vs %lu", selectedFunction.numOfCommands, (unsigned long)selectedFunction.commands.count);
    if (selectedFunction) { // If command is over a function
        if ((selectedFunction.numOfCommands >= selectedFunction.commands.count) && !initialFunction && !command.replacing) {
            // If command is from toolbox and function is full
            [command removeFromParent];
            SKAction *moveBack = [SKAction moveTo:_selectedNode.position duration:0.0025];
            SKAction *rightWiggle = [SKAction moveByX:2 y:0 duration:0.0025];
            SKAction *leftWiggle = [rightWiggle reversedAction];
            SKAction *sequence = [SKAction sequence:@[rightWiggle, moveBack, leftWiggle, moveBack]];
            _commandAnimated = YES;
            [_selectedNode runAction:[SKAction repeatAction:sequence count:2] completion:^{
                _commandAnimated = NO;
            }];
        } else { // If function is not full
            if(selectedFunction == initialFunction && CGPointEqualToPoint(initialPosition, currentPosition)) {
                // If clicked on a command inside a function
                [initialFunction update];
                _commandAnimated = YES;
                [command runAction:remove completion:^{ // remove it
                    _commandAnimated = NO;
                    if(_mainFunction.numOfCommands == 0) [_playButton setAlpha:0.5];
                }];
            } else { // If is over a position in function
                _commandAnimated = YES;
                [command runAction:[SKAction sequence:@[move, [SKAction removeFromParent]]]
                        completion:^{
                            _commandAnimated = NO;
                            if (command.replacing) {
                                [selectedFunction replaceCommand:command.replacing with:command];
                            } else {
                                [selectedFunction addCommand:command];
                            }
                            [initialFunction update];
                            [selectedFunction update];
                            if (selectedFunction == _mainFunction && _playButton.alpha == 0.5) [_playButton setAlpha:1.0];
                        }];
            }
        }
    } else { // If command is not over a function
        if (initialFunction) { // If moved from a function
            [initialFunction update];
            [initialFunction.commands removeObject:_selectedNode];
            _commandAnimated = YES;
            [command runAction:remove completion:^{
                _commandAnimated = NO;
                if(_mainFunction.numOfCommands == 0) [_playButton setAlpha:0.5];
                
            }];
        } else { // If moved from toolbox
            _commandAnimated = YES;
            [command runAction:[SKAction sequence:@[move, [SKAction removeFromParent]]] completion:^{
                _commandAnimated = NO;
            }];
        }
    }
    _selectedNode = nil;
    _selectedCommand = nil;
}

- (Function*)getFunctionForNode:(SKNode*)node {
    CGPoint position = node.position;
    Command *command = _selectedCommand;
    NSString *name = [command.name stringByReplacingOccurrencesOfString:@"instance_command_"
                                                              withString:@""];
    if ([_mainFunction containsPoint:position]) {
        return _mainFunction;
    } else if ([_function1 containsPoint:position] &&
               ![name isEqualToString:@"function1"]) {
                return _function1;
    } else if ([_function2 containsPoint:position] &&
               ![name isEqualToString:@"function2"]) {
                return _function2;
    }
    return nil;
}

- (Command*)getCommandForNode:(SKNode*)node function:(Function*)function {
    for(Command *command in function.commands) {
        if([command containsPoint:node.position])
            return command;
    }
    return nil;
}

- (BOOL)isInFunction:(CGPoint)position {
    return ([_mainFunction containsPoint:position] ||
            [_function1 containsPoint:position] ||
            [_function2 containsPoint:position]);
}

- (void)createCopyOfCommand:(BOOL)instance {
    NSString *name = [_selectedNode name];
    if (instance) {
         name = [[_selectedNode name] stringByReplacingOccurrencesOfString:@"instance_command_" withString:@""];
    } else {
         name = [[_selectedNode name] stringByReplacingOccurrencesOfString:@"toolbox_command_" withString:@""];
    }
    _selectedCommand = [[Command alloc] initWithAction:name type:@"instance"
                                         position:_selectedNode.position];
    [self addChild:_selectedCommand];
}

- (void)createCopyOfColor {
    NSString *hexColor = [[_selectedNode name] stringByReplacingOccurrencesOfString:@"chooser_color_" withString:@""];
    _selectedColor = [[Color alloc] initWithColor:hexColor type:@"instance"
                                             position:_selectedNode.position];
    [self addChild:_selectedColor];
    if ([_mixArea containsPoint:_selectedColor.position]) {
        [_selectedNode removeFromParent];
    }
}

- (void)panForTranslation:(CGPoint)translation {
    CGPoint position;
    if (_selectedCommand) {
        position = _selectedCommand.position;
        [_selectedCommand setPosition:CGPointMake(position.x + translation.x,
                                                      position.y + translation.y)];
    } else if (_selectedColor) {
        position = _selectedColor.position;
        [_selectedColor setPosition:CGPointMake(position.x + translation.x,
                                                      position.y + translation.y)];
    }
}

- (void)touchesEndedForColor {
    if ([_mixArea containsPoint:_selectedColor.position]) {
        CGPoint destination;
        SKAction *move;
        move.timingMode = SKActionTimingEaseOut;
        if (_colorsToMix.count <= 2 && ![[_selectedColor getColor] isEqual:[_mixedColor getColor]]) {
            destination = CGPointMake(_mixAreaBg.position.x, _mixAreaBg.position.y);
            move = [SKAction moveTo:destination duration:0.5];
            SKColor *color = [_selectedColor getColor];
            [_colorsToMix addObject:_selectedColor];
            [_selectedColor runAction:[SKAction sequence:@[move, [SKAction removeFromParent]]] completion:^{
                if (_colorsToMix.count == 1) {
                    _mixedColor = [[Color alloc] initWithColor:[Color hexOfColor:color] type:@"chooser"
                                                      position:destination];
                    [_mixArea addChild:_mixedColor];
                } else {
                    [_mixedColor setColor:[Color blend:[_mixedColor getColor] :color]];
                    _mixedColor.name = [NSString stringWithFormat:@"chooser_color_%@",
                                        [Color hexOfColor:[_mixedColor getColor]]];
                }
            }];
        } else {
            if (_selectedNode && [_mixArea containsPoint:_selectedNode.position]) {
                [_selectedNode removeFromParent];
                [self setFillColor];;
            } else {
                destination = _selectedNode.position;
                move = [SKAction moveTo:destination duration:0.5];
                [_selectedColor runAction:[SKAction sequence:@[move, [SKAction removeFromParent]]]];
            }
        }
    } else {
        [self setFillColor];
    }
    _selectedNode = nil;
    _selectedColor = nil;
}

- (void)setFillColor {
    SKAction *move = [SKAction moveTo:_fillCommand.position duration:0.5];
    NSString *hexColor = [[_selectedColor name] stringByReplacingOccurrencesOfString:@"instance_color_" withString:@""];
    SKColor *color = [Color colorOfHex:hexColor];
    [_selectedColor runAction:[SKAction sequence:@[move, [SKAction removeFromParent]]] completion:^{
        _fillCommand.fillColor.color = color;
        _fillCommand.name = [NSString stringWithFormat:@"toolbox_command_fill_%@", hexColor];
        [self animateColorChooser];
        if (_colorsToMix.count != 0) {
            [_colorsToMix removeAllObjects];
            [_mixedColor removeFromParent];
        }
    }];
}

- (void)touchesEndedForButton {
    if ([[_selectedNode name] isEqualToString:@"button_play"] && _mainFunction.numOfCommands != 0) {
        [_playButton setTexture:[_interface textureNamed:@"button_stop"]];
        [self runFunction:_mainFunction];
        [_selectedNode setName:@"button_stop"];
    } else if ([[_selectedNode name] isEqualToString:@"button_stop"]) {
        [_playButton setTexture:[_interface textureNamed:@"button_play"]];
        [_functionTimer invalidate];
        [_selectedNode setName:@"button_play"];
        [_tiles reset];
        [self resetBot];
        [_fillCommand resetFill];
    } else if ([[_selectedNode name] isEqualToString:@"button_reset"]) {
        [_resetButton setTexture:[_interface textureNamed:@"button_reset"]];
        [_playButton setAlpha:0.5];
        [_tiles reset];
        [self resetBot];
        [self resetFunctions];
        [_fillCommand resetFill];
    }
}

@end
