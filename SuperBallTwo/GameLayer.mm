//
//  GameLayer.m
//  SuperBallTwo
//
//  Created by Darrell Payne on 5/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

// #define JUMP_IMPULSE 12.5f
#define JUMP_IMPULSE 12.0f
#define WIDTH 320
#define HEIGHT 480
#define POINTERX 45
#define POINTERX_MAX 275
#define SHAKE 2

#import "GameLayer.h"
#import "GB2DebugDrawLayer.h"
#import "GB2Sprite.h"
#import "Ball.h"
#import "Launcher.h"
#import "Piston.h"
#import "DynamicObject.h"

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
        
        
       /* // Define the gravity vector.
		b2Vec2 gravity;
		gravity.Set(0.0f, -10.0f);
        
        // Do we want to let bodies sleep?
		// This will speed up the physics simulation
		bool doSleep = true;
        
        // Construct a world object, which will hold and simulate the rigid bodies.
		world = new b2World(gravity, doSleep); */
        
        
        world = [[GB2Engine sharedInstance]world];
        
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
        
        // Load physics object Launcher
        launcher = [[[Launcher alloc] initWithGameLayer:self] autorelease];
        [self addChild:[launcher ccNode] z:25];
        [launcher setPhysicsPosition:b2Vec2FromCC(60, 0)];
        
        
        // Setup for the bridge
        bridge = [[StaticObject alloc]initWithGameLayer:self andObjName:@"brokenBridge"andSpriteName:@"brokenBridge.png"];
        [self addChild:[bridge ccNode] z:25];
        // [bridge setPhysicsPosition:b2Vec2FromCC(160, 250)];
        [bridge setActive:NO];
                
        bigBumper = [[StaticObject alloc]initWithGameLayer:self andObjName:@"bigBumper" andSpriteName:@"bigBumper.png"];
        [self addChild:[bigBumper ccNode]z:20];
        
        
        // **** Definition for the RevoluteJoint *********
        
        // ************ Definition for the wall ************
        // Need two b2Bodies - this is the first one
        

        smallBumper = [CCSprite spriteWithSpriteFrameName:@"smallBumper.png"];
        [self addChild:smallBumper z:25];
        
        b2BodyDef wallBodyDef;
        wallBodyDef.type = b2_dynamicBody;
        wallBodyDef.linearDamping = 1;
        wallBodyDef.angularDamping = 1;
        wallBodyDef.position.Set(75.0f/PTM_RATIO, 370.0f/PTM_RATIO);
        // wallBodyDef.userData = smallBumper;
        wallBody = world->CreateBody(&wallBodyDef);
                
        // Load fixture from shape.plist file instead of creating it here
        [[GB2ShapeCache sharedShapeCache] addFixturesToBody:wallBody forShapeName:@"smallBumper"];
        [smallBumper setAnchorPoint:[[GB2ShapeCache sharedShapeCache]anchorPointForShape:@"smallBumper"]];
        
        // ********** End Definition of Wall **************
        
        // ********** Definition for the emitter **********
        // This is the 2nd of two b2Bodies
        
       
        emmitterDevice = [CCSprite spriteWithSpriteFrameName:@"newEmitter.png"];
        [self addChild:emmitterDevice z:25];
        
        b2BodyDef emitterDef;
        emitterDef.type = b2_staticBody;
        emitterDef.linearDamping = 1;
        emitterDef.angularDamping = 1;
        emitterDef.position.Set(0, 365.0f/PTM_RATIO);
        emitterDef.angle = 0;
        // emitterDef.userData = emmitterDevice;
        baseBody = world->CreateBody(&emitterDef);
                
        // Load fixture for baseBody
        [[GB2ShapeCache sharedShapeCache] addFixturesToBody:baseBody forShapeName:@"newEmitter"];
        [emmitterDevice setAnchorPoint:[[GB2ShapeCache sharedShapeCache] anchorPointForShape:@"newEmitter"]];
       
        
        // *********** End Definition of the emitter ******
        
        // Define the joint to fix the wall to floor of bridge
        
        b2RevoluteJointDef  wallJointDef;
        wallJointDef.Initialize(wallBody, baseBody, b2Vec2(75.0/PTM_RATIO,390.0f/PTM_RATIO));
        wallJointDef.enableMotor = true;
        wallJointDef.enableLimit = true;
        wallJointDef.motorSpeed = 0;
        wallJointDef.lowerAngle = CC_DEGREES_TO_RADIANS(1.65f);
        wallJointDef.upperAngle = CC_DEGREES_TO_RADIANS(20);
        wallJointDef.maxMotorTorque = 50;
        wallJoint = (b2RevoluteJoint *)world->CreateJoint(&wallJointDef);
        
        // ***** END TEST *******


        pressureBar = [CCSprite spriteWithSpriteFrameName:@"PressureBar.png"];
        
        [self addChild:pressureBar z:200];
        pressureBar.position = ccp(160,460);
        
        pressureBarPointer = [CCSprite spriteWithSpriteFrameName:@"PressureBarPointer.png"];
        [self addChild:pressureBarPointer z:205];
        pressureBarPointer.position = ccp(POINTERX, 470);
        
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
        [[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:YES];
        
        runOnce = false;
        doCountDown = true;
        currNumber = 0; // Start countdown with numberThree;
        
        modeLevel = 0; // initial level
        currPressure = 0.0f; // initial pressure
        toggle = true; // Initial toggle
        shakeDelay = 0;
        
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
    }
    
    
    // Camera follows ball
    float mY = [ball physicsPosition].y * PTM_RATIO;
    const float ballHeight = 50.0f;
    const float screenHeight = 480.0f;
    // float cY = mY - ballHeight - screenHeight/2.0f;
    float cY = mY -ballHeight - screenHeight/2;
    if(cY < 0)
    {
        cY = 0;
    }
    
    // Lock the bridge into position and start emitter
    if (cY > 300.0f && modeLevel == 0)
    {
        modeLevel = 1;
        [self addChild:podParticles z:22];
        // [bridge setActive:YES];
        wallJoint->SetMotorSpeed(1.0f);
    }
    
    if (cY < 300.0f && modeLevel == 1) {
        cY = 300.0f;
     }
    
    /* if(cY > 600.0f && modeLevel == 1){
        modeLevel = 2;
        cY = 600.0f;
    }
    
    if (modeLevel == 2) {
        cY = 600.0f;
    } */
    
    // Do some parallax scrolling
    [launcher setPhysicsPosition:b2Vec2FromCC(60, -cY)];
    [bridge setPhysicsPosition:b2Vec2FromCC(0, 250-cY)];
    // [emmitterDevice setPhysicsPosition:b2Vec2FromCC(50, 360-cY)];
    [podParticles setPosition:ccp(32,381-cY)];
    [bigBumper setPhysicsPosition:b2Vec2FromCC(75, 600-cY)];
    
    wallBody->SetTransform(b2Vec2FromCC(75, 355-cY),wallBody->GetAngle());
    baseBody->SetTransform(b2Vec2FromCC(0, 350.0f-cY), baseBody->GetAngle());
    
    //         wallJointDef.Initialize(wallBody, baseBody, b2Vec2(75.0/PTM_RATIO,340.0f/PTM_RATIO));
    
    [background setPosition:ccp(0,-cY*0.6)]; // move main background slower than foreground
    
    smallBumper.position = CGPointMake(wallBody->GetPosition().x * PTM_RATIO, wallBody->GetPosition().y * PTM_RATIO);
    smallBumper.rotation = -1 * CC_RADIANS_TO_DEGREES(wallBody->GetAngle());
    
    emmitterDevice.position = CGPointMake(baseBody->GetPosition().x * PTM_RATIO, baseBody->GetPosition().y * PTM_RATIO);
    emmitterDevice.rotation = -1 * CC_RADIANS_TO_DEGREES(baseBody->GetAngle());
    
    // Ball bounces to a stop above the particle emitter
    
    float base = 100.0f;
    float targetHeight = 110.0f;
    float distanceAboveGround = mY - base;
    b2Vec2 ballVel = [ball linearVelocity];
    float   springConstant = 0.25f;
    
    // Determine whether SteamBot is directly above the emmitterDevice
    CGPoint  leftBoundry, rightBoundry; // left and right side of corridor
    leftBoundry = ccp(0, 0);
    rightBoundry = ccp(75.0f, 0);
    bool isInCorridor; // Is the SteamBot in the corridor (x cood only)
    
    // Where is the SteamBot
    b2Vec2 ballPos = [ball physicsPosition];
    CGPoint ccBallPos = ccpMult(CGPointMake(ballPos.x, ballPos.y), PTM_RATIO); // Convert to CGPoint
    
    if (ccBallPos.x > leftBoundry.x && ccBallPos.x < rightBoundry.x) {
        isInCorridor = true;
    }else isInCorridor = false;
    
    
    //dont do anything if too far above ground or not in the correct level or not in the corridor
    // All three must be true
    if ( distanceAboveGround < targetHeight && modeLevel == 1 && isInCorridor) {
        
        wallJoint->SetMotorSpeed(-1.0f);
        //replace distanceAboveGround with the 'look ahead' distance
        //this will look ahead 0.25 seconds - longer gives more 'damping'
        // Higher numbers reduce 'bounce' of ball
        distanceAboveGround += 2.5f * ballVel.y;
        
        float distanceAwayFromTargetHeight = targetHeight - distanceAboveGround;
        [ball applyForce:b2Vec2(0,springConstant * distanceAwayFromTargetHeight) point:[ball worldCenter]];
        
        //negate gravity
        [ball applyForce:[ball mass] * -world->GetGravity() point:[ball worldCenter]];
        
        // Increase pressure on ball
        currPressure += 0.2f;
        
        // Shake SteamBot after pressure hits
        if(currPressure > 115)
        {
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

        if (CGRectContainsPoint(pistonAnimation.ccNode.boundingBoxInPixels, touchLocation))
        {
            if (![pistonAnimation isOpen]) {
                [pistonAnimation openPiston];
                [pistonAnimation setActive:YES];
            }else{
                [pistonAnimation closePiston];
                [pistonAnimation setActive:NO];
            }
            
        }
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

@end
