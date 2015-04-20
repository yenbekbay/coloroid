//
//  Command.h
//  Coloroid
//
//  Created by Ayan Yenbekbay on 4/25/14.
//  Copyright (c) 2014 Ayan Yenbekbay. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface Command : SKNode

@property (nonatomic, strong) SKSpriteNode *bg;
@property (nonatomic, strong) SKSpriteNode *fillColor;
@property (nonatomic, strong) Command *replacing;
@property (nonatomic, strong) NSString *type;
@property (nonatomic, strong) NSString *action;

- (instancetype)initWithAction:(NSString*)action type:(NSString *)type position:(CGPoint)position;
- (instancetype)initBlankAtPosition:(CGPoint)position;
- (void)createColorLayerWithColor:(NSString*)hexColor;
- (void)resetFill;

@end
