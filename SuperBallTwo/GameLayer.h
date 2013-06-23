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
    CCSprite            *numbers[3];
    CCSprite            *pressureBar;
    CCSprite            *pressureBarPointer;
    CCSprite            *emmitterDevice;
    CCSprite            *controlButton;
    CCSprite            *controlButtonArrows;
    StaticObject        *spinner;
    float               angle;
    NSMutableArray      *triangleObjects;
    NSMutableArray      *rightPlatforms;
    NSMutableArray      *leftPlatforms;
    
    CCSpriteBatchNode   *objectLayer;  // Holds all active game objects
    CCSpriteBatchNode   *controlLayer; // Holds all HUD/control objects
    
    bool                runOnce;
    bool                doCountDown;
    bool                toggle;
    bool                playSoundOnce;
    bool                justOnce;
    bool                spinnerExists;
    bool                wasNotDone;
    int                 numberOpacity;
    int                 currCountdown;
    int                 currNumber;
    int                 shakeDelay;
    
    float               curTime;
    float               floor;
    float               currPressure;
    int                 modeLevel;
    b2World             *world;
    
    CCParticleSystemQuad    *particles;
    CCParticleSystemQuad    *podParticles;
    
    // CCSpriteBatchNode   *objectLayer;           // weak reference
}

// returns a CCScene that contains the GameLayer as the only child
+(CCScene *) scene;

// Bounces objects on screen
-(void)bounceObject: (DynamicObject *) bouncingObject;


@end

