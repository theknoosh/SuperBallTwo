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
}

-(id) initWithGameLayer:(GameLayer*)gl;

@end
