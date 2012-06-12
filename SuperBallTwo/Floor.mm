//
//  Floor.m
//  SuperBallTwo
//
//  Created by Darrell Payne on 5/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Floor.h"
#import "GameLayer.h"

@implementation Floor

-(id)initWithGameLayer:(GameLayer*)gl;
{
    self = [super initWithStaticBody:@"grassfront"
                      spriteFrameName:@"grassfront.png"];
    
    if(self)
    {
        // [self setFixedRotation:true];
        
        [self setBullet:YES];
        
        gameLayer = gl;
    }
    return self;
}

@end
