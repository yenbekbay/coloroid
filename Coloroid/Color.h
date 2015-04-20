//
//  Color.h
//  Coloroid
//
//  Created by Ayan Yenbekbay on 4/26/14.
//  Copyright (c) 2014 Ayan Yenbekbay. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface Color : SKNode

@property (nonatomic, strong) NSString *type;
@property (nonatomic, strong) NSString *hexCode;

- (instancetype)initWithColor:(NSString*)hexColor type:(NSString*)type position:(CGPoint)position;
- (void)setColor:(SKColor*)color;
- (SKColor*)getColor;
+ (SKColor*)colorOfHex:(NSString*)string;
+ (NSString*)hexOfColor:(SKColor*)color;
+ (SKColor*)blend:(SKColor*)c1 :(SKColor*)c2;

@end
