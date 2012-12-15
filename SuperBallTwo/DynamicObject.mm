//
//  DynamicObject.m
//  SteamBot
//
//  Created by DPayne on 12/5/12.
//
//

#import "DynamicObject.h"
#import "GameLayer.h"

@implementation DynamicObject

-(id) initWithGameLayer:(GameLayer*)gl andObjName:(NSString *)objName andSpriteName:(NSString *)spriteName
{
    
    self = [super initWithDynamicBody:objName spriteFrameName:spriteName];
    
    if(self)
    {
        [self setBullet:YES];
        
        gameLayer = gl;
    }
    return self;
}

@end
