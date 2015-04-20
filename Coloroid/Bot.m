//
//  Bot.m
//  Coloroid
//
//  Created by Ayan Yenbekbay on 4/19/14.
//  Copyleft (c) 2014 Ayan Yenbekbay. All lefts reserved.
//

#import "Bot.h"

@implementation Bot {
    SKTextureAtlas *_front;
    SKSpriteNode *_head;
    SKSpriteNode *_antenna;
    SKSpriteNode *_body;
    SKSpriteNode *_rightArm;
    SKSpriteNode *_leftArm;
    SKSpriteNode *_rightClaw;
    SKSpriteNode *_leftClaw;
    SKNode *_bucket;
    SKSpriteNode *_bucketBody;
    SKSpriteNode *_bucketHandle;
    SKAction *_headFrontAnimation;
    SKAction *_bodyFrontAnimation;
    SKAction *_rightArmFrontAnimation;
    SKAction *_leftArmFrontAnimation;
    SKAction *_rightClawFrontAnimation;
    SKAction *_leftClawFrontAnimation;
    SKAction *_bucketHandleFrontAnimation;
    SKAction *_headAroundAnimation;
    SKAction *_bodyAroundAnimation;
    SKAction *_rightArmAroundAnimation;
    SKAction *_leftArmAroundAnimation;
    SKAction *_rightClawAroundAnimation;
    SKAction *_leftClawAroundAnimation;
    SKAction *_bucketHandleAroundAnimation;
}

- (instancetype)init {
    if (self = [super init]) {
        _direction = 270;
        self.zPosition = 3;
        [self createElements];
        [self createAnimations];
    }
    return self;
}

- (void)createElements {
    _front = [SKTextureAtlas atlasNamed:@"elements_front"];
    
    // Add head
    _head = [SKSpriteNode spriteNodeWithTexture: [_front textureNamed:@"head_inactive_front"]];
    _head.zPosition = 2;
    [self addChild:_head];
    
    // Add antenna
    _antenna = [SKSpriteNode spriteNodeWithTexture: [_front textureNamed:@"antenna_inactive"]];
    _antenna.position = CGPointMake(_head.position.x, _head.position.y + _head.size.height / 2);
    _antenna.zPosition = 3;
    [self addChild:_antenna];
    
    // Add body
    _body = [SKSpriteNode spriteNodeWithTexture: [_front textureNamed:@"body_front"]];
    _body.position = CGPointMake(_head.position.x, _head.position.y - _head.size.height / 2);
    [self addChild:_body];
    
    // Add right arm
    _rightArm = [SKSpriteNode spriteNodeWithTexture:
                             [_front textureNamed:@"right_arm_front"]];
    _rightArm.position = CGPointMake(_body.position.x - 9 - _rightArm.size.width / 2,
                                   _body.position.y);
    _rightArm.zPosition = 2;
    
    // Add left arm
    _leftArm = [SKSpriteNode spriteNodeWithTexture:
                              [_front textureNamed:@"left_arm_front"]];
    _leftArm.position = CGPointMake(_body.position.x + 9 + _leftArm.size.width / 2,
                                    _body.position.y);
    _leftArm.zPosition = 2;
    
    // Add right claw
    _rightClaw = [SKSpriteNode spriteNodeWithTexture:
                                  [_front textureNamed:@"claw_front"]];
    _rightClaw.anchorPoint = CGPointMake(0.5, 1.0);
    _rightClaw.position = CGPointMake(2 - _rightClaw.size.width / 2, _rightArm.size.height / 2 - 6);
    _rightClaw.zPosition = 3;
    [_rightArm addChild:_rightClaw];
    
    // Add left claw
    _leftClaw = [SKSpriteNode spriteNodeWithTexture:
                               [_front textureNamed:@"claw_front"]];
    _leftClaw.anchorPoint = CGPointMake(0.5, 1.0);
    _leftClaw.position = CGPointMake(_leftClaw.size.width / 2 - 2, _leftArm.size.height / 2 - 6);
    _leftClaw.zPosition = 3;
    [_leftArm addChild:_leftClaw];
    
    // Add bucket
    _bucket = [SKNode node];
    _bucketBody = [SKSpriteNode spriteNodeWithTexture:
                                [_front textureNamed:@"bucket_body"]];
    _bucketBody.position = CGPointMake(-8, -_bucketBody.size.height / 2);
    _bucketBody.zPosition = 1;
    [_bucket addChild:_bucketBody];
    
    _bucketColor = [SKSpriteNode spriteNodeWithTexture:
                                 [_front textureNamed:@"bucket_mask"]];
    _bucketColor.position = _bucketBody.position;
    _bucketColor.color = SKColorWithRGB(125, 125, 125);
    _bucketColor.colorBlendFactor = 1.0;
    [_bucket addChild:_bucketColor];
    
    _bucketHandle = [SKSpriteNode spriteNodeWithTexture:
                            [_front textureNamed:@"bucket_handle_front"]];
    _bucketHandle.position = _bucketBody.position;
    _bucketHandle.zPosition = 2;
    [_bucket addChild:_bucketHandle];
    
    [_rightArm addChild:_bucket];
    [self addChild:_rightArm];
    [self addChild:_leftArm];
    
    // Add body shadow
    CGRect shadowBox = CGRectMake(_body.position.x - 12,
                                  _body.position.y - _body.size.width / 2 - _body.size.height / 2, 24, 8);
    UIBezierPath *ellipsePath = [UIBezierPath bezierPathWithOvalInRect:shadowBox];
    SKShapeNode *bodyShadow = [SKShapeNode node];
    bodyShadow.path = ellipsePath.CGPath;
    bodyShadow.fillColor = SKColorWithRGBA(0, 0, 0, 30);
    bodyShadow.strokeColor = [SKColor clearColor];
    bodyShadow.zPosition = -10;
    [self addChild:bodyShadow];
}

- (void)turnRight {
    if (_direction == 270) {
        _head.xScale = -1;
        _body.xScale = -1;
        _bucketHandle.xScale = -1;
        [self moveArmsTo:@"right"];
        [self animateTurnReversed:NO around:NO];
        _direction = 180;
    } else if (_direction == 180) {
        [self moveArmsTo:@"back"];
        [self animateTurnReversed:NO around:YES];
        _direction = 90;
    } else if (_direction == 0) {
        [self moveArmsTo:@"forward"];
        [self animateTurnReversed:YES around:NO];
        _direction = 270;
    } else {
        _head.xScale = 1;
        _body.xScale = 1;
        _bucketHandle.xScale = 1;
        [self moveArmsTo:@"left"];
        [self animateTurnReversed:YES around:YES];
        _direction = 0;
    }
}

- (void)turnLeft {
    if (_direction == 270) {
        _head.xScale = 1;
        _body.xScale = 1;
        _bucketHandle.xScale = 1;
        [self moveArmsTo:@"left"];
        [self animateTurnReversed:NO around:NO];
        _direction = 0;
    } else if (_direction == 0) {
        [self moveArmsTo:@"back"];
        [self animateTurnReversed:NO around:YES];
        _direction = 90;
    } else if (_direction == 180) {
        _head.xScale = -1;
        _body.xScale = -1;
        _bucketHandle.xScale = -1;
        [self moveArmsTo:@"forward"];
        [self animateTurnReversed:YES around:NO];
        _direction = 270;
    } else {
        _head.xScale = -1;
        _body.xScale = -1;
        _bucketHandle.xScale = -1;
        [self moveArmsTo:@"right"];
        [self animateTurnReversed:YES around:YES];
        _direction = 180;
    }
}

- (void)animateTurnReversed:(BOOL)reversed around:(BOOL)around {
    SKAction *headAnimation;
    SKAction *bodyAnimation;
    SKAction *rightArmAnimation;
    SKAction *leftArmAnimation;
    SKAction *rightClawAnimation;
    SKAction *leftClawAnimation;
    SKAction *bucketAnimation;
    if (!around) {
        headAnimation = _headFrontAnimation;
        bodyAnimation = _bodyFrontAnimation;
        rightArmAnimation = _rightArmFrontAnimation;
        leftArmAnimation = _leftArmFrontAnimation;
        rightClawAnimation = _rightClawFrontAnimation;
        leftClawAnimation = _leftClawFrontAnimation;
        bucketAnimation = _bucketHandleFrontAnimation;
    } else {
        headAnimation = _headAroundAnimation;
        bodyAnimation = _bodyAroundAnimation;
        rightArmAnimation = _rightArmAroundAnimation;
        leftArmAnimation = _leftArmAroundAnimation;
        rightClawAnimation = _rightClawAroundAnimation;
        leftClawAnimation = _leftClawAroundAnimation;
        bucketAnimation = _bucketHandleAroundAnimation;
    }
    if (reversed) {
        headAnimation = [headAnimation reversedAction];
        bodyAnimation = [bodyAnimation reversedAction];
        rightArmAnimation = [rightArmAnimation reversedAction];
        leftArmAnimation = [leftArmAnimation reversedAction];
        rightClawAnimation = [rightClawAnimation reversedAction];
        leftClawAnimation = [leftClawAnimation reversedAction];
        bucketAnimation = [bucketAnimation reversedAction];
    }
    if (!around && reversed) {
        if (_direction == 180) {
            _rightArm.xScale = 1;
           rightArmAnimation = leftArmAnimation;
        } else {
            _leftArm.xScale = 1;
            leftArmAnimation = rightArmAnimation;
        }
        // when animation is done return to initial texture
        [_head runAction:headAnimation completion:^{
            [_head runAction:[SKAction setTexture:[_front textureNamed:@"head_active_front"]]];
        }];
        [_body runAction:bodyAnimation completion:^{
            [_body runAction:[SKAction setTexture:[_front textureNamed:@"body_front"]]];
        }];
        [_rightArm runAction:rightArmAnimation completion:^{
            [_rightArm runAction:[SKAction setTexture:[_front textureNamed:@"right_arm_front"]]];
        }];
        [_leftArm runAction:leftArmAnimation completion:^{
            [_leftArm runAction:[SKAction setTexture:[_front textureNamed:@"left_arm_front"]]];
        }];
        [_rightClaw runAction:rightClawAnimation completion:^{
            [_rightClaw runAction:[SKAction setTexture:[_front textureNamed:@"claw_front"]]];
        }];
        [_leftClaw runAction:rightClawAnimation completion:^{
            [_leftClaw runAction:[SKAction setTexture:[_front textureNamed:@"claw_front"]]];
        }];
        [_bucketHandle runAction:bucketAnimation completion:^{
            [_bucketHandle runAction:[SKAction setTexture:[_front textureNamed:@"bucket_handle_front"]]];
        }];
    } else {
        [_head runAction: headAnimation];
        [_body runAction: bodyAnimation];
        [_rightArm runAction: rightArmAnimation];
        [_leftArm runAction: leftArmAnimation];
        [_rightClaw runAction: rightClawAnimation];
        [_leftClaw runAction: leftClawAnimation];
        [_bucketHandle runAction: bucketAnimation];
    }
}

- (void)createAnimations {
    _headFrontAnimation = [self createAnimOfElement:@"head" around:NO];
    _bodyFrontAnimation = [self createAnimOfElement:@"body" around:NO];
    _rightArmFrontAnimation = [self createAnimOfElement:@"right_arm" around:NO];
    _leftArmFrontAnimation = [self createAnimOfElement:@"left_arm" around:NO];
    _rightClawFrontAnimation = [self createAnimOfElement:@"right_claw" around:NO];
    _leftClawFrontAnimation = [self createAnimOfElement:@"left_claw" around:NO];
    _bucketHandleFrontAnimation = [self createAnimOfElement:@"bucket" around:NO];
    _headAroundAnimation = [self createAnimOfElement:@"head" around:YES];
    _bodyAroundAnimation = [self createAnimOfElement:@"body" around:YES];
    _rightArmAroundAnimation = [self createAnimOfElement:@"right_arm" around:YES];
    _leftArmAroundAnimation = [self createAnimOfElement:@"left_arm" around:YES];
    _rightClawAroundAnimation = [self createAnimOfElement:@"right_claw" around:YES];
    _leftClawAroundAnimation = [self createAnimOfElement:@"left_claw" around:YES];
    _bucketHandleAroundAnimation = [self createAnimOfElement:@"bucket" around:YES];
}

- (SKAction*)createAnimOfElement:(NSString *)element around:(BOOL)around {
    SKTextureAtlas *atlas = [SKTextureAtlas atlasNamed:[NSString stringWithFormat:@"%@_anim", element]];
    int first;
    int last;
    if (around) {
        first = 11;
        last = 20;
    } else {
        first = 1;
        last = 10;
    }
    NSMutableArray *textures = [NSMutableArray arrayWithCapacity:last-first+1];
    for (int i = first; i <= last; i++) {
        int num;
        if ([element isEqualToString:@"head"] && i > 14) {
            num = 14;
        } else if ([element isEqualToString:@"body"] && i > 15) {
            num = 15;
        } else {
            num = i;
        }
        SKTexture *texture = [atlas textureNamed: [NSString stringWithFormat:@"%@_turn%d", element, num]];
        [textures addObject:texture];
    }
    float framesPerSec = 0.03;
    SKAction *action = [SKAction animateWithTextures:textures timePerFrame:framesPerSec];
    action.timingMode = SKActionTimingEaseInEaseOut;
    return action;
}

- (void)moveArmsTo:(NSString*)dir {
    // Arm points
    CGPoint armCenter = CGPointMake(_body.position.x, _body.position.y - 11);
    CGPoint armLeftForward = CGPointMake(_body.position.x - 9 - _rightArm.size.width / 2,
                                         _body.position.y);
    CGPoint armRightForward = CGPointMake(_body.position.x + 9 + _leftArm.size.width / 2,
                                          _body.position.y);
    CGPoint armLeftBack = CGPointMake(armLeftForward.x + 7, _body.position.y);
    CGPoint armRightBack = CGPointMake(armRightForward.x - 7, _body.position.y);
    
    // Arm actions
    SKAction *armMoveToSide = [SKAction moveTo:armCenter duration:0.3];
    SKAction *armMoveToForwardFromLeft = [SKAction moveTo:armLeftForward duration:0.3];
    SKAction *armMoveToForwardFromRight = [SKAction moveTo:armRightForward duration:0.3];
    SKAction *armMoveToBackFromLeft = [SKAction moveTo:armLeftBack duration:0.3];
    SKAction *armMoveToBackFromRight = [SKAction moveTo:armRightBack duration:0.3];
    
    // Claw actions
    SKAction *clawMoveToRight = [SKAction moveTo:CGPointMake(-6, 0) duration:0.3];
    SKAction *clawMoveToLeft = [SKAction moveTo:CGPointMake(7, 0) duration:0.3];
    SKAction *clawMoveToForwardFromLeft = [SKAction moveTo:CGPointMake(-8, 10) duration:0.3];
    SKAction *clawMoveToForwardFromRight = [SKAction moveTo:CGPointMake(8, 10) duration:0.3];
    SKAction *clawMoveToBackFromLeft = [SKAction moveTo:CGPointMake(-8, 1) duration:0.3];
    SKAction *clawMoveToBackFromRight = [SKAction moveTo:CGPointMake(8, 1) duration:0.3];
    
    // Bucket actions
    SKAction *bucketMoveToRight = [SKAction moveTo:CGPointMake(17, 10) duration:0.3];
    SKAction *bucketMoveToLeft = [SKAction moveTo:CGPointMake(17, -10) duration:0.3];
    SKAction *bucketMoveToForwardFromLeft = [SKAction moveTo:CGPointZero duration:0.3];
    SKAction *bucketMoveToBackFromRight = [SKAction moveTo:CGPointMake(16, -9) duration:0.3];
    
    // Start moving
    if ([dir isEqualToString:@"right"] || [dir isEqualToString:@"left"]) {
        [_leftArm runAction:armMoveToSide];
        [_rightArm runAction:armMoveToSide];
        if ([dir isEqualToString:@"right"]) {
            [_leftClaw runAction:clawMoveToRight];
            [_rightClaw runAction:clawMoveToRight];
            [_bucket runAction:bucketMoveToRight];
            _leftArm.zPosition = 2;
            _leftClaw.zPosition = 3;
            _rightArm.zPosition = -2;
            _rightClaw.zPosition = -3;
            _bucketBody.zPosition = -5;
            _bucketHandle.zPosition = -4;
            _bucketColor.zPosition = -6;
        } else {
            [_leftClaw runAction:clawMoveToLeft];
            [_rightClaw runAction:clawMoveToLeft];
            [_bucket runAction:bucketMoveToLeft];
            _leftArm.zPosition = -2;
            _leftClaw.zPosition = -3;
            _rightArm.zPosition = 2;
            _rightClaw.zPosition = 3;
            _bucketBody.zPosition = 1;
            _bucketHandle.zPosition = 2;
        }
    } else {        
        if([dir isEqualToString:@"forward"]) {
            [_leftArm runAction:armMoveToForwardFromRight];
            [_rightArm runAction:armMoveToForwardFromLeft];
            [_leftClaw runAction:clawMoveToForwardFromRight];
            [_rightClaw runAction:clawMoveToForwardFromLeft];
            [_bucket runAction:bucketMoveToForwardFromLeft];
            _leftArm.zPosition = 2;
            _leftClaw.zPosition = 3;
            _rightArm.zPosition = 2;
            _rightClaw.zPosition = 3;
            _bucketBody.zPosition = 1;
            _bucketHandle.zPosition = 2;
        } else {
            [_leftArm runAction:armMoveToBackFromLeft];
            [_rightArm runAction:armMoveToBackFromRight];
            [_leftClaw runAction:clawMoveToBackFromLeft];
            [_rightClaw runAction:clawMoveToBackFromRight];
            [_bucket runAction:bucketMoveToBackFromRight];
            _leftArm.zPosition = -2;
            _leftClaw.zPosition = -3;
            _rightArm.zPosition = -2;
            _rightClaw.zPosition = -3;
            _bucketBody.zPosition = -5;
            _bucketHandle.zPosition = -4;
            _bucketColor.zPosition = -6;
        }
    }
}

- (void)activate:(BOOL)reverse {
    NSMutableArray *headTextures = [NSMutableArray arrayWithCapacity:5];
    for (int i = 1; i <= 5; i++) {
        SKTexture *texture = [[SKTextureAtlas atlasNamed:@"head_activate_anim"] textureNamed: [NSString stringWithFormat:@"head_activate%d", i]];
        [headTextures addObject:texture];
    }
    NSMutableArray *antennaTextures = [NSMutableArray arrayWithArray:@[
                                                        [_front textureNamed:@"antenna_inactive"],
                                                        [_front textureNamed:@"antenna_active"]]];
    SKAction *headAnimation = [SKAction animateWithTextures:headTextures timePerFrame:0.03];
    headAnimation.timingMode = SKActionTimingEaseInEaseOut;
    if (!reverse) {
        _active = YES;
        [_antenna runAction:[SKAction moveByX:0 y:5 duration:0.15]];
        [_head runAction:headAnimation completion:^{
            [_antenna runAction:[SKAction repeatActionForever:
                                     [SKAction animateWithTextures:antennaTextures timePerFrame:1.0 resize:YES restore:NO]]];
        }];
    } else {
        _active = NO;
        [_head runAction:[headAnimation reversedAction]];
        [_antenna runAction:[SKAction moveByX:0 y:-5 duration:0.15] completion:^{
            [_antenna removeAllActions];
            [_antenna setTexture:[_front textureNamed:@"antenna_inactive"]];
        }];
    }
}

@end
