//
//  GameLayer.m
//  SuperBallTwo
//
//  Created by Darrell Payne on 5/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#define JUMP_IMPULSE 6.0f

#import "GameLayer.h"
#import "GB2DebugDrawLayer.h"
#import "GB2Sprite.h"
#import "Ball.h"
#import "Rock.h"
#import "Floor.h"

@implementation GameLayer

-(id) init
{
    if( (self=[super init]))
    {
        // Load all Sprites
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"sprites.plist"];
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"Background.plist"];
        
        // Load Box2d Shapes
        [[GB2ShapeCache sharedShapeCache] addShapesWithFile:@"shapes.plist"];
        
        // Setup game background layer
        background = [CCSprite spriteWithSpriteFrameName:@"Background.png"];
        [self addChild:background z:0];
        background.anchorPoint = ccp(0,0);
        background.position = ccp(0,0);
        
        // Setup left Pod
        leftPod = [CCSprite spriteWithSpriteFrameName:@"leftPod.png"];
        [self addChild:leftPod z:2];
        leftPod.anchorPoint = ccp(0, 0);
        leftPod.position = ccp(0, 0);
        
        // Setup right Pod
        rightPod = [CCSprite spriteWithSpriteFrameName:@"rightPod.png"];
        [self addChild:rightPod z:2];
        rightPod.anchorPoint = ccp(0, 0);
        rightPod.position = ccp(157, 0);
        
        /* // Setup Ejector Mound
        ejector = [CCSprite spriteWithSpriteFrameName:@"mound.png"];
        [self addChild:ejector z:2];
        // int width = [ejector boundingBox].size.width;
        ejector.anchorPoint = ccp(0, 0);
        ejector.position = ccp(70, 10); */
        
        // Setup Floor
        floorSprite = [[[Floor alloc] initWithGameLayer:self] autorelease];
        [self addChild:[floorSprite ccNode] z:20];
        // [floorSprite setPhysicsPosition:b2Vec2(0,10)];
        
        // Setup Ball
        ball = [[[Ball alloc] initWithGameLayer:self] autorelease];
        [self addChild:[ball ccNode] z:10000];
        [ball setPhysicsPosition:b2Vec2FromCC(155,600)];
        
        // Setup Rock
        rockSprite = [[[Rock alloc] initWithGameLayer:self] autorelease];
        [self addChild:[rockSprite ccNode] z:2];
        [rockSprite setPhysicsPosition:b2Vec2FromCC(0, 5)];
        
        // Tell app to check update function
        [self scheduleUpdate];
        
        // Enable screen touches
        // self.isTouchEnabled = YES;
        [[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:YES];

        
    }
    return self;
}

-(void) update: (ccTime) dt
{
    // Ball's position
    float mY = [ball physicsPosition].y * PTM_RATIO;
    if (mY < 150.0f) {
        [ball applyLinearImpulse:b2Vec2(0,[ball mass]*JUMP_IMPULSE) point:[ball worldCenter]];
    
    }
    
   /* // Adjust camera
    const float ballHeight = 50.0f;
    const float screenHeight = 480.0f;
    float cY = mY - ballHeight - screenHeight/2.0f; 
    if(cY < 0)
    {
        cY = 0;
    }
    
    // Do some parallax scrolling    
    [ejector setPosition:ccp(70, -cY)];
    [leftPod setPosition:ccp(0, -cY*0.9)];
    [rightPod setPosition:ccp(157, -cY*0.9)];
    [floorSprite setPhysicsPosition:b2Vec2(0,-cY*0.8)];
    [background setPosition:ccp(0,-cY*0.6)];      // move main background even slower */

}

// This method called whenever screen is touched
- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event {    
    CGPoint touchLocation = [self convertTouchToNodeSpace:touch]; // Stores where on screen touched
    [self selectSpriteForTouch:touchLocation];      
    return TRUE;    
}

- (void)selectSpriteForTouch:(CGPoint)touchLocation {

        if (CGRectContainsPoint(leftPod.boundingBox , touchLocation))
        {
            [rockSprite setPhysicsPosition:b2Vec2FromCC(0, 5)];
            
            [rockSprite applyLinearImpulse:b2Vec2(0.2f, 0.5f)
                                point: [rockSprite worldCenter]];
            NSLog(@"Touch seen");
            
         }
}

+(CCScene *) scene
{
    // 'scene' is an autorelease object.
    CCScene *scene = [CCScene node];
    
    // 'layer' is an autorelease object.
    GameLayer *layer = [GameLayer node];
    
    // add layer as a child to scene
    [scene addChild: layer];
    
    // return the scene
    return scene;
}

@end
