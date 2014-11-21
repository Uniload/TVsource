class x2FlagThrowerBeagle extends GameClasses.FlagThrowerBeagle config(x2);

var config float FlagInheritedVelocity;
var config int FlagVelocity;

function PostBeginPlay()
{
	Super.PostBeginPlay();
        SetFlagThrow();
}

function SetFlagThrow()

{
        local x2FlagThrowerBeagle BEFlag;
        foreach AllActors(class'x2FlagThrowerBeagle', BEFlag)
        	if(BEFlag != None)
                {
		BEFlag.projectileInheritedVelFactor = FlagInheritedVelocity;//was .8
                BEFlag.projectileVelocity = FlagVelocity;//was 800
	        }
}

defaultproperties
{
}