//
//  Piston.mm
//  SuperBallTwo
//
//  Created by DPayne on 8/31/12.
//
//

#import "Piston.h"
#import "GameLayer.h"
#import "GB2Contact.h"

#define ANIM_SPEED .05f

@implementation Piston

-(id)initWithGameLayer:(GameLayer*)gl;
{
    self = [super initWithStaticBody:@"PistonAnimation010"
                     spriteFrameName:@"PistonAnimation00.png"];
    
    if(self)
    {
        [super updateCCFromPhysics];
        // [self setFixedRotation:true];
        
        [self setBullet:YES];
        
        gameLayer = gl;
        
    }
    setOpenPiston = false;
    return self;
}

-(void)openPiston{
    setOpenPiston = true;
    setClosePiston = false;
}
-(void)closePiston{
    setClosePiston = true;
    setOpenPiston = false;
}

-(void) updateCCFromPhysics
{
    NSString    *frameName;
    
    animDelay -= 1.0f/30.0f;
    
    if(animDelay <= 0)
    {
        animDelay = ANIM_SPEED;
        
        if (setOpenPiston) {
            animPhase++;
            if(animPhase > 10)
            {
                animPhase = 10;
            }
        }
        if (setClosePiston) {
            animPhase--;
            if (animPhase<0) {
                animPhase = 0;
            }
        }
        
    }
    
    frameName = [NSString stringWithFormat:@"PistonAnimation0%d.png", animPhase];
  
    [self setDisplayFrameNamed:frameName];
    // [self setStaticBody:frameName position:[self physicsPosition]];
}

-(void)beginContactWithObject: (GB2Contact*)contact{
    NSLog(@"Contact");
}

-(bool)isOpen{
    return setOpenPiston;
}

-(void) dealloc
{
    [super dealloc];
    
}


@end
