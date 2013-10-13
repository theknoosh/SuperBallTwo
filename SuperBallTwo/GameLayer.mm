//
//  GameLayer.m
//  SuperBallTwo
//
//  Created by Darrell Payne on 5/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#define JUMP_IMPULSE 25.0f
// #define JUMP_IMPULSE 0.4f
#define WIDTH 320
#define HEIGHT 480
#define POINTERX 45
#define POINTERX_MAX 275
#define NORMAL 0
#define ANGRY 1
#define SHAKE 2
#define LDELAY 100
#define ARC4RANDOM_MAX      0x100000000

#import "GameLayer.h"
#import "GB2DebugDrawLayer.h"
#import "GB2Sprite.h"
#import "Ball.h"
#import "Launcher.h"
#import "Piston.h"
#import "DynamicObject.h"
#import "SimpleAudioEngine.h"


// Private iVars
@interface GameLayer()
{
    
}

@property (nonatomic,strong) CCSprite   *lightning;
@property (nonatomic, strong) CCAction *lightningAction;


@end


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
        ballInPlay = NO;
        
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
        [rightWall addEdgeFrom:b2Vec2FromCC(320, 323) to:b2Vec2FromCC(320, 20000)];
        
        /*
         // add floor
        GB2Node *theFloor = [[GB2Node alloc] initWithStaticBody:nil node:nil];
        [theFloor addEdgeFrom:b2Vec2FromCC(0, 0) to:b2Vec2FromCC(320, 0)];
         */
        
         // Setup object layer
        // Contains all active objects
    	objectLayer = [CCSpriteBatchNode batchNodeWithFile:@"sprites.pvr.ccz" capacity:150];
        [self addChild:objectLayer z:10];
        
        effectsLayer = [[CCLayer alloc]init];
        [self addChild:effectsLayer z:1];
        
        // Lose the lightning for now
        /* NSMutableArray *lightningAnimFrames = [NSMutableArray array];
        for (int i=0; i<=5; i++) {
            [lightningAnimFrames addObject:
             [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
              [NSString stringWithFormat:@"LightningAnim000%d.png",i]]];
        }
        
        CCAnimation *LightningAnim = [CCAnimation animationWithFrames:lightningAnimFrames delay:0.1f];
        
        self.lightning = [CCSprite spriteWithSpriteFrameName:@"LightningAnim0001.png"];
        self.lightning.position = ccp(160, 370);
        self.lightningAction = [CCRepeatForever actionWithAction:[CCAnimate actionWithAnimation:LightningAnim]];
        [self.lightning runAction:self.lightningAction];
        [objectLayer addChild:self.lightning];
        */
        
        // Setup control layer
        controlLayer = [CCSpriteBatchNode batchNodeWithFile:@"Controls.pvr.ccz" capacity:150];
        [self addChild:controlLayer z:10];
        
        /*leftDrain = [[StaticObject alloc]initWithGameLayer:self andObjName:@"leftDrain" andSpriteName:@"leftDrain.png"];
        [objectLayer addChild:[leftDrain ccNode]z:25];
        [leftDrain setPhysicsPosition:b2Vec2FromCC(0.0, 0.0)];
        [leftDrain setActive:YES];
        
        rightDrain = [[StaticObject alloc]initWithGameLayer:self andObjName:@"rightDrain" andSpriteName:@"rightDrain.png"];
        [objectLayer addChild:[rightDrain ccNode]z:25];
        [rightDrain setPhysicsPosition:b2Vec2FromCC(320.0, 0.0)];
        [rightDrain setActive:YES];*/
        
        roof = [[StaticObject alloc]initWithGameLayer:self andObjName:@"roof" andSpriteName:@"roof.png"];
        [objectLayer addChild:[roof ccNode]z:25];
        [roof setPhysicsPosition:b2Vec2FromCC(0.0, 2400.0)];
        [roof setActive:YES];
        
        // ********** Revolute Joint Definitions ***********
        
        leftPaddle = [CCSprite spriteWithSpriteFrameName:@"leftPaddle.png"];
        [objectLayer addChild:leftPaddle z:20];
        rightPaddle = [CCSprite spriteWithSpriteFrameName:@"rightPaddle.png"];
        [objectLayer addChild:rightPaddle z:20];
        leftDrain = [CCSprite spriteWithSpriteFrameName:@"leftDrain.png"];
        [objectLayer addChild:leftDrain z:25];
        rightDrain = [CCSprite spriteWithSpriteFrameName:@"rightDrain.png"];
        [objectLayer addChild:rightDrain z:25];
        
        b2BodyDef leftPaddleBodyDef;
        leftPaddleBodyDef.type = b2_dynamicBody;
        leftPaddleBodyDef.linearDamping = 1;
        leftPaddleBodyDef.angularDamping = 1;
        leftPaddleBodyDef.position.Set(80.0f/PTM_RATIO, 128.0f/PTM_RATIO);
        // leftPaddleBodyDef.userData = leftPaddle;
        
        leftPaddleBody = world->CreateBody(&leftPaddleBodyDef);
        
        // Load fixture from shape.plist file instead of creating it here
        [[GB2ShapeCache sharedShapeCache] addFixturesToBody:leftPaddleBody forShapeName:@"leftPaddle"];
        [leftPaddle setAnchorPoint:[[GB2ShapeCache sharedShapeCache]anchorPointForShape:@"leftPaddle"]];
        
        b2BodyDef rightPaddleBodyDef;
        rightPaddleBodyDef.type = b2_dynamicBody;
        rightPaddleBodyDef.linearDamping = 1;
        rightPaddleBodyDef.angularDamping = 1;
        rightPaddleBodyDef.position.Set(320.0f/PTM_RATIO, 128.0f/PTM_RATIO);
        // leftPaddleBodyDef.userData = leftPaddle;
        
        rightPaddleBody = world->CreateBody(&rightPaddleBodyDef);
        
        // Load fixture from shape.plist file instead of creating it here
        [[GB2ShapeCache sharedShapeCache] addFixturesToBody:rightPaddleBody forShapeName:@"rightPaddle"];
        [rightPaddle setAnchorPoint:[[GB2ShapeCache sharedShapeCache]anchorPointForShape:@"rightPaddle"]];
        
        b2BodyDef leftDrainBodyDef;
        leftDrainBodyDef.type = b2_staticBody;
        leftDrainBodyDef.linearDamping = 1;
        leftDrainBodyDef.angularDamping = 1;

        leftDrainBodyDef.position.Set(80.0f/PTM_RATIO, 128.0f/PTM_RATIO);
        // leftPaddleBodyDef.userData = leftPaddle;
        
        leftDrainBody = world->CreateBody(&leftDrainBodyDef);
        
        // Load fixture from shape.plist file instead of creating it here
        [[GB2ShapeCache sharedShapeCache] addFixturesToBody:leftDrainBody forShapeName:@"leftDrain"];
        [leftDrain setAnchorPoint:[[GB2ShapeCache sharedShapeCache]anchorPointForShape:@"leftDrain"]];
        
        b2BodyDef rightDrainBodyDef;
        rightDrainBodyDef.type = b2_staticBody;
        rightDrainBodyDef.linearDamping = 1;
        rightDrainBodyDef.angularDamping = 1;
        
        rightDrainBodyDef.position.Set(320.0f/PTM_RATIO, 128.0f/PTM_RATIO);
        // leftPaddleBodyDef.userData = leftPaddle;
        
        rightDrainBody = world->CreateBody(&rightDrainBodyDef);
    
        
        // Load fixture from shape.plist file instead of creating it here
        [[GB2ShapeCache sharedShapeCache] addFixturesToBody:rightDrainBody forShapeName:@"rightDrain"];
        [rightDrain setAnchorPoint:[[GB2ShapeCache sharedShapeCache]anchorPointForShape:@"rightDrain"]];
        
        
        
        // Define the joint to fix the wall to floor of bridge
        
        b2RevoluteJointDef  leftPaddelJointDef;
        leftPaddelJointDef.Initialize(leftPaddleBody, leftDrainBody, b2Vec2(80.0/PTM_RATIO,128.0f/PTM_RATIO));
        leftPaddelJointDef.enableMotor = true;
        leftPaddelJointDef.enableLimit = true;
        leftPaddelJointDef.collideConnected = false;
        leftPaddelJointDef.motorSpeed = 0;
        leftPaddelJointDef.lowerAngle = CC_DEGREES_TO_RADIANS(-75.0f);
        leftPaddelJointDef.upperAngle = CC_DEGREES_TO_RADIANS(0.0f);
        leftPaddelJointDef.maxMotorTorque = 200;
        leftPaddelJointDef.referenceAngle = -0;
        leftPaddleJoint = (b2RevoluteJoint *)world->CreateJoint(&leftPaddelJointDef);
        
        b2RevoluteJointDef  rightPaddelJointDef;
        rightPaddelJointDef.Initialize(rightPaddleBody, rightDrainBody, b2Vec2(320.0/PTM_RATIO,128.0f/PTM_RATIO));
        rightPaddelJointDef.enableMotor = true;
        rightPaddelJointDef.enableLimit = true;
        rightPaddelJointDef.collideConnected = false;
        rightPaddelJointDef.motorSpeed = 0;
        rightPaddelJointDef.lowerAngle = CC_DEGREES_TO_RADIANS(0.0f);
        rightPaddelJointDef.upperAngle = CC_DEGREES_TO_RADIANS(75.0f);
        rightPaddelJointDef.maxMotorTorque = 4800;
        rightPaddelJointDef.referenceAngle = 0;
        rightPaddleJoint = (b2RevoluteJoint *)world->CreateJoint(&rightPaddelJointDef);
        
        // ********** End Revolute Joint *******************
        
        float curHeight = 450.0f;
        
        emmitterDevice = [CCSprite spriteWithSpriteFrameName:@"newEmitter.png"];
        [objectLayer addChild:emmitterDevice z:25];
        [emmitterDevice setPosition:ccp(40, 248)]; // emitter is simple sprite
        
        controlButton = [CCSprite spriteWithSpriteFrameName:@"ControlButton.png"];
        [controlLayer addChild:controlButton z:25];
        [controlButton setPosition:ccp(40, 60)];
        
        /* controlButtonArrows = [CCSprite spriteWithSpriteFrameName:@"ControlButtonArrows.png"];
        [controlLayer addChild:controlButtonArrows z:24];
        [controlButtonArrows setPosition:ccp(60, 60)];
         */
        
        /* // Set off particles
        particles = [CCParticleSystemQuad particleWithFile:@"ParticleTest.plist"];
        [self addChild:particles z:22];
        particles.scale = .6;
        particles.position = ccp(160,200);
         */
        
        // Fire for device
        fireEffect = [CCParticleSystemQuad particleWithFile:@"fire.plist"];
        [effectsLayer addChild:fireEffect z:1];
        fireEffect.position = ccp(35, 250);
        
        //particles from pods
        podParticles = [CCParticleSystemQuad particleWithFile:@"ParticleEmitter.plist"];
        podParticles.scale = .75;
        [podParticles setPosition:ccp(160,80)];
        // [self addChild:podParticles z:22];
        
        // Setup Ball
        ball = [[[Ball alloc] initWithGameLayer:self] autorelease];
        [objectLayer addChild:[ball ccNode] z:2];
        [ball setPhysicsPosition:b2Vec2FromCC(45,500)];
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
        /* if (particles != NULL) {
            [self removeChild:particles cleanup:YES];
        }*/
        [ball setVisible:YES];
        [ball setActive:YES];
    }
    
    
    //Track CCSprites to B2Body objects
    leftDrain.position = CGPointMake(leftDrainBody->GetPosition().x * PTM_RATIO, leftDrainBody->GetPosition().y * PTM_RATIO);
    leftDrain.rotation = -1 * CC_RADIANS_TO_DEGREES(leftDrainBody->GetAngle());
    
    leftPaddle.position = CGPointMake(leftPaddleBody->GetPosition().x * PTM_RATIO, leftPaddleBody->GetPosition().y * PTM_RATIO);
    leftPaddle.rotation = -1 * CC_RADIANS_TO_DEGREES(leftPaddleBody->GetAngle());
    
    rightDrain.position = CGPointMake(rightDrainBody->GetPosition().x * PTM_RATIO, rightDrainBody->GetPosition().y * PTM_RATIO);
    rightDrain.rotation = -1 * CC_RADIANS_TO_DEGREES(rightDrainBody->GetAngle());
    
    rightPaddle.position = CGPointMake(rightPaddleBody->GetPosition().x * PTM_RATIO, rightPaddleBody->GetPosition().y * PTM_RATIO);
    rightPaddle.rotation = -1 * CC_RADIANS_TO_DEGREES(rightPaddleBody->GetAngle());
    
    // TODO: Cancel gravity of flippers (general code below)
    // [ball applyForce:[ball mass]* world->GetGravity() point:[ball worldCenter]]; -- cancel gravity
    
    // Speed of the ball, when it gets below 1, it is at
    // top of arc
    
    b2Vec2 currentVelocity = [ball linearVelocity];
    float currentSpeed = currentVelocity.Length();
    
    
    // Track position of ball in relation to screen
    float mY = [ball physicsPosition].y * PTM_RATIO;
    const float ballHeight = 50.0f;
    const float screenHeight = 480.0f;
    float cY;
    
    // Ball falls off bottom of screen - reset game
    if (mY < -25) {
        ballInPlay = FALSE;
        [ball setPhysicsPosition:b2Vec2FromCC(45,500)];
        mY = [ball physicsPosition].y * PTM_RATIO;
        ball.linearVelocity = b2Vec2FromCC(0.0, 0.0);
        [ball setVisible:NO];
        [ball setActive:NO];
        runOnce = false;
        curTime = 0.0;
    }   
        
    // Follow ball on screen
    if (ballInPlay) {
       
        cY = mY - ballHeight - screenHeight/2 - (screenHeight/4);
        if(cY < 0)
        {
            cY = 0;
        }
        
    [objectLayer setPosition:ccp(0, -cY)]; // move objectLayer
    [effectsLayer setPosition:ccp(0, -cY)]; // move effectsLayer
    [background setPosition:ccp(0,-cY*0.6)]; // move main background slower than foreground

    }
    
    // Ball bounces to a stop above the particle emitter
    
    corridor col1;
    col1.base = 200.0f;
    col1.targetheight = 120.0f;
    col1.springConstant = 0.25f;
    col1.left = 0.0f;
    col1.right = 75.0f;
    col1.lookahead = 2.5f; // 2.5f is the default value!! .25 very bouncy.
    
    float distanceAboveGround = mY - col1.base;
    
    float base = col1.base;
    
    // Determine ball position
    b2Vec2  ballPos = [ball physicsPosition];
    CGPoint ccBallPos = ccpMult(CGPointMake(ballPos.x, ballPos.y), PTM_RATIO); // Convert to cgpoint
    
    // Is the ball within the left and right boundaries
    if (ccBallPos.x > col1.left && ccBallPos.x < col1.right) {
        //dont do anything if too far above ground
        if ( distanceAboveGround < col1.targetheight) {
            
            [self bounceObject:col1];
            
            currPressure += 0.2f;
            
            // Shake SteamBot after pressure hits
            if(currPressure > 115)
            {
                
                [ball setMood:ANGRY];
                
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
            } else [ball setMood:NORMAL];
        }
        
    }

    
    /*
    
    // Move pointer with pressure
    // TODO: Bar should move up AND down
    pressureBarPointer.position = ccp(POINTERX + currPressure, 470);
    if (pressureBarPointer.position.x > POINTERX_MAX) {
        pressureBarPointer.position = ccp(POINTERX_MAX, 470);
    }
    
     // Turn on and off lightning
    if (lightningDelay > LDELAY) {
        [self.lightning setVisible:NO];
        lightningDelay++;
        if (lightningDelay > (2*LDELAY)) {
            lightningDelay = 0;
        }
    }else {
        [self.lightning setVisible:YES];
        lightningDelay++;
    }
    
    if (pulseOn || pulseSide) {
        [ball applyLinearImpulse:b2Vec2([ball mass] * horizPulse,[ball mass]*vertPulse)point:[ball worldCenter]];
        // NSLog(@"Horizontal pulse = %f",horizPulse);
    }
     */
}

// This method called whenever screen is touched
// Determines location of touch then calls selectSprite function

- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event {    

    CGPoint touchLocation = [touch locationInView:[touch view]];
    touchLocation = [[CCDirector sharedDirector] convertToGL:touchLocation];
    touchLocation = [self convertToNodeSpace:touchLocation];
    
    [ball setMood:NORMAL];
    
    [self selectSpriteForTouch:touchLocation];

    return TRUE;    
}

-(void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{
    // position = ccp(60, 60);
    pulseOn = NO;
    pulseSide = NO;
    vertPulse = 0.0;
    horizPulse = 0.0;
    leftPaddleJoint->SetMotorSpeed(20.0f);
    rightPaddleJoint->SetMotorSpeed(-20.0f);
}

- (void)selectSpriteForTouch:(CGPoint)touchLocation {

        if(CGRectContainsPoint(controlButton.boundingBox,
                               touchLocation))
        {
            float bImpulse = currPressure * .4;
            [ball applyLinearImpulse:b2Vec2(0,[ball mass]*bImpulse)point:[ball worldCenter]];
            currPressure = 0.0;
        }else {
            leftPaddleJoint->SetMotorSpeed(-20.0f);
            rightPaddleJoint->SetMotorSpeed(20.0f);
        }
}

/*
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
    CGPoint pos = controlButton.position;
    if (pos.x > 80.0) {
        pos.x = 80.0;
    }else if (pos.x < 40){
        pos.x = 40;
    }
    if(pos.y > 80.0){
        pos.y = 80.0;
    }else {
        if (pos.y < 60.0) {
            pos.y = 60.0;
        }
    }
    controlButton.position = pos;
    
    
    // Set ball to apply vertical force for upward motion
    if (pos.y>70) {
        pulseOn = YES;
        vertPulse = 0.4;
    }else {
        pulseOn = NO;
        vertPulse = 0.0;
    }
    
    // Set ball for left right motion
    if (pos.x > 70) {
        pulseSide = YES;
        horizPulse = 0.2;
    }else if (pos.x < 50){
        pulseSide = YES;
        horizPulse = -0.2;
    }else{
        pulseSide = NO;
        horizPulse = 0;
    }

}

*/

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

-(void)bounceObject: (corridor) position
{
    // Object bounces to a stop above specified point
    
    float mY = [ball physicsPosition].y * PTM_RATIO;
    float distanceAboveGround = mY - position.base;
   
    float base = position.base;
    
    // Determine ball position
    // b2Vec2  ballPos = [ball physicsPosition];
    // CGPoint ccBallPos = ccpMult(CGPointMake(ballPos.x, ballPos.y), PTM_RATIO); // Convert to cgpoint
    
    b2Vec2 ObVel = [ball linearVelocity];
    float   springConstant = position.springConstant;
        
    ballInPlay = true;
    
    //replace distanceAboveGround with the 'look ahead' distance
    //this will look ahead 0.25 seconds - longer gives more 'damping'
    // Higher numbers reduce 'bounce' of ball
    distanceAboveGround += position.lookahead * ObVel.y;
        
    float distanceAwayFromTargetHeight = position.targetheight - distanceAboveGround;
    [ball applyForce:b2Vec2(0,springConstant * distanceAwayFromTargetHeight) point:[ball worldCenter]];
        
    //negate gravity
    [ball applyForce:[ball mass] * -world->GetGravity() point:[ball worldCenter]];
        
}

@end
