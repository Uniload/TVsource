class promodFlagThrowerBeagle extends GameClasses.FlagThrowerBeagle config(promod);

var config float FlagInheritedVelocity;
var config int FlagVelocity;

function PostBeginPlay()
{
	Super.PostBeginPlay();
        SetFlagThrow();
}

function SetFlagThrow()

{
        local promodFlagThrowerBeagle BEFlag;
        foreach AllActors(class'promodFlagThrowerBeagle', BEFlag)
        	if(BEFlag != None)
            {
		BEFlag.projectileInheritedVelFactor = FlagInheritedVelocity;//was .8
                BEFlag.projectileVelocity = FlagVelocity;//was 800
					}
}

defaultproperties
{
FlagInheritedVelocity=0.600000
FlagVelocity=1400.000000
}