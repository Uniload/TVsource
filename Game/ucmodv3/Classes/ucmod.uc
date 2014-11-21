class ucmod extends Gameplay.Mutator;


var config int Degrapple;
var config int VehiclePod;
var config int VehicleRover;
var config int VehicleAssaultShip;
var config int VehicleTank;
var config int GrapplerAmmo;
var config int Shieldpack;
var config int DisableDeployableTurrets;
var config int DisableMines;
var config int DisableDeployableInvStations;
var config int DisableRepairer;
var config int DisableDeployableCatapults;
var config int DisableBaseTurrets;
var config int AATurret;
var config int AntiBaseRape;
var config int ScoreSystem;
var config int EnergyBladeStyle;




function preBeginPlay()
{

local Gameplay.VehicleSpawnPoint VSP;
local BaseObjectClasses.BaseTurretAntiAir turretaa;
local BaseObjectClasses.BaseTurret turret2;
local BaseObjectClasses.StaticMeshRemovable baseturret;
local BaseObjectClasses.BaseDeployableSpawnTurret depspawnturret;
local BaseObjectClasses.BaseDeployableSpawnCatapult depspawncatapult;
local BaseObjectClasses.BaseDeployableSpawnInventoryStation depspawninvstation;
local BaseObjectClasses.BaseDeployableSpawnRepairer depspawnrepairer;
local BaseObjectClasses.BaseDeployableSpawnShockMine depspawnmine;
local BaseObjectClasses.BaseCatapult catap;
local BaseObjectClasses.BaseInventoryStation invstation;
local BaseObjectClasses.BaseInventoryStationDouble dblstation;
local BaseObjectClasses.BaseInventoryStationQuad quadstation;
local BaseObjectClasses.BaseInventoryStationSingle singlestation;
local BaseObjectClasses.BaseInventoryStationTriple triplestation;
local BaseObjectClasses.BasePowerGenerator powergen;
local BaseObjectClasses.BaseResupply resupstation;
local BaseObjectClasses.Basesensor sensor;




foreach AllActors(class'Gameplay.VehicleSpawnPoint', VSP)     //here, we take care of the vehicle spawn points
{
	if (VehiclePod==2)
	{

                if (VSP != None && VSP.vehicleClass == class'VehicleClasses.VehiclePod')
			{
			VSP.vehicleClass = class'ucmodv3.classyPod';
			}

        }

        else if(VehiclePod==1)
        {
                if (VSP != None && VSP.vehicleClass == class'VehicleClasses.VehiclePod')
			    {
			    VSP.vehicleClass=None;
			    }
       }

	if (VehicleRover==2)
	{

                if (VSP != None && VSP.vehicleClass == class'VehicleClasses.VehicleBuggy')
			{
			VSP.vehicleClass = class'ucmodv3.classyBuggy';
			}

        }

        else if(VehicleRover==1)
        {
                if (VSP != None && VSP.vehicleClass == class'VehicleClasses.VehicleBuggy')
			    {
			    VSP.vehicleClass=None;
			    }
       }
       
	if (VehicleAssaultShip==2)
	{

                if (VSP != None && VSP.vehicleClass == class'VehicleClasses.VehicleAssaultShip')
			{
			VSP.vehicleClass = class'ucmodv3.classyAssaultShip';
			}

        }

        else if(VehicleAssaultShip==1)
        {
                if (VSP != None && VSP.vehicleClass == class'VehicleClasses.VehicleAssaultShip')
			    {
			    VSP.vehicleClass=None;
			    }
       }
       

	if (VehicleTank==2)
	{

                if (VSP != None && VSP.vehicleClass == class'VehicleClasses.VehicleTank')
			{
			VSP.vehicleClass = class'ucmodv3.classyTank';
			}

        }

        else if(VehicleTank==1)
        {
                if (VSP != None && VSP.vehicleClass == class'VehicleClasses.VehicleTank')
			    {
			    VSP.vehicleClass=None;
			    }
       }




}




ForEach AllActors(class'BaseObjectClasses.BaseTurret', turret2)    //ici, on va dégager les base turrets
    {
        if (DisableBaseTurrets==1)
           {
           turret2.Destroy();
           }

    }

ForEach AllActors(class'BaseObjectClasses.StaticMeshRemovable', baseturret)    //ici, on va dégager les bases des bases turrets
    {
        if (DisableBaseTurrets==1)
           {
           baseturret.Destroy();
           }

    }


ForEach AllActors(class'BaseObjectClasses.BaseTurretAntiAir', turretaa)    //ici, on s'occupe des popcorn turrets
    {
        if (AATurret==1)
           {
           turretaa.weaponClass=Class'ucmodv3.classyaaturretweapon';
           }
        else if (AATurret==2)
           {
           turretaa.Destroy();
           }
    }
    

    
    
ForEach AllActors(class'BaseObjectClasses.BaseDeployableSpawnTurret', depspawnturret)    //ici, on s'occupe des spawn de deployable turrets
    {
        if (AntiBaseRape==1)
           {
           depspawnturret.bcanBeDamaged=False;
           }

        if (DisableDeployableTurrets==1)
           {
           depspawnturret.Destroy();
           }

    }




ForEach AllActors(class'BaseObjectClasses.BaseDeployableSpawnCatapult', depspawncatapult)    //ici, on s'occupe des spawn de deployable catapult
    {
           if (AntiBaseRape==1)
           {
           depspawncatapult.bcanBeDamaged=False;
           }

        if (DisableDeployableCatapults==1)
           {
           depspawncatapult.Destroy();
           }

     
    }
    
    
ForEach AllActors(class'BaseObjectClasses.BaseDeployableSpawnInventoryStation', depspawninvstation)    //ici, on s'occupe des spawn de deployable invstation
    {
       if (AntiBaseRape==1)
           {
           depspawninvstation.bcanBeDamaged=False;
           }

        if (DisableDeployableInvStations==1)
           {
           depspawninvstation.Destroy();
           }

    }


ForEach AllActors(class'BaseObjectClasses.BaseDeployableSpawnRepairer', depspawnrepairer)    //ici, on s'occupe des spawn de deployable repairer
    {
       if (AntiBaseRape==1)
           {
           depspawnrepairer.bcanBeDamaged=False;
           }

        if (DisableRepairer==1)
           {
           depspawnrepairer.Destroy();
           }

    }

ForEach AllActors(class'BaseObjectClasses.BaseDeployableSpawnShockMine', depspawnmine)    //ici, on s'occupe des spawn de deployable repairer
    {
       if (AntiBaseRape==1)
           {
           depspawnmine.bcanBeDamaged=False;
           }
        if (DisableMines==1)
           {
           depspawnmine.Destroy();
           }

    }


ForEach AllActors(class'BaseObjectClasses.BaseCatapult', catap)    //ici, on modifie les catapultes
    {
       if (AntiBaseRape==1)
           {
           catap.bcanBeDamaged=False;
           }

    }


ForEach AllActors(class'BaseObjectClasses.BaseInventoryStation', invstation)    //ici, on modifie les inv
    {
       if (AntiBaseRape==1)
           {
           invstation.bcanBeDamaged=False;
           }

    }



ForEach AllActors(class'BaseObjectClasses.BaseInventoryStationDouble', dblstation)    //ici, on modifie les station
    {
       if (AntiBaseRape==1)
           {
           dblstation.bcanBeDamaged=False;
           }

    }


ForEach AllActors(class'BaseObjectClasses.BaseInventoryStationQuad', quadstation)    //ici, on modifie les station
    {
       if (AntiBaseRape==1)
           {
           quadstation.bcanBeDamaged=False;
           }

    }

ForEach AllActors(class'BaseObjectClasses.BaseInventoryStationSingle', singlestation)    //ici, on modifie les station
    {
       if (AntiBaseRape==1)
           {
           singlestation.bcanBeDamaged=False;
           }

    }
    
ForEach AllActors(class'BaseObjectClasses.BasePowerGenerator', powergen)    //ici, on modifie les generator
    {
       if (AntiBaseRape==1)
           {
           powergen.bcanBeDamaged=False;
           }

    }
    
ForEach AllActors(class'BaseObjectClasses.BaseResupply', resupstation)    //ici, on modifie les resupplystation
    {
       if (AntiBaseRape==1)
           {
           resupstation.bcanBeDamaged=False;
           }

    }
    
ForEach AllActors(class'BaseObjectClasses.Basesensor', sensor)    //ici, on modifie les sensor
    {
       if (AntiBaseRape==1)
           {
           sensor.bcanBeDamaged=False;
           }

    }
    



}



function Actor ReplaceActor(Actor Other)
{

		if(Other.IsA('PackShield'))     //on gere le shieldpack
	{
	        if(ShieldPack==1)
	        {
		Other.Destroy();
		return ReplaceWith(Other, "ucmodv3.cmodshieldpack");
                }
                if(ShieldPack==2)
	        {
		PackShield(Other).activeFractionDamageBlocked=0.500000;
		PackShield(Other).passiveFractionDamageBlocked=0.100000;
                }


	}


	if(Other.IsA('WeaponGrappler'))       //on s'occupe d'activer ou non desactiver degrapple
	{
        if(Degrapple==1)
        {
		WeaponGrappler(Other).projectileClass = class'ucmodv3.classyGrapplerProjectile';
		return Other;
        }
	}

        if(Other.IsA('WeaponEnergyBlade'))       //on s'occupe de transformer l'eblade en shocklance ou non
	{

        if(EnergyBladeStyle==1)
        {
                WeaponEnergyBlade(Other).damageAmt = 50;
		return Other;
        }

                if(EnergyBladeStyle==2)
        {
		WeaponEnergyBlade(Other).roundsPerSecond = 0.8000;
                WeaponEnergyBlade(Other).damageAmt = 75;
                WeaponEnergyBlade(Other).Range = 600;
		return Other;
        }
        
        

	}



}

function string MutateSpawnCombatRoleClass(Character c)
{

//thanks to compmod for that one!

    if(grapplerAmmo==1)
    {
    c.team().combatRoleData[0].role.default.armorClass.default.AllowedWeapons = class<Armor>(DynamicLoadObject("ucmodv3.grapplerAmmocmodArmorLight", class'class')).default.AllowedWeapons;
    c.team().combatRoleData[1].role.default.armorClass.default.AllowedWeapons = class<Armor>(DynamicLoadObject("ucmodv3.grapplerAmmocmodArmorMedium", class'class')).default.AllowedWeapons;
    c.team().combatRoleData[2].role.default.armorClass.default.AllowedWeapons = class<Armor>(DynamicLoadObject("ucmodv3.grapplerAmmocmodArmorHeavy", class'class')).default.AllowedWeapons;
    }

    else
    {
	c.team().combatRoleData[0].role.default.armorClass.default.AllowedWeapons = class<Armor>(DynamicLoadObject("ucmodv3.cmodArmorLight", class'class')).default.AllowedWeapons;
	c.team().combatRoleData[1].role.default.armorClass.default.AllowedWeapons = class<Armor>(DynamicLoadObject("ucmodv3.cmodArmorMedium", class'class')).default.AllowedWeapons;
	c.team().combatRoleData[2].role.default.armorClass.default.AllowedWeapons = class<Armor>(DynamicLoadObject("ucmodv3.cmodArmorHeavy", class'class')).default.AllowedWeapons;
    }
}

defaultproperties
{
}
