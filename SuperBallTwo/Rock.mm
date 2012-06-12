//
//  Rock.m
//  SuperBallTwo
//
//  Created by Darrell Payne on 5/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Rock.h"
#import "GameLayer.h"

@implementation Rock

-(id)initWithGameLayer:(GameLayer*)gl;
{
    self = [super initWithDynamicBody:@"rock"
                      spriteFrameName:@"rock.png"];
    
    if(self)
    {
        // [self setFixedRotation:true];
        
        [self setBullet:YES];
        
        gameLayer = gl;
    }
    return self;
}

@end
