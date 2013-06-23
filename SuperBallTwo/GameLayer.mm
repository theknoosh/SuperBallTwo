//
//  GameLayer.m
//  SuperBallTwo
//
//  Created by Darrell Payne on 5/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

// #define JUMP_IMPULSE 12.5f
#define JUMP_IMPULSE 24.0f
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
        rightPlatforms = [[NSMutableArray alloc] init];
        leftPlatforms = [[NSMutableArray alloc] init];
        
        float curHeight = 450.0f;
        
        // Array of left and right platforms (3 each)
        for (NSUInteger x=0; x<7; x++) {
            [rightPlatforms addObject:[[StaticObject alloc] initWithGameLayer:self andObjName:@"rightPlatform" andSpriteName:@"rightPlatform.png"]];
            [leftPlatforms addObject:[[StaticObject alloc] initWithGameLayer:self andObjName:@"leftPlatform" andSpriteName:@"leftPlatform.png"]];
            
            [[leftPlatforms objectAtIndex:x] setPhysicsPosition:b2Vec2FromCC(100.0f, curHeight)];
            [[rightPlatforms objectAtIndex:x] setPhysicsPosition:b2Vec2FromCC(250.0f, curHeight + 150.0f)];
            curHeight += 300.0f;
            
            [[leftPlatforms objectAtIndex:x]setActive:NO];
            [[rightPlatforms objectAtIndex:x]setActive:NO];
            
        }
        
        // Gothic Spinner
        spinner = [[StaticObject alloc] initWithGameLayer:self andObjName:@"spinner" andSpriteName:@"spinner.png"];
        [spinner setPhysicsPosition:b2Vec2FromCC(300.0f, 420.0f)];
        [spinner setActive:NO];
        
        emmitterDevice = [CCSprite spriteWithSpriteFrameName:@"newEmitter.png"];
        [objectLayer addChild:emmitterDevice z:25];
        [emmitterDevice setPosition:ccp(50, 370)]; // emitter is simple sprite
        
        controlButton = [CCSprite spriteWithSpriteFrameName:@"ControlButton.png"];
        [controlLayer addChild:controlButton z:25];
        [controlButton setPosition:ccp(60, 60)];
        
        controlButtonArrows = [CCSprite spriteWithSpriteFrameName:@"ControlButtonArrows.png"];
        [controlLayer addChild:controlButtonArrows z:24];
        [controlButtonArrows setPosition:ccp(60, 60)];
                
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
    
   /*
   double y = ((double)arc4random() / ARC4RANDOM_MAX) * 1.0f;
    // NSLog(@"Random number: %f",y-1);
    
    CGPoint pos = [triangle position];
    [triangle setPosition:ccp(pos.x + (y-.5), pos.y + (y-.5))];
    */
    
    /*
    
    // Do the countdown here
    if (doCountDown && ball.active == YES) {
        [launcher setToOpen];
        ++currCountdown;
        numbers[currNumber].scale += 0.001f;
        if (currCountdown<32) {
            numberOpacity += 4;
            if (numberOpacity>255) {
                numberOpacity = 255;
            }
        }else if (currCountdown>40){
            numberOpacity -= 4;
            if (numberOpacity<0) {
                numberOpacity = 0;
                currCountdown = 0;
                currNumber += 1;
                if (currNumber > 2) {
                    doCountDown = false;
                    currNumber = 2;
                    [ball applyLinearImpulse:b2Vec2(0,[ball mass]*JUMP_IMPULSE) point:[ball worldCenter]];

                }
            }
        }
        numbers[currNumber].opacity = numberOpacity;
    } */
    

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
                
        /*
        [objectLayer addChild:[spinner ccNode] z:25];
        [spinner setActive:YES];
        spinnerExists = YES;
        */
    }
    
    if (cY < 300.0f && modeLevel == 1) {
        cY = 300.0f;
     }
    static float gridPosition = 400;
    // static NSInteger curIndex = 0;
    
    // This section places random triangles
   /* if (mY > gridPosition + 100) {
        
        
        if (currentSpeed < 1 && wasNotDone) {
            
            
            for (NSUInteger x=0; x<7; x++) {
                [objectLayer addChild:[[rightPlatforms objectAtIndex:x]ccNode]z:25];
                [objectLayer addChild:[[leftPlatforms objectAtIndex:x]ccNode]z:25];
                [[leftPlatforms objectAtIndex:x]setActive:YES];
                [[rightPlatforms objectAtIndex:x]setActive:YES];
            }
            wasNotDone = NO;
            [triangleObjects addObject:[[StaticObject alloc] initWithGameLayer:self andObjName:@"triangle" andSpriteName:@"triangle.png"]];
            int xLoc = arc4random() % 3;
            [[triangleObjects objectAtIndex:curIndex] setPhysicsPosition:b2Vec2FromCC(((float) xLoc * 106) + 53, gridPosition)];
            [[triangleObjects objectAtIndex:curIndex]setActive:YES];
            [objectLayer addChild:[[triangleObjects objectAtIndex:curIndex] ccNode]z:25];
            curIndex++;
            gridPosition += 106.0f;
        }
    } */
    
    /*
    if (spinnerExists) {
        [spinner setAngle:angle];
        angle -= 0.01f;
        if (angle < -6.2831f) {
            angle = 0;
        }
    
    } */
    
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
        
        // wallJoint->SetMotorSpeed(-1.0f);
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
}

// This method called whenever screen is touched
- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event {    

    // [launcher setToOpen];
    CGPoint touchLocation = [touch locationInView:[touch view]];
    touchLocation = [[CCDirector sharedDirector] convertToGL:touchLocation];
    touchLocation = [self convertToNodeSpace:touchLocation];
    // b2Vec2 locationWorld = b2Vec2(touchLocation.x/PTM_RATIO, touchLocation.y/PTM_RATIO);
    
    [self selectSpriteForTouch:touchLocation];
    // [bridge setActive:YES];
    
    
   // [ball applyLinearImpulse:b2Vec2(0,[ball mass]*JUMP_IMPULSE) point:[ball worldCenter]];
    // [piston01 setActive:YES];
    // NSLog(@"Touch made");
            
   //  [self selectSpriteForTouch:touchLocation];
    return TRUE;    
}

- (void)selectSpriteForTouch:(CGPoint)touchLocation {

        if(CGRectContainsPoint(ball.ccNode.boundingBoxInPixels,
                               touchLocation))
        {
            [ball applyLinearImpulse:b2Vec2(0,[ball mass]*JUMP_IMPULSE) point:[ball worldCenter]];
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
