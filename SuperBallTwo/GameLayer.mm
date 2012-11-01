//
//  GameLayer.m
//  SuperBallTwo
//
//  Created by Darrell Payne on 5/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

// #define JUMP_IMPULSE 12.5f
#define JUMP_IMPULSE 11.0f
#define WIDTH 320
#define HEIGHT 480

#import "GameLayer.h"
#import "GB2DebugDrawLayer.h"
#import "GB2Sprite.h"
#import "Ball.h"
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
        
        world = [[GB2Engine sharedInstance]world];
        
        // Setup game background layer
        background = [CCSprite spriteWithSpriteFrameName:@"Background.png"];
        [self addChild:background z:0];
        background.anchorPoint = ccp(0,0);
        background.position = ccp(0,0);
        
        // Initial Test for launcher
        launcher = [[[Launcher alloc] initWithGameLayer:self] autorelease];
        [self addChild:[launcher ccNode] z:25];
        [launcher setPhysicsPosition:b2Vec2FromCC(60, 0)];
        
        // Setup for the bridge
        bridge = [CCSprite spriteWithSpriteFrameName:@"Bridge.png"];
        [self addChild:bridge];
        bridge.position = ccp(160,250);
        
        // Setup for emitter
        emmitterDevice = [CCSprite spriteWithSpriteFrameName:@"newEmitter01.png"];
        [self addChild:emmitterDevice z:24];
        emmitterDevice.position = ccp(160,400);
        
        
        //Setup for numbers
        numbers[0] = [CCSprite spriteWithSpriteFrameName:@"NumberThree.png"];
        numbers[0].opacity = 0;
        numbers[0].position = ccp(160,150);
        [self addChild:numbers[0] z:255];
        
        numbers[1] = [CCSprite spriteWithSpriteFrameName:@"NumberTwo.png"];
        numbers[1].opacity = 0;
        numbers[1].position = ccp(160,150);
        [self addChild:numbers[1] z:255];
        
        numbers[2] = [CCSprite spriteWithSpriteFrameName:@"NumberOne.png"];
        numbers[2].opacity = 0;
        numbers[2].position = ccp(160,150);
        [self addChild:numbers[2] z:255];
        
        // Set off particles
        particles = [CCParticleSystemQuad particleWithFile:@"ParticleTest.plist"];
        [self addChild:particles z:22];
        particles.scale = .6;
        particles.position = ccp(160,100);
        
        //particles from pods
        podParticles = [CCParticleSystemQuad particleWithFile:@"ParticleEmitter.plist"];
        podParticles.scale = .75;
        // podParticles.position = ccp(160,375); // Not necessary
        
        // Setup Ball
        ball = [[[Ball alloc] initWithGameLayer:self] autorelease];
        [self addChild:[ball ccNode] z:20];
        [ball setPhysicsPosition:b2Vec2FromCC(160,120)];
        [ball setActive:NO];
        [ball setVisible:NO];
        
        // Tell app to check update function
        [self scheduleUpdate];
        
        // Enable screen touches
        // self.isTouchEnabled = YES;
        [[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:YES];
        
        runOnce = false;
        doCountDown = true;
        currNumber = 0; // Start countdown with numberThree;
        
        modeLevel = 0; // current level
        
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
    
    
    // Do the countdown here
    
    if (doCountDown && ball.active == YES) {
        ++currCountdown;
        numbers[currNumber].scale += 0.001f;
        if (currCountdown<64) {
            numberOpacity += 4;
            if (numberOpacity>255) {
                numberOpacity = 255;
            }
        }else if (currCountdown>80){
            numberOpacity -= 4;
            if (numberOpacity<0) {
                numberOpacity = 0;
                currCountdown = 0;
                currNumber += 1;
                if (currNumber > 2) {
                    doCountDown = false;
                    currNumber = 2;
                    [launcher setToOpen];
                    [ball applyLinearImpulse:b2Vec2(0,[ball mass]*JUMP_IMPULSE) point:[ball worldCenter]];

                }
            }
        }
        numbers[currNumber].opacity = numberOpacity;
    }
    
    
    
    /*
    // Ball's position
    float mY = [ball physicsPosition].y * PTM_RATIO;
    if (mY < 150.0f) {
        [ball applyLinearImpulse:b2Vec2(0,[ball mass]*JUMP_IMPULSE) point:[ball worldCenter]];
    
    }*/
    
    
    // Adjust camera
    float mY = [ball physicsPosition].y * PTM_RATIO;
    const float ballHeight = 50.0f;
    const float screenHeight = 480.0f;
    float cY = mY - ballHeight - screenHeight/2.0f; 
    if(cY < 0)
    {
        cY = 0;
    }
    
    // Lock the bridge into position and start emitter
    if (cY > 300.0f && modeLevel == 0)
    {
        cY = 300.0f;
        modeLevel = 1;
        [self addChild:podParticles z:22];
    }
    
    if (cY < 300.0f && modeLevel == 1) {
        cY = 300.0f;
    }
    
    
    // Do some parallax scrolling
    [launcher setPhysicsPosition:b2Vec2FromCC(60, -cY)];
    [bridge setPosition:ccp(160, 250-cY)];
    [emmitterDevice setPosition:ccp(160,400-cY)];
    [podParticles setPosition:ccp(160,415-cY)];
    
    [background setPosition:ccp(0,-cY*0.6)];      // move main background even slower
    
   
    // Attempt to stop the ball at a point above the ejector
    
    float base = 100.0f;
    float targetHeight = 110.0f;
    float distanceAboveGround = mY - base;
    b2Vec2 ballVel = [ball linearVelocity];
    float   springConstant = 0.25f;
    
    //dont do anything if too far above ground
    if ( distanceAboveGround < targetHeight && modeLevel == 1) {
        
        //replace distanceAboveGround with the 'look ahead' distance
        //this will look ahead 0.25 seconds - longer gives more 'damping'
        // Higher numbers reduce 'bounce' of ball
        distanceAboveGround += 2.5f * ballVel.y;
        
        float distanceAwayFromTargetHeight = targetHeight - distanceAboveGround;
        [ball applyForce:b2Vec2(0,springConstant * distanceAwayFromTargetHeight) point:[ball worldCenter]];
        
        /* m_hovercarBody->ApplyForce( b2Vec2(0,springConstant*distanceAwayFromTargetHeight), m_hovercarBody->GetWorldCenter() ); */
        
        //negate gravity
        [ball applyForce:[ball mass] * -world->GetGravity() point:[ball worldCenter]];
        /* m_hovercarBody->ApplyForce( m_hovercarBody->GetMass() * -m_world->GetGravity(), m_hovercarBody->GetWorldCenter() ); */
    }
}

// This method called whenever screen is touched
- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event {    
        // CGPoint touchLocation = [self convertTouchToNodeSpace:touch]; // Stores where on screen touched
          // Ball's position
    // float mY = [ball physicsPosition].y * PTM_RATIO;
    [launcher setToOpen];
    
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
