class x2FlagThrowerPhoenix extends GameClasses.FlagThrowerPhoenix;

var config float FlagInheritedVelocity;
var config int FlagVelocity;

function PostBeginPlay()
{
	Super.PostBeginPlay();
        SetFlagThrow();
}

function SetFlagThrow()

{
        local x2FlagThrowerPhoenix PnxFlag;
        foreach AllActors(class'x2FlagThrowerPhoenix', PnxFlag)
        	if(PnxFlag != None)
                {
		PnxFlag.projectileInheritedVelFactor = FlagInheritedVelocity;//was .8
                PnxFlag.projectileVelocity = FlagVelocity;//was 800
	        }
}

defaultproperties
{
FlagInheritedVelocity=0.600000
FlagVelocity=1400.000000
}