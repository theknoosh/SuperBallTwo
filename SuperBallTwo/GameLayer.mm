//
//  GameLayer.m
//  SuperBallTwo
//
//  Created by Darrell Payne on 5/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

// #define JUMP_IMPULSE 12.5f
#define JUMP_IMPULSE 0.4f
#define WIDTH 320
#define HEIGHT 480
#define POINTERX 45
#define POINTERX_MAX 275
#define NORMAL 0
#define ANGRY 1
#define SHAKE 2
#define ARC4RANDOM_MAX      0x100000000

#import "GameLayer.h"
#import "GB2DebugDrawLayer.h"
#import "GB2Sprite.h"
#import "Ball.h"
#import "Launcher.h"
#import "Piston.h"
#import "DynamicObject.h"
#import "SimpleAudioEngine.h"


@implementation GameLayer

-(id) init
{
    if( (self=[super init]))
    {
        
        [SimpleAudioEngine sharedEngine];
        
        
        // Load all assets *******************************
        
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"sprites.plist"];
        
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"Background.plist"];
        
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"Controls.plist"];
        
         // Load Box2d Shapes
        [[GB2ShapeCache sharedShapeCache] addShapesWithFile:@"shapes.plist"];
        
        // ***********************************************

        world = [[GB2Engine sharedInstance]world];
        // world->SetGravity(b2Vec2FromCC(0, -9.0f));
        
        justOnce = YES;
        spinnerExists = NO;
        pulseOn = NO;
        
        // Setup all graphics ****************************
        
        // Setup game background layer
        background = [CCSprite spriteWithSpriteFrameName:@"Background.png"];
        [self addChild:background z:0];
        background.anchorPoint = ccp(0,0);
        background.position = ccp(0,0);
        
        // add walls to the left
        GB2Node *leftWall = [[GB2Node alloc] initWithStaticBody:nil node:nil];
        [leftWall addEdgeFrom:b2Vec2FromCC(0, 0) to:b2Vec2FromCC(0, 20000)];
        
        // add walls to the right
        GB2Node *rightWall = [[GB2Node alloc] initWithStaticBody:nil node:nil];
        [rightWall addEdgeFrom:b2Vec2FromCC(320, 0) to:b2Vec2FromCC(320, 20000)];
        
        // add floor
        GB2Node *theFloor = [[GB2Node alloc] initWithStaticBody:nil node:nil];
        [theFloor addEdgeFrom:b2Vec2FromCC(0, 0) to:b2Vec2FromCC(0, 320)];
        
         // Setup object layer
        // Contains all active objects
    	objectLayer = [CCSpriteBatchNode batchNodeWithFile:@"sprites.pvr.ccz" capacity:150];
        [self addChild:objectLayer z:10];
        
        // Setup control layer
        controlLayer = [CCSpriteBatchNode batchNodeWithFile:@"Controls.pvr.ccz" capacity:150];
        [self addChild:controlLayer z:10];
       
        // Load physics object Launcher
        launcher = [[[Launcher alloc] initWithGameLayer:self] autorelease];
        [objectLayer addChild:[launcher ccNode] z:25];
        [launcher setPhysicsPosition:b2Vec2FromCC(60, 0)];
        
        // Setup for the bridge
        bridge = [[StaticObject alloc]initWithGameLayer:self andObjName:@"brokenBridge"andSpriteName:@"brokenBridge.png"];
        [objectLayer addChild:[bridge ccNode] z:25];
        // [bridge setPhysicsPosition:b2Vec2FromCC(160, 250)];
        [bridge setActive:NO];
        
        // Initialize NSMutableArray
        // triangleObjects = [[NSMutableArray alloc] init];
        
        float curHeight = 450.0f;
        
        emmitterDevice = [CCSprite spriteWithSpriteFrameName:@"newEmitter.png"];
        [objectLayer addChild:emmitterDevice z:25];
        [emmitterDevice setPosition:ccp(50, 370)]; // emitter is simple sprite
        
        controlButton = [CCSprite spriteWithSpriteFrameName:@"ControlButton.png"];
        [controlLayer addChild:controlButton z:25];
        [controlButton setPosition:ccp(60, 60)];
        
        controlButtonArrows = [CCSprite spriteWithSpriteFrameName:@"ControlButtonArrows.png"];
        [controlLayer addChild:controlButtonArrows z:24];
        [controlButtonArrows setPosition:ccp(60, 60)];
        
        // Set off particles
        particles = [CCParticleSystemQuad particleWithFile:@"ParticleTest.plist"];
        [self addChild:particles z:22];
        particles.scale = .6;
        particles.position = ccp(160,200);

        
        //particles from pods
        podParticles = [CCParticleSystemQuad particleWithFile:@"ParticleEmitter.plist"];
        podParticles.scale = .75;
        [podParticles setPosition:ccp(160,80)];
        // [self addChild:podParticles z:22];
        
        // Setup Ball
        ball = [[[Ball alloc] initWithGameLayer:self] autorelease];
        [objectLayer addChild:[ball ccNode] z:2];
        [ball setPhysicsPosition:b2Vec2FromCC(160,220)];
        [ball setActive:NO];
        [ball setVisible:NO];
        
        // Tell app to check update function
        [self scheduleUpdate];
        
        // Enable screen touches
        [[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:YES];
        
        runOnce = false;
        doCountDown = true;
        currNumber = 0; // Start countdown with numberThree;
        
        modeLevel = 0; // initial level
        currPressure = 0.0f; // initial pressure
        toggle = true; // Initial toggle
        shakeDelay = 0;
        playSoundOnce = YES;
        wasNotDone = YES;
        
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
    
    // Speed of the ball, when it gets below 1, it is at
    // top of arc
    
    b2Vec2 currentVelocity = [ball linearVelocity];
    float currentSpeed = currentVelocity.Length();    
    
    if (doCountDown && ball.active == YES) {
        [launcher setToOpen];
    }
    
    // Camera follows ball
    float mY = [ball physicsPosition].y * PTM_RATIO;
    const float ballHeight = 50.0f;
    const float screenHeight = 480.0f;
    float cY = mY - ballHeight - screenHeight/2 - (screenHeight/4);
    if(cY < 0)
    {
        cY = 0;
    }
    
    // Lock the bridge into position and start emitter
    
    if (cY > 500.0f && modeLevel == 0)
    {
        modeLevel = 1;
    }
    
    if (cY < 300.0f && modeLevel == 1) {
        cY = 300.0f;
     }
    static float gridPosition = 400;
    
    [bridge setPhysicsPosition:b2Vec2FromCC(0, 250)];
    [launcher setPhysicsPosition:b2Vec2FromCC(60, 0)];
    
    [objectLayer setPosition:ccp(0, -cY)]; // move objectLayer
    [background setPosition:ccp(0,-cY*0.6)]; // move main background slower than foreground
    
    // Ball bounces to a stop above the particle emitter
    
    float base = 0.0f;
    float targetHeight = 120.0f;
    float distanceAboveGround = mY - base;
    b2Vec2 ballVel = [ball linearVelocity];
    float   springConstant = 0.25f;
    
    // Determine whether SteamBot is directly above the emmitterDevice
    CGPoint  leftBoundry, rightBoundry; // left and right side of corridor
    leftBoundry = ccp(125.0f, 0);
    rightBoundry = ccp(200.0f, 0);
    bool isInCorridor; // Is the SteamBot in the corridor (x cood only)
    
    // Where is the SteamBot
    b2Vec2 ballPos = [ball physicsPosition];
    CGPoint ccBallPos = ccpMult(CGPointMake(ballPos.x, ballPos.y), PTM_RATIO); // Convert to CGPoint
    
    if (ccBallPos.x > leftBoundry.x && ccBallPos.x < rightBoundry.x) {
        isInCorridor = true;
    }else isInCorridor = false;
    
    
    //dont do anything if too far above ground or not in the correct level or not in the corridor
    // All three must be true
    if ( distanceAboveGround < targetHeight && isInCorridor) {
        
        //replace distanceAboveGround with the 'look ahead' distance
        //this will look ahead 0.25 seconds - longer gives more 'damping'
        // Higher numbers reduce 'bounce' of ball
        distanceAboveGround += 2.5f * ballVel.y;
        
        float distanceAwayFromTargetHeight = targetHeight - distanceAboveGround;
        [ball applyForce:b2Vec2(0,springConstant * distanceAwayFromTargetHeight) point:[ball worldCenter]];
        
        //negate gravity
        [ball applyForce:[ball mass] * -world->GetGravity() point:[ball worldCenter]];
        
        targetHeight++;
        
        // Increase pressure on ball
        currPressure += 0.2f;
        
        // Shake SteamBot after pressure hits
        if(currPressure > 115)
        {

            [ball setMood:ANGRY];
            
            /* if (playSoundOnce) {
                [[SimpleAudioEngine sharedEngine] playEffect:@"SteamBuildup.caf" pitch:1.0 pan:-1.0 gain:1.0];
                
                playSoundOnce = false;
            } */
            
             if (shakeDelay > SHAKE) {

                shakeDelay = 0;
                // Get current position of steamBot and convert to CGPoints
                b2Vec2 ballP = [ball physicsPosition];
                CGPoint ballC = ccpMult(CGPointMake(ballP.x, ballP.y), PTM_RATIO);
                
                // Shake distance
                float shakeOffset = currPressure/50;
                
                if(toggle)
                {
                    [ball setPhysicsPosition:b2Vec2FromCC(ballC.x + shakeOffset, ballC.y)];
                }
                else
                {
                     [ball setPhysicsPosition:b2Vec2FromCC(ballC.x - shakeOffset, ballC.y)];
                }
                toggle = !toggle;
            } else ++shakeDelay;
        }
    }
    
    // Move pointer with pressure
    pressureBarPointer.position = ccp(POINTERX + currPressure, 470);
    if (pressureBarPointer.position.x > POINTERX_MAX) {
        pressureBarPointer.position = ccp(POINTERX_MAX, 470);
    }
    if (pulseOn) {
        [ball applyLinearImpulse:b2Vec2(0,[ball mass]*JUMP_IMPULSE) point:[ball worldCenter]];
    }
}

// This method called whenever screen is touched
// Determines location of touch then calls selectSprite function

- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event {    

    CGPoint touchLocation = [touch locationInView:[touch view]];
    touchLocation = [[CCDirector sharedDirector] convertToGL:touchLocation];
    touchLocation = [self convertToNodeSpace:touchLocation];
    
    [self selectSpriteForTouch:touchLocation];

    return TRUE;    
}

-(void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{
    controlButton.position = ccp(60, 60);
    pulseOn = NO;
}

- (void)selectSpriteForTouch:(CGPoint)touchLocation {

        if(CGRectContainsPoint(controlButton.boundingBox,
                               touchLocation))
        {
            pulseOn = YES;
        }
}

- (void)ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event {
    CGPoint touchLocation = [self convertTouchToNodeSpace:touch];
    
    CGPoint oldTouchLocation = [touch previousLocationInView:touch.view];
    oldTouchLocation = [[CCDirector sharedDirector] convertToGL:oldTouchLocation];
    oldTouchLocation = [self convertToNodeSpace:oldTouchLocation];
    
    CGPoint translation = ccpSub(touchLocation, oldTouchLocation);
    [self spriteTranslation:translation];
}

- (void)spriteTranslation:(CGPoint)translation {

    CGPoint newPos = ccpAdd(controlButton.position, translation);
    controlButton.position = newPos;
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

-(void)bounceObject: (DynamicObject *) bouncingObject
{
    // Object bounces to a stop above specified point
    
    float mY = [bouncingObject physicsPosition].y * PTM_RATIO;
    
    float base = 0.0f;
    static float targetHeight;
    float distanceAboveGround = mY - base;
    
    if (justOnce) {
        targetHeight = mY - 100;
        justOnce = NO;
    }
    
    b2Vec2 ObVel = [bouncingObject linearVelocity];
    float   springConstant = 0.25f;
        
    //dont do anything if too far above ground
    // All three must be true
    if ( distanceAboveGround < targetHeight) {
        
        //replace distanceAboveGround with the 'look ahead' distance
        //this will look ahead 0.25 seconds - longer gives more 'damping'
        // Higher numbers reduce 'bounce' of ball
        distanceAboveGround += 2.5f * ObVel.y;
        
        float distanceAwayFromTargetHeight = targetHeight - distanceAboveGround;
        [bouncingObject applyForce:b2Vec2(0,springConstant * distanceAwayFromTargetHeight) point:[bouncingObject worldCenter]];
        
        //negate gravity
        [bouncingObject applyForce:[bouncingObject mass] * -world->GetGravity() point:[bouncingObject worldCenter]];
        
    }
}

@end
