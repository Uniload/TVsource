class x2FlagThrowerImperial extends GameClasses.FlagThrowerImperial;

var config float FlagInheritedVelocity;
var config int FlagVelocity;

function PostBeginPlay()
{
	Super.PostBeginPlay();
        SetFlagThrow();
}

function SetFlagThrow()

{
        local x2FlagThrowerImperial ImpFlag;
        foreach AllActors(class'x2FlagThrowerImperial', ImpFlag)
        	if(ImpFlag != None)
                {
		ImpFlag.projectileInheritedVelFactor = FlagInheritedVelocity;//was .8
                ImpFlag.projectileVelocity = FlagVelocity;//was 800
	        }
}

defaultproperties
{
     FlagInheritedVelocity=0.600000
     FlagVelocity=1400
}
