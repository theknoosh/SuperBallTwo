//
//  Launcher.m
//  SuperBallTwo
//
//  Created by DPayne on 8/31/12.
//
//

#import "Launcher.h"
#import "GameLayer.h"

#define ANIM_SPEED 1.0f

@implementation Launcher

-(id)initWithGameLayer:(GameLayer*)gl;
{
    self = [super initWithStaticBody:@"Launcher01"
                     spriteFrameName:@"Launcher01.png"];
    
    if(self)
    {
        [super updateCCFromPhysics];
        // [self setFixedRotation:true];
        
        [self setBullet:YES];
        
        gameLayer = gl;
    }
    openLauncher = false;
    return self;
}

-(void)setToOpen{
    openLauncher = true;
}

-(void) updateCCFromPhysics
{
    NSString    *frameName;
    
    animDelay -= 1.0f/60.0f;
    if(animDelay <= 0)
    {
        animDelay = ANIM_SPEED;
        animPhase++;
        if(animPhase > 4)
        {
            animPhase = 4;
        }
    }
    if(openLauncher)
    {
        frameName = [NSString stringWithFormat:@"Launcher0%d.png", animPhase];
    }
    else
    {
        frameName = [NSString stringWithFormat:@"Launcher01.png"];
    }
    
    [self setDisplayFrameNamed:frameName];
        
}


@end
