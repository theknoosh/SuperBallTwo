
#pragma once

//
//  StaticObject.h
//  SuperBallTwo
//
//  Created by Darrell Payne on 5/23/12.
//  Copyright (c) 2012 Sancturay of Darkness All rights reserved.
//

#import "cocos2d.h"
#import "GB2Sprite.h"

@class GameLayer;

@interface StaticObject : GB2Sprite
{
    GameLayer *gameLayer; // weak reference
    
}

-(id) initWithGameLayer:(GameLayer*)gl andObjName:(NSString *)objName andSpriteName:(NSString *)spriteName;

@end
