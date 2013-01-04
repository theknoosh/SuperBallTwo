//
//  Piston.h
//  SuperBallTwo
//
//  Created by DPayne on 8/31/12.
//
//

#import "GB2Sprite.h"

@class GameLayer;

@interface Piston : GB2Sprite
{
    GameLayer *gameLayer; // weak reference
    ccTime  animDelay; // control speed of animation
    int     animPhase;        // the current animation phase
    bool    setOpenPiston, setClosePiston;

    
}

-(id) initWithGameLayer:(GameLayer*)gl;
-(void)openPiston;
-(void)closePiston;
-(bool)isOpen;


@end
