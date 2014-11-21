class promodFlagThrowerImperial extends GameClasses.FlagThrowerImperial;

var config float FlagInheritedVelocity;
var config int FlagVelocity;

function PostBeginPlay()
{
	Super.PostBeginPlay();
        SetFlagThrow();
}

function SetFlagThrow()

{
        local promodFlagThrowerImperial ImpFlag;
        foreach AllActors(class'promodFlagThrowerImperial', ImpFlag)
        	if(ImpFlag != None)
                {
		ImpFlag.projectileInheritedVelFactor = FlagInheritedVelocity;//was .8
                ImpFlag.projectileVelocity = FlagVelocity;//was 800
	        }
}

defaultproperties
{
FlagInheritedVelocity=0.600000
FlagVelocity=1400.000000
}