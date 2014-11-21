class newgrappler extends Gameplay.Mutator;


function Actor ReplaceActor(Actor Other)
{

//unlimited ammo for grappler

	if(Other.IsA('WeaponGrappler'))
	{
		WeaponGrappler(Other).ammoUsage = 0;
                return Other;
        }
}

defaultproperties
{
}
