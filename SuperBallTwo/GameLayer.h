//
//  GameLayer.h
//  SuperBallTwo
//
//  Created by Darrell Payne on 5/14/12.
//  Copyright (c) 2012 DarrellPayne Inc. All rights reserved.
//

#import "CCLayer.h"

// When you import this file, you import all the cocos2d classes
#import "cocos2d.h"
#import "Box2D.h"
#import "StaticObject.h"

// info on where to bounce ball
typedef struct {
    float base;
    float targetheight;
    float springConstant;
    float left;
    float right;
    float lookahead; // increases or decreases bounce
    
}corridor;

@class Ball;
@class Launcher;
@class Piston;
@class DynamicObject;

@interface GameLayer : CCLayer
{
    CCSprite            *background;            // weak reference
    Ball                *ball;
    Launcher            *launcher;
    Piston              *pistonAnimation;
    StaticObject        *rightPiston;
    StaticObject        *bridge;
    CCSprite            *leftDrain;
    CCSprite            *rightDrain;
    StaticObject        *roof;
    CCSprite            *leftPaddle;
    CCSprite            *rightPaddle;
    CCSprite            *pressureBar;
    CCSprite            *pressureBarPointer;
    CCSprite            *emmitterDevice;
    CCSprite            *controlButton;
    float               angle;
    
    CCSpriteBatchNode   *objectLayer;  // Holds all active game objects
    CCSpriteBatchNode   *controlLayer; // Holds all HUD/control objects
    CCLayer             *effectsLayer;
    
    bool                runOnce;
    bool                doCountDown;
    bool                toggle;
    bool                playSoundOnce;
    bool                justOnce;
    bool                spinnerExists;
    bool                wasNotDone;
    bool                pulseOn;
    bool                pulseSide;
    bool                ballInPlay;
    bool                inThePipe;
    int                 numberOpacity;
    int                 currCountdown;
    int                 currNumber;
    int                 shakeDelay;
    int                 lightningDelay;
    
    float               curTime;
    float               floor;
    float               currPressure;
    int                 modeLevel;
    b2World             *world;
    float               vertPulse,horizPulse;
    
    // ****** Revolute Joint *******
    
    b2Body              *leftPaddleBody;
    b2Body              *rightPaddleBody;
    b2Body              *leftDrainBody;
    b2Body              *rightDrainBody;
    b2Fixture           *leftPaddleFixture;
    b2Fixture           *rightPaddleFixture;
    b2Fixture           *leftDrainFixture;
    b2Fixture           *rightDrainFixture;
    
    b2RevoluteJoint     *leftPaddleJoint;
    b2RevoluteJoint     *rightPaddleJoint;
    
    // ****** End Revolute Joint *********
    
    CCParticleSystemQuad    *particles;
    CCParticleSystemQuad    *podParticles;
    CCParticleSystemQuad    *fireEffect;
    
    // CCSpriteBatchNode   *objectLayer;           // weak reference
}

// returns a CCScene that contains the GameLayer as the only child
+(CCScene *) scene;

// Bounces objects on screen
-(void)bounceObject: (corridor) position;
// -(void)spriteTranslation:(CGPoint)translation;


@end

