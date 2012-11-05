//
//  StaticObject.m
//  SuperBallTwo
//
//  Created by Darrell Payne on 5/23/12.
//  Copyright (c) 2012 Santuary of Darkness All rights reserved.
//

#import "StaticObject.h"
#import "GameLayer.h"

@implementation StaticObject

-(id) initWithGameLayer:(GameLayer*)gl andObjName:(NSString *)objName andSpriteName:(NSString *)spriteName;
{
    self = [super initWithStaticBody:objName
                     spriteFrameName:spriteName];
    
    if(self)
    {
        // [self setFixedRotation:true];
        
        [self setBullet:YES];
        
        gameLayer = gl;
    }
    return self;
}

@end
