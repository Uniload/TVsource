class promodWeaponEnergyBlade extends EquipmentClasses.WeaponEnergyBlade config(promod); //thanks waterbottle

var Vector extent;
var float missEnergyUsage;
var config bool flagDrop;

simulated protected function Projectile makeProjectile(Rotator fireRot, Vector fireLoc)
{
	local Vector hitLocation;
	local Vector hitNormal;
	local Vector traceEnd;
	local Material hitMaterial;
	local Actor victim;
	local Actor viewActor;
	local Vector startLoc;
	local Rotator viewRot;
	local PlayerController pc;

	local Character weaponOwner;
	local PlayerCharacterController enemyPCC;

	weaponOwner = Character(rookOwner);

	useAmmo();
	fireCount++;

	if (pc != None)
	{
		startLoc = pc.location;
		viewRot = pc.rotation;
		viewActor = Owner;
		pc.PlayerCalcView(viewActor, startLoc, viewRot);
	}
	else
	{
		startLoc = Owner.Location;
		viewRot = fireRot;
	}

	traceEnd = fireLoc + Vector(viewRot) * range;

	victim = Trace(hitLocation, hitNormal, traceEnd, startLoc, true, extent, hitMaterial);

	if (victim != None && TerrainInfo(victim) == None)
	{
		TriggerEffectEvent('Hit', None, hitMaterial, hitLocation, Rotator(hitNormal));

		weaponOwner.changeEnergy(energyUsage);

		if (Level.NetMode != NM_Client)
                {
			victim.TakeDamage(damageAmt, rookOwner, hitLocation, Normal(traceEnd - fireLoc) * knockBackVelocity, damageTypeClass);
			if(Character(victim) != None && flagdrop)
                        {
			Character(victim).dropCarryables();
                        }

		}
	}
	else
        {
	Character(rookOwner).changeEnergy(missEnergyUsage * -1);
	}

	return None;
}

defaultproperties
{
     Extent=(X=20.000000,Y=20.000000,Z=20.000000)
     missEnergyUsage=0.000000
     Range=250
     damageAmt=50
     knockBackVelocity=175000.000000
     damageTypeClass=Class'promodBladeProjectileDamageType'
     projectileClass=Class'promodProjectileEnergyBlade'
     flagDrop=True
}
