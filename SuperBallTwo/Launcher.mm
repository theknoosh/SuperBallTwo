//
//  Launcher.m
//  SuperBallTwo
//
//  Created by DPayne on 8/31/12.
//
//

#import "Launcher.h"
#import "GameLayer.h"

#define ANIM_SPEED 0.3f

@implementation Launcher

-(id)initWithGameLayer:(GameLayer*)gl;
{
    self = [super initWithStaticBody:@"Launcher01"
                     spriteFrameName:@"Launcher01.png"];
    
    if(self)
    {
        // [self setFixedRotation:true];
        
        [self setBullet:YES];
        
        gameLayer = gl;
    }
    return self;
}

-(void)open
{
    NSString *frameName;
    int animPhase = 1;
    while (animPhase < 5) {
        
        animDelay -= 1.0f/60.0f;
        if (animDelay < 0.0f) {
            animDelay = ANIM_SPEED;
            frameName = [NSString stringWithFormat:@"Launcher0%d.png", animPhase];
            ++animPhase;
            [self setDisplayFrameNamed:frameName];
        }
        
       
    }
        
}


@end
