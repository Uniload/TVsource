class x2WeaponEnergyBlade extends EquipmentClasses.WeaponEnergyBlade; //thanks waterbottle

var Vector extent;
var float missEnergyUsage;

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

	local Pack enemyPack;
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

		if (Level.NetMode != NM_Client){
			victim.TakeDamage(damageAmt, rookOwner, hitLocation, Normal(traceEnd - fireLoc) * knockBackVelocity, damageTypeClass);
			if(Character(victim) != None){
				Character(victim).dropCarryables();
    /*
				if(Character(victim).pack != None){

					enemyPack = Character(victim).pack;
					enemyPack.gotoHeldState();
					/*
					enemyPack.gotoState('Recharging');
					enemyPack.finishActiveEffect();
					enemyPack.deactivating = true;
					enemyPack.deactivatingProgressedTime = 0;
					enemyPack.bLocalActive = false;
					enemyPack.rechargingAlpha = 0;
					enemyPack.alpha = 0;
					enemyPCC = PlayerCharacterController(Character(victim).Controller);
						
					enemyPCC.HUDManager.UpdateHUDData();
					*/
					
					//Character(victim).pack.drop();
					//Character(victim).destroyThirdPersonMesh();
					//Character(victim).pack = None
					//Character(victim).pack.endHeldByCharacter(Character(victim));
				}
				*/
			} 
		}
	}else {
		Character(rookOwner).changeEnergy(missEnergyUsage * -1);
	}

	return None;
}

defaultproperties
{
     Extent=(X=20.000000,Y=20.000000,Z=20.000000)
     missEnergyUsage=25.000000
     Range=500
     damageAmt=30
     knockBackVelocity=175000.000000
     damageTypeClass=Class'x2BladeProjectileDamageType'
     projectileClass=Class'x2ProjectileEnergyBlade'
}
