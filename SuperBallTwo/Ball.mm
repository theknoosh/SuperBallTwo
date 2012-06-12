//
//  Ball.m
//  SuperBallTwo
//
//  Created by Darrell Payne on 5/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//


#import "Ball.h"
#import "GameLayer.h"


@implementation Ball

-(id)initWithGameLayer:(GameLayer*)gl;
{
    self = [super initWithDynamicBody:@"Ball"
                      spriteFrameName:@"Ball.png"];
    
    if(self)
    {
        // [self setFixedRotation:true];
        
        [self setBullet:YES];
        
        gameLayer = gl;
    }
    return self;
}

@end
