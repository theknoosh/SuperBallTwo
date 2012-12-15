//
//  DynamicObject.h
//  SteamBot
//
//  Created by DPayne on 12/5/12.
//
//

#pragma once

#import "CCLayer.h"
#import "cocos2d.h"
#import "GB2Sprite.h"


@class GameLayer;

@interface DynamicObject : GB2Sprite

{
    GameLayer *gameLayer; // weak reference
    
}

-(id) initWithGameLayer:(GameLayer*)gl andObjName:(NSString *)objName andSpriteName:(NSString *)spriteName;


@end
