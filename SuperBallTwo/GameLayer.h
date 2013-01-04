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
    StaticObject        *bigBumper;
    CCSprite            *numbers[3];
    CCSprite            *pressureBar;
    CCSprite            *pressureBarPointer;
    CCSprite            *smallBumper;
    CCSprite            *emmitterDevice;
   
    // ****** Revolute Joint *******
    
    b2Body              *wallBody;
    b2Body              *baseBody;
    b2Fixture           *wallFixture;
    b2Fixture           *baseFixture;
    b2RevoluteJoint     *wallJoint;
    
    // ****** End Revolute Joint *********
    
    bool                runOnce;
    bool                doCountDown;
    bool                toggle;
    bool                playSoundOnce;
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



@end

