//
//  Ball.h
//  SuperBallTwo
//
//  Created by Darrell Payne on 5/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#pragma once

#import "CCLayer.h"
#import "cocos2d.h"
#import "GB2Sprite.h"


@class GameLayer;

@interface Ball : GB2Sprite
{
    GameLayer *gameLayer; // weak reference
    ccTime  animDelay; // control speed of animation
    ccTime  blinkDelay; // When to blink
    int     animPhase; // the current animation phase
    bool    blinkNow;  // when to blink
    bool    blinkOpen; // Close lids, then open lids
    bool    botHasChanged; // Indicates face change
    NSString    *botMood;
    NSString    *botAnim;
 
}

@property (readonly, nonatomic) bool inContact;

-(id) initWithGameLayer:(GameLayer*)gl;
-(void)setMood:(int)Mood;

@end
