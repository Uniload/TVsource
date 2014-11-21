class x2ProjectileSpinfusor extends EquipmentClasses.ProjectileSpinfusor config(x2);

var config int DiscLifeSpan;

function ProjectileTouch(Actor Other, vector TouchLocation, vector TouchNormal)
{
       super.ProjectileTouch(Other, TouchLocation, TouchNormal);
}

function PreBeginPlay()
{
	Super.PreBeginPlay();
        SetDiscLifeSpan();
}

function SetDiscLifeSpan()

{
        local x2ProjectileSpinfusor Disc;
        foreach AllActors(class'x2ProjectileSpinfusor', Disc)
        	if(Disc != None)
                {
		Disc.LifeSpan = DiscLifeSpan;
                }
}

defaultproperties
{
     radiusDamageSize=650.000000
     radiusDamageMomentum=255000.000000
     MaxVelocity=10000.000000
     DiscLifeSpan=4.000000
}
