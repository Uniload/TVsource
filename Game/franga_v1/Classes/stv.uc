class stv extends Gameplay.Mutator;

const VERSION_NAME = "securetv_v1";

function PreBeginPlay()
{
	ModifyStats();
        super.PreBeginPlay();
}

function ModifyStats()
{
	local ModeInfo M;
	local int i;

	M = ModeInfo(Level.Game);

	if(M != None)
	{
                for(i = 0; i < M.extendedProjectileDamageStats.Length; ++i)
		{
			if(M.extendedProjectileDamageStats[i].damageTypeClass == Class'EquipmentClasses.ProjectileDamageTypeSpinfusor')
			{
				M.extendedProjectileDamageStats[i].extendedStatClass = Class'statMA';
			}
		}
        }
}

function Actor ReplaceActor(Actor Other)
{
        if(Other.IsA('WeaponChaingun'))
	{
		WeaponChaingun(Other).projectileClass = Class'stvProjectileChaingun';
		return Super.ReplaceActor(Other);
	}
	if(Other.IsA('WeaponRocketPod'))
	{
		WeaponRocketPod(Other).projectileClass = Class'stvProjectileRocketPod';
		return Super.ReplaceActor(Other);
	}
	if(Other.IsA('WeaponBlaster'))
	{
		WeaponBlaster(Other).projectileClass = Class'stvProjectileBlaster';
		return Super.ReplaceActor(Other);
	}
	if(Other.IsA('WeaponBuckler'))
	{
		WeaponBuckler(Other).projectileClass = Class'stvProjectileBuckler';
		return Super.ReplaceActor(Other);
	}
	if(Other.IsA('WeaponSniperRifle'))
	{
		WeaponSniperRifle(Other).projectileClass = Class'stvProjectileSniperRifle';
		return Super.ReplaceActor(Other);
	}
        if(Other.IsA('WeaponMortar'))
	{
		WeaponMortar(Other).projectileClass = Class'stvProjectileMortar';
                return Super.ReplaceActor(Other);
	}
        if(Other.IsA('WeaponGrenadeLauncher'))
	{
		WeaponGrenadeLauncher(Other).projectileClass = Class'stvProjectileGrenadeLauncher';
		return Super.ReplaceActor(Other);
	}
	if(Other.IsA('WeaponSpinfusor'))
	{
		WeaponSpinfusor(Other).projectileClass = Class'stvProjectileSpinfusor';
		return Super.ReplaceActor(Other);
	}
	if(Other.IsA('WeaponEnergyBlade'))
	{
		Other.Destroy();
		return ReplaceWith(Other, VERSION_NAME $ ".stvWeaponEnergyBlade");
	}
	if(Other.IsA('WeaponBurner'))
	{
               	WeaponBurner(Other).projectileClass = Class'stvProjectileBurner';
		return Super.ReplaceActor(Other);
	}
	if(Other.IsA('Grappler'))
	{
		Gameplay.Grappler(Other).projectileClass = Class'stvGrapplerProjectile';
		Gameplay.Grappler(Other).roundsPerSecond = 1.0;
		return Super.ReplaceActor(Other);
	}
	// Gameplay hack fix
        if(Other.IsA('ShieldPack'))
	{
		ShieldPack(Other).activeFractionDamageBlocked = 0.750000;
		ShieldPack(Other).passiveFractionDamageBlocked = 0.20000;
                ShieldPack(Other).rechargeTimeSeconds = 16.000000;
                ShieldPack(Other).rampUpTimeSeconds = 0.250000;
	        ShieldPack(Other).durationSeconds = 3.000000;
	        ShieldPack(Other).deactivatingDuration = 0.250000;
	        return Super.ReplaceActor(Other);
	}
	if(Other.IsA('CloakPack'))
	{
		Other.Destroy();
		return ReplaceWith(Other, VERSION_NAME $ ".stvanticloak");
	}
	if(Other.IsA('EnergyPack'))
	{
                EnergyPack(Other).boostImpulsePerSecond = 75000.000000;
                EnergyPack(Other).rechargeScale = 1.155000;
                EnergyPack(Other).rechargeTimeSeconds = 18.000000;
                EnergyPack(Other).rampUpTimeSeconds = 0.250000;
	        EnergyPack(Other).durationSeconds = 1.000000;
	        EnergyPack(Other).deactivatingDuration = 0.250000;
	        return Super.ReplaceActor(Other);
	}
	if(Other.IsA('RepairPack'))
	{
                RepairPack(Other).accumulationScale = 0.500000;
                RepairPack(Other).activeExtraSelfHealthPerPeriod = 1.750000;
                RepairPack(Other).activeHealthPerPeriod = 13.000000;
                RepairPack(Other).activePeriod = 1.000000;
	        RepairPack(Other).passiveHealthPerPeriod = 1.750000;
	        RepairPack(Other).passivePeriod = 1.000000;
	        RepairPack(Other).radius = 1500.000000;
	        RepairPack(Other).deactivatingDuration = 0.250000;
	        RepairPack(Other).durationSeconds = 15.000000;
	        RepairPack(Other).rampUpTimeSeconds = 0.250000;
	        RepairPack(Other).rechargeTimeSeconds = 12.000000;
	        return Super.ReplaceActor(Other);
	}
        if(Other.IsA('SpeedPack'))
	{
                SpeedPack(Other).passiveRefireRateScale = 1.250000;
                SpeedPack(Other).refireRateScale = 1.800000;
                SpeedPack(Other).rechargeTimeSeconds = 13.000000;
                SpeedPack(Other).rampUpTimeSeconds = 0.250000;
	        SpeedPack(Other).durationSeconds = 2.000000;
	        SpeedPack(Other).deactivatingDuration = 0.250000;
	        return Super.ReplaceActor(Other);
	}
	return Super.ReplaceActor(Other);
}

defaultproperties
{
}