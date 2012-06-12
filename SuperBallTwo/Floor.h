
#pragma once

//
//  Floor.h
//  SuperBallTwo
//
//  Created by Darrell Payne on 5/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "cocos2d.h"
#import "GB2Sprite.h"

@class GameLayer;

@interface Floor : GB2Sprite
{
    GameLayer *gameLayer; // weak reference
    
}

-(id) initWithGameLayer:(GameLayer*)gl;

@end
