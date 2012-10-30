//
//  GameLayer.h
//  SuperBallTwo
//
//  Created by Darrell Payne on 5/14/12.
//  Copyright (c) 2012 DarrellPayne Inc. All rights reserved.
//

#import "CCLayer.h"
#import "Floor.h"

// When you import this file, you import all the cocos2d classes
#import "cocos2d.h"
#import "Box2D.h"

@class Ball;
@class Rock;
@class Launcher;

@interface GameLayer : CCLayer
{
    CCSprite            *background;            // weak reference
    // CCSprite            *floorBackground;       // weak reference
    Ball                *ball;
    Rock                *rockSprite;
    Launcher            *launcher;
    CCSprite            *bridge;
    CCSprite            *numbers[3];
    bool                runOnce;
    bool                doCountDown;
    int                 numberOpacity;
    int                 currCountdown;
    int                 currNumber;
    
    float               curTime;
    int                 modeLevel;
    
    CCParticleSystemQuad    *particles;
    
    // CCSpriteBatchNode   *objectLayer;           // weak reference
}

// returns a CCScene that contains the GameLayer as the only child
+(CCScene *) scene;

@end

