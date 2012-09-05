//
//  GameLayer.m
//  SuperBallTwo
//
//  Created by Darrell Payne on 5/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#define JUMP_IMPULSE 10.5f

#import "GameLayer.h"
#import "GB2DebugDrawLayer.h"
#import "GB2Sprite.h"
#import "Ball.h"
#import "Rock.h"
#import "Launcher.h"

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
        
        // Initial Test for launcher
        launcher = [[[Launcher alloc] initWithGameLayer:self] autorelease];
        // launcher.anchorPoint = ccp(200,386);
        [self addChild:[launcher ccNode] z:25];
        [launcher setPhysicsPosition:b2Vec2(.5,0)];
        
        // Setup for the bridge
        bridge = [CCSprite spriteWithSpriteFrameName:@"Bridge.png"];
        [self addChild:bridge];
        bridge.position = ccp(160,300);
        
        // Set off particles
        particles = [CCParticleSystemQuad particleWithFile:@"ParticleTest.plist"];
        [self addChild:particles z:22];
        particles.scale = .6;
        particles.position = ccp(145,100);
        
        /* // Setup Floor
        floorSprite = [[[Floor alloc] initWithGameLayer:self] autorelease];
        [self addChild:[floorSprite ccNode] z:20];
        // [floorSprite setPhysicsPosition:b2Vec2(0,10)]; */
        
        // Setup Ball
        ball = [[[Ball alloc] initWithGameLayer:self] autorelease];
        [self addChild:[ball ccNode] z:20];
        [ball setPhysicsPosition:b2Vec2FromCC(137,120)];
        [ball setActive:NO];
        [ball setVisible:NO];
       
        
        // Tell app to check update function
        [self scheduleUpdate];
        
        // Enable screen touches
        // self.isTouchEnabled = YES;
        [[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:YES];
        
        runOnce = false;

        
    }
    return self;
}

-(void) update: (ccTime) dt
{
    curTime += dt;
    
    if (curTime> 5.0f && runOnce == false) {
        
        runOnce = true;
        if (particles != NULL) {
            [self removeChild:particles cleanup:YES];
        }
        [ball setVisible:YES];
        [ball setActive:YES];
    }
    
    /*
    // Ball's position
    float mY = [ball physicsPosition].y * PTM_RATIO;
    if (mY < 150.0f) {
        [ball applyLinearImpulse:b2Vec2(0,[ball mass]*JUMP_IMPULSE) point:[ball worldCenter]];
    
    }*/
    
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
    // CGPoint touchLocation = [self convertTouchToNodeSpace:touch]; // Stores where on screen touched
    [launcher open]; // Open the arms of the launcher
    // Ball's position
    // float mY = [ball physicsPosition].y * PTM_RATIO;
    [ball applyLinearImpulse:b2Vec2(0,[ball mass]*JUMP_IMPULSE) point:[ball worldCenter]];
            
   //  [self selectSpriteForTouch:touchLocation];
    return TRUE;    
}

/* - (void)selectSpriteForTouch:(CGPoint)touchLocation {

        if (CGRectContainsPoint(launcher.boun , touchLocation))
        {
            [rockSprite setPhysicsPosition:b2Vec2FromCC(0, 5)];
            
            [rockSprite applyLinearImpulse:b2Vec2(0.2f, 0.5f)
                                point: [rockSprite worldCenter]];
            NSLog(@"Touch seen");
            
         }
} */

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
