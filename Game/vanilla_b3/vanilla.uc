class vanilla extends Gameplay.Mutator config(vanilla);

var config bool EnableDegrapple; // Enabling of degrapple.
var config bool EnableVehicles; // Enabling of vehicles.
var config int GrapplerAmmo; // Grappler ammo count.
var config float GrapplerReelRate; // Grappler reel in rate.
var config float GrapplerRPS; // Grappler rounds per second.
var config float ShieldActive; // Active shield pack damage reduction.
var config float ShieldPassive; // Passive shield pack damage reduction.
var config bool AutoBan; // Auto banning of cheaters.
var config bool AutoKick; // Auto kicking of cheaters.
var int CheaterThreshold; // Number of violations before a client is considered a cheater.
var anticsIRC IRC; // IRC connection.
var config bool PermaBan; // Determines whether the ban will be a session or permanent ban.
var string ServerPackage; // Server package name.
var config int ValidationInterval; // Validation interval, in minutes.


function PreBeginPlay()
{
	ModifyVehiclePads();

	AddServerPackage();
	LoadCharacterController();	
	
	SetTimer(ValidationInterval * 60, true);
}

function PostBeginPlay()
{
	// TODO: Research Super.PostBeginPlay() further.
	
	Super.PostBeginPlay();
	
	IRC = Spawn(class'anticsIRC');
	IRC.Connect();
	
	SaveConfig();
}

function AddServerPackage()
{
	local bool addServerPackage;
	local int i;
	
	addServerPackage = true;
	
	for(i = 0; i < class'Engine.GameEngine'.default.ServerPackages.Length; i++)
	{
		if(class'Engine.GameEngine'.default.ServerPackages[i] == ServerPackage)
		{
			addServerPackage = false;
			break;
		}
	}
	
	if(addServerPackage)
	{
		class'Engine.GameEngine'.default.ServerPackages[class'Engine.GameEngine'.default.ServerPackages.Length] = ServerPackage;
		class'Engine.GameEngine'.static.StaticSaveConfig();
		log("Server requires a restart for setup to complete!", 'antics');
		
		// TODO: Figure out how to reboot a server.
		// Quit();
	}
}

function LoadCharacterController()
{
	local Gameplay.ModeInfo MI;
	
	foreach AllActors(class'Gameplay.ModeInfo', MI)
	{
		if (MI != None)
		{
			MI.PlayerControllerClassName = ServerPackage $ ".anticsCharacterController";
			log("Character controller loaded successfully!", 'antics');
			break;
		}
	}
}

function Timer()
{	
	ValidateClients();
}

function ValidateClients()
{
	local Controller C;
	
	for(C = Level.ControllerList; C != None; C = C.NextController)
	{
		if(anticsCharacterController(C).ViolationCount > CheaterThreshold)
		{
			LogCheater(C);
			DisciplineCheater(C);
		}
	}
}

function LogCheater(Controller C)
{
	local string IPAddressLong, IPAddress, IPAddressPort, IRCMessage;
	
	IPAddressLong = PlayerController(C).GetPlayerNetworkAddress();
	Div(IPAddressLong, ":", IPAddress, IPAddressPort);
			
	if(anticsCharacterController(C).LogCheater)
	{
		IRCMessage = "1,13<<CHEATER DETECTED>> Name: " $ C.PlayerReplicationInfo.PlayerName $ " IP: " $ IPAddress $ "";
		IRC.SendMessage(IRCMessage);
		log(IRCMessage, 'antics');
		anticsCharacterController(C).LogCheater = false;
	}
}

function DisciplineCheater(Controller C)
{
	if(AutoBan)
	{
		Level.Game.AccessControl.BanPlayer(PlayerController(C), !PermaBan);
		log("Player '" $ C.PlayerReplicationInfo.PlayerName $ "' has been banned for cheating.", 'antics');
		Level.Game.BroadcastLocalized(self, class'anticsGameMessage', 32, C.PlayerReplicationInfo);
		return;
	}
	else if(AutoKick)
	{
		Level.Game.AccessControl.KickPlayer(PlayerController(C));
		log("Player '" $ C.PlayerReplicationInfo.PlayerName $ "' has been kicked for cheating.", 'antics');
		Level.Game.BroadcastLocalized(self, class'anticsGameMessage', 31, C.PlayerReplicationInfo);
	}
	else
	{
		log("No action has been taken against '" $ C.PlayerReplicationInfo.PlayerName $ "' for cheating.", 'antics');
		Level.Game.BroadcastLocalized(self, class'anticsGameMessage', 30, C.PlayerReplicationInfo);
	}
}

function ModifyVehiclePads()
{
    local Gameplay.VehicleSpawnPoint vehiclePad;
    local Gameplay.Vehicle vehicle;

    ForEach AllActors(Class'Gameplay.VehicleSpawnPoint', vehiclePad)
        if(vehiclePad != None)
			vehiclePad.setSwitchedOn(EnableVehicles);
		
	ForEach AllActors(Class'Gameplay.Vehicle', vehicle)
		if(vehicle != None && !EnableVehicles)
			vehicle.Destroy();
}

function string MutateSpawnCombatRoleClass(Character c)
{
	local int i, j;
	
	for(i = 0; i < c.team().combatRoleData.length; i++)
		for(j = 0; j < c.team().combatRoleData[i].role.default.armorClass.default.AllowedWeapons.length; j++)
			if(c.team().combatRoleData[i].role.default.armorClass.default.AllowedWeapons[j].typeClass == Class'EquipmentClasses.WeaponGrappler')
				c.team().combatRoleData[i].role.default.armorClass.default.AllowedWeapons[j].quantity = GrapplerAmmo;
				
	ModifyVehiclePads();
				
	return Super.MutateSpawnCombatRoleClass(c);
}

function Actor ReplaceActor(Actor Other)
{
	if(Other.IsA('Grappler'))
	{
		if(EnableDegrapple)
			Gameplay.Grappler(Other).projectileClass = Class'DegrappleProjectile';
		else
			Gameplay.Grappler(Other).projectileClass = Class'Gameplay.GrapplerProjectile';
		
		Gameplay.Grappler(Other).reelInDelay = GrapplerReelRate;	
		Gameplay.Grappler(Other).roundsPerSecond = GrapplerRPS;
	}
		
	if(Other.IsA('PackShield'))
	{
		Gameplay.ShieldPack(Other).activeFractionDamageBlocked = ShieldActive;
		Gameplay.ShieldPack(Other).passiveFractionDamageBlocked = ShieldPassive;
	}
	if(Other.IsA('WeaponChaingun'))
	{
		WeaponChaingun(Other).projectileClass = Class'NRBProjectileChaingun';
		return Super.ReplaceActor(Other);
	}
	if(Other.IsA('WeaponBlaster'))
	{
		WeaponBlaster(Other).projectileClass = Class'NRBProjectileBlaster';
		return Super.ReplaceActor(Other);
	}
	if(Other.IsA('WeaponSpinfusor'))
	{
		WeaponSpinfusor(Other).projectileClass = Class'NRBProjectileSpinfusor';
		return Super.ReplaceActor(Other);
	}
	if(Other.IsA('WeaponSniperRifle'))
	{
		WeaponSniperRifle(Other).projectileClass = Class'NRBProjectileSniperRifle';
		return Super.ReplaceActor(Other);
	}
	if(Other.IsA('WeaponGrenadeLauncher'))
	{
		WeaponGrenadeLauncher(Other).projectileClass = Class'NRBProjectileGrenadeLauncher';
		return Super.ReplaceActor(Other);
	}
	if(Other.IsA('WeaponBurner'))
	{
		WeaponBurner(Other).projectileClass = Class'NRBProjectileBurner';
		return Super.ReplaceActor(Other);
	}
	if(Other.IsA('WeaponRocketPod'))
	{
		WeaponRocketPod(Other).projectileClass = Class'NRBProjectileRocketPod';
		return Super.ReplaceActor(Other);
	}
	if(Other.IsA('WeaponMortar'))
	{
		WeaponMortar(Other).projectileClass = Class'NRBProjectileMortar';
		return Super.ReplaceActor(Other);
	}
	if(Other.IsA('WeaponBuckler'))
	{
		WeaponBuckler(Other).projectileClass = Class'NRBProjectileBuckler';
		return Super.ReplaceActor(Other);
	}
	return Super.ReplaceActor(Other);
}

defaultproperties
{
     EnableDegrapple=True
     GrapplerAmmo=10
     GrapplerReelRate=0.500000
     GrapplerRPS=1.000000
     shieldActive=0.600000
     ShieldPassive=0.125000
     AutoKick=True
     CheaterThreshold=200
     ServerPackage="Vanilla_b3"
     ValidationInterval=1
}
