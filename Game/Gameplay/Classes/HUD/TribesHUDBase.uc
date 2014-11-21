class TribesHUDBase extends Engine.HUD
	native;

import enum EObjectiveStatus from ObjectiveInfo;
import enum EObjectiveType from ObjectiveInfo;
import enum EAllyType from ObjectiveInfo;
import enum EStateType from ObjectiveInfo;

import enum EInputKey from Engine.Interaction;
import enum EInputAction from Engine.Interaction;

var bool	bAllowCommandHUDSwitching;
var bool	bShowCursor;

var PlayerCharacterController	Controller;
var ClientSideCharacter			ClientSideChar;
var localized string			quickKeyText;

struct native TagBindingMap
{
	var String Tag;
	var String BindingText;
	var String BoundKey;
};

var Array<TagBindingMap> TagBindings;

native function String ReplacePromptKeyBinds(String PromptText);

simulated event PostBeginPlay()
{
	Super.PostBeginPlay();

	Controller = PlayerCharacterController(PlayerOwner);
	ClientSideChar = Controller.clientSideChar;
}

// called when the HUD is shown
simulated function HUDShown();

// called when the HUD is Hidden
simulated function HUDHidden();

// Key events
function bool KeyType( EInputKey Key, optional string Unicode );

function bool KeyEvent( EInputKey Key, EInputAction Action, FLOAT Delta );

simulated function Cleanup();

simulated function bool NeedsKeyInput()
{
	return false;
}

simulated function Character GetCharacter()
{
	local Character character;

	character = Controller.character;
	
	// Failsafe: sometimes the character is none and shouldnt be
	if(character == None && Vehicle(Controller.Pawn) != None)
	{
		character = Vehicle(Controller.Pawn).GetDriver();
		Controller.Character = character;
	}

	// Failsafe: sometimes the character is none and shouldnt be
	if(character == None && VehicleMountedTurret(Controller.Pawn) != None)
	{
		character = VehicleMountedTurret(Controller.Pawn).getControllingCharacter();
		Controller.Character = character;
	}

	// Failsafe: sometimes the character is none and shouldnt be
	if(character == None && Turret(Controller.Pawn) != None)
	{
		character = Turret(Controller.Pawn).getControllingCharacter();
		Controller.Character = character;
	}

	return character;
}

simulated function UpdateHUDData();

simulated function UpdateHUDHealthData()
{
	local Character character;

	character = GetCharacter();

	if(character == None)
	{
		// set health to zero on death
		clientSideChar.health = 0;
		return;
	}

	// do all character specific stuff in here
	clientSideChar.health = character.health;
	clientSideChar.healthMaximum = character.healthMaximum;
	clientSideChar.healthInjectionAmount = character.GetHealthInjectionAmount();
	clientSideChar.energy = character.energy;
	clientSideChar.energyMaximum = character.energyMaximum;
	clientSideChar.bShowEnergyBar = ! character.bDisableJetting;

	clientSideChar.energyWeaponDepleted = character.energyWeaponDepleted;
	character.energyWeaponDepleted = 0;
	clientSideChar.bZoomed = (Controller.bZoom == 1) && character.bCanZoom;
	clientSideChar.zoomMagnificationLevel = Controller.zoomMagnificationLevels[Controller.zoomLevel];

	clientSideChar.Velocity = character.movementSpeed;
}

simulated function ClearHUDEquipmentData()
{
	// fill in default equipment info
	clientSideChar.fallbackWeapon.type = None;
	clientSideChar.weapons[0].type = None;
	clientSideChar.weapons[1].type = None;
	clientSideChar.weapons[2].type = None;
	clientSideChar.activeWeapon.type = None;
	clientSideChar.grenades.type = None;
	clientSideChar.healthKit = None;
	clientSideChar.healthKitQuantity = 0;
	clientSideChar.deployable = None;
	clientSideChar.bDeployableActive = false;
	clientSideChar.activeWeaponIdx = -2;
	clientSideChar.throwForceMax = 0;
	clientSideChar.throwForce = 0;
}

function String GetHotkey(String Binding)
{
	local String hotKey;
	hotKey = class'KeyBindings'.static.GetKeyFromBinding(Binding, true);

	if(Len(hotKey) > 2)
		hotKey = Left(hotKey, 2);
	if(hotKey == "`")
		hotKey = "~";

	return hotKey;
}

simulated function UpdateHUDEquipmentData()
{
	local Character character;
	local int weaponIdx;
	local Weapon w;
	local TimeChargeUpWeapon timeCharge;
	local Deployable dep;

	character = GetCharacter();

	if(character == None)
		return;

//	ClearHUDEquipmentData();

	// throw force info
	timeCharge = TimeChargeUpWeapon(character.weapon);
	if (timeCharge != None && timeCharge.bShowChargeOnHUD && timeCharge.charge > 0)
	{
		clientSideChar.throwForceMax = timeCharge.maxCharge;
		clientSideChar.throwForce = timeCharge.charge;
	}
	else
	{
		timeCharge = TimeChargeUpWeapon(character.GetAltWeapon());
		if (timeCharge != None && timeCharge.bShowChargeOnHUD)
		{
			clientSideChar.throwForceMax = timeCharge.maxCharge;
			clientSideChar.throwForce = timeCharge.charge;
		}
		else
		{
			clientSideChar.throwForceMax = 0;
			clientSideChar.throwForce = 0;
		}
	}

	clientSideChar.activeWeapon.type = None;
	clientSideChar.activeWeaponIdx = -2;
	for (weaponIdx = 0; weaponIdx < class'Character'.const.NUM_WEAPON_SLOTS; ++weaponIdx)
	{
		if (character.weaponSlots[weaponIdx] != None)
		{
			w = character.weaponSlots[weaponIdx];

			// this is slow, so we only update it when required
			if(! clientSideChar.bHotKeysUpdated || clientSideChar.weapons[weaponIdx].type != w.class)
			{
				clientSideChar.weapons[weaponIdx].hotkey = GetHotKey("SwitchWeapon "$string(weaponIdx+1));
			}

			clientSideChar.weapons[weaponIdx].type = w.class;
			clientSideChar.weapons[weaponIdx].ammo = w.ammoCount;
			clientSideChar.weapons[weaponIdx].bCanFire = w.canFire();
			clientSideChar.weapons[weaponIdx].refireTime = 1.0 / w.roundsPerSecond;
			clientSideChar.weapons[weaponIdx].timeSinceLastFire = Level.TimeSeconds - w.lastFireTime;
			clientSideChar.weapons[weaponIdx].Spread = w.GetProjectileSpreadScale();

			if(w == character.weapon)
			{
				clientSideChar.activeWeaponIdx = weaponIdx;
				clientSideChar.activeWeapon = clientSideChar.weapons[weaponIdx];
			}
		}
		else
		{
			clientSideChar.weapons[weaponIdx].type = None;
		}
	}

	if(character.fallbackWeapon != None)
	{
		w = character.fallbackWeapon;

		// this is slow, so we only update it when required
		if(! clientSideChar.bHotKeysUpdated || clientSideChar.fallbackWeapon.type != w.class)
			clientSideChar.fallbackWeapon.hotkey = GetHotKey("SwitchToFallbackWeapon");

		clientSideChar.fallbackWeapon.type = w.class;
		clientSideChar.fallbackWeapon.ammo = w.ammoCount;
		clientSideChar.fallbackWeapon.bCanFire = w.canFire();
		clientSideChar.fallbackWeapon.refireTime = 1.0 / w.roundsPerSecond;
		clientSideChar.fallbackWeapon.timeSinceLastFire = Level.TimeSeconds - w.lastFireTime;
	}
	else if(character.armorClass != None && character.armorClass.default.fallbackWeaponClass != None)
	{
		// this is slow, so we only update it when required
		if(! clientSideChar.bHotKeysUpdated || clientSideChar.fallbackWeapon.type != character.armorClass.default.fallbackWeaponClass)
			clientSideChar.fallbackWeapon.hotkey = GetHotKey("SwitchToFallbackWeapon");

		clientSideChar.fallbackWeapon.type = character.armorClass.default.fallbackWeaponClass;
		clientSideChar.fallbackWeapon.ammo = character.armorClass.default.fallbackWeaponClass.default.ammoCount;
		clientSideChar.fallbackWeapon.bCanFire = true;
		clientSideChar.fallbackWeapon.refireTime = 1;
		clientSideChar.fallbackWeapon.timeSinceLastFire = 1;
	}
	else
	{
		clientSideChar.fallbackWeapon.type = None;
	}

	if(character.fallbackWeapon == character.weapon && character.weapon != None)
	{
		clientSideChar.activeWeaponIdx = -1;
		clientSideChar.activeWeapon = clientSideChar.fallbackWeapon;		
	}

	// deployable
	clientSideChar.bDeployableActive = false;
	dep = Deployable(character.nextEquipment(None, class'Deployable'));
	if(dep != None)
	{
		// this is slow so only update when required
		if(! clientSideChar.bHotKeysUpdated || clientSideChar.deployable != dep.class)
			clientSideChar.deployableHotkey = GetHotKey("equipDeployable");

		clientSideChar.deployable = dep.class;

		if(character.deployable != None && dep == character.deployable)
		{
			clientSideChar.bDeployableActive = true;
			clientSideChar.deployableState = character.deployable.lastTestResult; // test if deployable can be deployed
		}
	}
	else
	{
		clientSideChar.deployable = None;
	}

	// Grenades
	if(character.altWeapon != None)
	{
		// this is slow so only update when required
		if(! clientSideChar.bHotKeysUpdated || clientSideChar.grenades.type != character.altWeapon.class)
			clientSideChar.grenades.hotkey = GetHotKey("altFire");

		clientSideChar.grenades.type = character.altWeapon.class;
		clientSideChar.grenades.ammo = character.altWeapon.ammoCount;
		clientSideChar.grenades.bCanFire = character.altWeapon.canFire();
		clientSideChar.grenades.refireTime = 1.0 / character.altWeapon.roundsPerSecond;
		clientSideChar.grenades.timeSinceLastFire = Level.TimeSeconds - character.altWeapon.lastFireTime;
	}
	else
	{
		clientSideChar.grenades.type = None;
	}

	if(character.carryableReference != None)
	{
		if(! clientSideChar.bHotKeysUpdated || clientSideChar.carryable != character.carryableReference.class)
		{
			if(character.carryableReference.default.bIsWeaponType)
				clientSideChar.carryableHotkey = GetHotKey("equipCarryable");
			else
				clientSideChar.carryableHotkey = "";
		}

		clientSideChar.carryable = character.carryableReference.class;
		clientSideChar.numCarryables = character.numCarryables - character.numPermanentCarryables;
	}
	else
	{
		clientSideChar.carryable = None;
		clientSideChar.numCarryables = 0;
	}

	if(character.pack != None)
	{
		if(! clientSideChar.bHotKeysUpdated || clientSideChar.pack != character.pack.class)
			clientSideChar.packHotkey = GetHotKey("activatePack");

		clientSideChar.pack = character.pack.class;
		if(character.pack.IsInState('Recharging'))
		{
			clientSideChar.packState = PS_Recharging;
			clientSideChar.packProgressRatio = character.pack.rechargingAlpha;
		}
		else if(character.pack.IsInState('Active'))
		{
			clientSideChar.packState = PS_Active;
			clientSideChar.packProgressRatio = character.pack.progressedActiveTime / character.pack.durationSeconds;
		}
		else
		{
			clientSideChar.packState = PS_Ready;
			clientSideChar.packProgressRatio = 1;
		}			
	}
	else
		clientSideChar.pack = None;

	clientSideChar.bHotkeysUpdated = true;
}

simulated function UpdateHUDTargetData()
{
	local Character character;
	local Actor target;
	local TribesReplicationInfo targetPRI;
	local Rook targetRook;
	local Character targetCharacter;
	local int i;
	local Array<Vector> useablePoints;
	local Array<Byte> useablePointsValid;
	local bool pointValid;
	local Vector closestPoint;
	local float shortestDistance;

	character = GetCharacter();

	// default values:
	clientSideChar.targetType = None;
	clientSideChar.targetLabel = "";
	clientSideChar.targetHealth = -1;
	clientSideChar.targetHealthMax = -1;
	clientSideChar.targetShield = -1;
	clientSideChar.targetShieldMax = -1;
	clientSideChar.targetDistance = 0;
	clientSideChar.targetTeam = None;
	clientSideChar.targetCanBeDamaged = true;
	clientSideChar.useableObjectLocation.X = -1;
	clientSideChar.useableObjectLocation.Y = -1;
	clientSideChar.bHitObject = false;
	clientSideChar.lastHitObjectTime = 0;
	clientSideChar.bUseableObjectPowered = true;

	if(character == None)
		return;

	// Was there a hit registered with the character?
	if(character.bHitRegistered)
	{
		clientSideChar.bHitObject = true;
		clientSideChar.lastHitObjectTime = Level.TimeSeconds;
		character.bHitRegistered = false;
	}

	// Get the actor under the cursor and set info for it
	target = Controller.GetIdentify();
	if(target != None)
	{
		if(Character(target) != None && Character(target).tribesReplicationInfo != None)
			targetPRI = Character(target).tribesReplicationInfo;
		
		targetCharacter = Character(target);
		targetRook = Rook(target);

		clientSideChar.targetFunctionalHealthThreshold = 0;
		if(targetPRI != None)
		{
			clientSideChar.targetType = targetPRI.class;
			clientSideChar.targetLabel = targetPRI.playerName;
			clientSideChar.targetHealth = targetPRI.health;
			clientSideChar.targetHealthMax = targetCharacter.healthMaximum;
			clientSideChar.targetDistance = vSize(targetCharacter.Location - character.location);
			if(targetCharacter.Team() == None)
			{
				clientSideChar.targetTeam = None;
				clientSideChar.targetTeamAlignment = TA_Neutral;
			}
			else
			{
				clientSideChar.targetTeam = targetCharacter.team().class;
				if(character.IsFriendly(targetCharacter))
					clientSideChar.targetTeamAlignment = TA_Friendly;
				else
					clientSideChar.targetTeamAlignment = TA_Enemy;
			}
			clientSideChar.targetCanBeDamaged = true;
		}
		else if(targetRook != None)
		{
			clientSideChar.targetType = targetRook.class;
			clientSideChar.targetLabel = targetRook.GetHumanReadableName();
			clientSideChar.targetHealth = targetRook.health;
			clientSideChar.targetHealthMax = targetRook.healthMaximum;
			clientSideChar.targetDistance = vSize(targetRook.Location - character.location);
			if(targetRook.Team() == None)
			{
				clientSideChar.targetTeam = None;
				clientSideChar.targetTeamAlignment = TA_Neutral;
			}
			else
			{
				clientSideChar.targetTeam = targetRook.team().class;
				if(character.IsFriendly(targetRook))
					clientSideChar.targetTeamAlignment = TA_Friendly;
				else
					clientSideChar.targetTeamAlignment = TA_Enemy;
			}
			clientSideChar.targetCanBeDamaged = targetRook.bCanBeDamaged;
			if(targetRook.personalShield != None)
			{
				clientSideChar.targetShield = targetRook.personalShield.Health;
				clientSideChar.targetShieldMax = targetRook.personalShield.Max;
			}

			if(BaseDevice(targetRook) != None)
			{
				clientSideChar.targetFunctionalHealthThreshold = BaseDevice(targetRook).functionalHealthThreshold;
				clientSideChar.bUseableObjectPowered = BaseDevice(targetRook).isPowered() || BaseDevice(targetRook).isFunctional();
			}

			if(Controller.IsFriendly(targetRook))
			{
				for(i = 0; i < class'Rook'.const.MAX_USEABLE_POINTS; ++i)
				{
					if(targetRook.UseablePointsValid[i] != UP_Unused)
					{
						// hack for vehicle points which move unlikje others
						if(Vehicle(targetRook) != None)
							useablePoints[i] = Vehicle(targetRook).getVehicleUseablePoint(i);
						else
							useablePoints[i] = targetRook.UseablePoints[i];							
						if(targetRook.UseablePointsValid[i] == UP_Valid)
							useablePointsValid[i] = 1;
						else
							useablePointsValid[i] = 0;
					}
				}
			}
		}
		else if(target.IsA('AccessTerminal'))
		{
			// special case just for useable points on an access terminal
			useablePoints[0] = AccessTerminal(target).atuo.Location;
			if(AccessTerminal(target).used)
				useablePointsValid[0] = 0;
			else
				useablePointsValid[0] = 1;
		}

		// check the useables to see if we have an identified useable target
		if( controller.PromptingObjectClass == None && 
			controller.PromptingUseableObject == None && 
			useablePoints.Length > 0)
		{
			shortestDistance = vSize(useablePoints[0] - character.Location);
			closestPoint = useablePoints[0];
			pointValid = (useablePointsValid[0] == 1);
			for(i = 1; i < useablePoints.Length; ++i)
			{
				if(shortestDistance > vSize(useablePoints[i] - character.Location))
				{
					shortestDistance = vSize(useablePoints[i] - character.Location);
					closestPoint = useablePoints[i];
					pointValid = (useablePointsValid[i] == 1);					
				}
			}

			clientSideChar.useableObjectLocation = closestPoint;
			clientSideChar.bEnabledForUse = pointValid;
			controller.WorldToScreen(clientSideChar.useableObjectLocation);
		}
	}
}

simulated function UpdateObjectiveList(ObjectivesList list)
{
	local int i;
	local Vector screenPos, playerLocation;
	local ClientSideCharacter.ClientObjectiveInfo clientObjectiveInfo;
	local ClientSideCharacter.ClientObjectiveActorInfo clientActorInfo;
	local ObjectiveInfo objInfo;

	objInfo = list.first();
	while (objInfo != None)
	{
		if(Controller != None)
		{
			if(Controller.Pawn != None)
				playerLocation = Controller.Pawn.Location;
			else
				playerLocation = Controller.Location;
		}

		// Add objective data
		clientObjectiveInfo.description = objInfo.getDescription();
		clientObjectiveInfo.status = objInfo.status;
		clientObjectiveInfo.type = objInfo.type;
		clientObjectiveInfo.radarInfoClass = objInfo.radarInfoClass;
		clientObjectiveInfo.state = objInfo.state;
		clientObjectiveInfo.IsFriendly = true;
		clientObjectiveInfo.TeamInfoClass = objInfo.TeamInfoClass;
		clientObjectiveInfo.bFlashing = objInfo.bShouldFlash;
		if(objInfo.numObjectiveActors > 0)
			clientObjectiveInfo.IsFriendly = (objInfo.allyType[0] == EAllyType.AllyType_Friendly);
		clientSideChar.ObjectiveData[clientSideChar.ObjectiveData.Length] = clientObjectiveInfo;

		// for each actor, add objective actor data
		for (i = 0; i < objInfo.numObjectiveActors; ++i)
		{
			// index into the objective data, see above
			clientActorInfo.objectiveDataIndex = clientSideChar.ObjectiveData.Length - 1;

			clientActorInfo.XPosition = objInfo.pos[i].X;
			clientActorInfo.YPosition = objInfo.pos[i].Y;

			clientActorInfo.Distance = VSize(playerLocation - objInfo.pos[i]);

			if (Controller != None)
			{
				screenPos = Controller.calculateScreenPosition(objInfo.class, objInfo.pos[i]);
				clientActorInfo.ScreenX = screenPos.X;
				clientActorInfo.ScreenY = screenPos.Y;
			}

			clientActorInfo.TeamInfoClass = objInfo.TeamInfoClasses[i];

			clientActorInfo.IsFriendly = (objInfo.allyType[i] == EAllyType.AllyType_Friendly);
			if(objInfo.actorStateOverride.Length > i) 
				clientActorInfo.bFlashing = (objInfo.actorStateOverride[i] != StateType_None);
			else
				clientActorInfo.bFlashing = false;

			clientActorInfo.Height = Controller.calculateHeight(objInfo.pos[i].Z);

			clientSideChar.ObjectiveActorData[clientSideChar.ObjectiveActorData.Length] = clientActorInfo;

			// marker data
			if(Controller.IsSinglePlayer() && objInfo.objectiveActors[i] != None && Controller != None)
				Controller.HUDManager.activeHUD.AddHUDMarker(objInfo.objectiveActors[i], objInfo.state, objInfo.radarInfoClass);
		}

		objInfo = objInfo.next;
	}
}


simulated function UpdateHUDObjectiveData()
{
	local Character character;
	local TribesReplicationInfo TRI;

	character = GetCharacter();
	TRI = TribesReplicationInfo(Controller.PlayerReplicationInfo);

	// Radar objective information
	clientSideChar.ObjectiveData.Length = 0;
	clientSideChar.ObjectiveActorData.Length = 0;

	// Update objectives
	if(Controller.objectives != None)
		UpdateObjectiveList(Controller.objectives);

	if(TRI != None)
	{
		if(TRI.team != None && TRI.team.objectives != None)
			UpdateObjectiveList(TRI.team.objectives);
	}
	else if(character != None)
	{
		if (character.team() != None && character.team().objectives != None)
			UpdateObjectiveList(character.team().objectives);
	}
}

simulated function UpdateHUDPromptData()
{
	local Character character;
	local String potentialEquipmentName, weaponName, packName;

	character = GetCharacter();

	if(character == None)
	{
		clientSideChar.promptText = "";
		return;
	}

	clientSideChar.bCanBeUsed = false;

	if((Controller.PromptingObjectClass != None || Controller.PromptingUseableObject != None) && Controller.Pawn.IsA('Character'))
	{
		// we have a useable object

		// hacky: if the prompt object is of type AccessTerminalUseableObject, get the prompt direclty
		if( Controller.PromptingUseableObject != None && 
			Controller.PromptingUseableObject.IsA('AccessTerminalUseableObject') &&
			Controller.PromptingUseableObject.CanBeUsedBy(character))
				clientSideChar.promptText =	Controller.PromptingUseableObject.prompt;
		else if (ClassIsChildOf(Controller.PromptingObjectClass, class'InventoryStationAccess') && !Controller.IsSinglePlayer() && controller.PromptingObjectPromptIndex == 0)
			clientSideChar.promptText =	Controller.PromptingObjectClass.static.getPrompt(controller.PromptingObjectPromptIndex, controller.PromptingDataClass)
			   $ replaceStr(quickKeyText, Controller.Player.InteractionMaster.GetKeyFromBinding("Button bLoadoutSelection", true));
		else
			clientSideChar.promptText =	Controller.PromptingObjectClass.static.getPrompt(controller.PromptingObjectPromptIndex, controller.PromptingDataClass);

		clientSideChar.useableObjectLocation = controller.PromptingObjectLocation;
		controller.WorldToScreen(clientSideChar.useableObjectLocation);
		clientSideChar.bCanBeUsed = Controller.PromptingObjectCanBeUsed;
		clientSideChar.bEnabledForUse = Controller.PromptingObjectCanBeUsed;
		if(ClassIsChildOf(controller.PromptingObjectClass, class'BaseDeviceAccess'))
			clientSideChar.bUseableObjectPowered = (controller.PromptingObjectPromptIndex != 1);
		else
			clientSideChar.bUseableObjectPowered = true;
//		if(clientSideChar.promptText == "" || clientSideChar.bCanBeUsed == false)
//			clientSideChar.useableObjectLocation.X = -1;	// no prompt || no use = no marker
	}
	else if(character.potentialEquipment != None)
	{
		clientSideChar.promptText = character.potentialEquipment.prompt;
		potentialEquipmentName = character.potentialEquipment.localizedName;
	}
	else if (Controller.lowPriorityPromptTimeout > 0 && Controller.lowPriorityPromptText != "")
	{
		clientSideChar.promptText = Controller.lowPriorityPromptText;
	}
	else
		clientSideChar.promptText = "";

	if(character.weapon != None)
		weaponName = character.Weapon.localizedName;
	if(character.pack != None)
		packName = character.pack.localizedName;

	if(clientSideChar.promptText != "")
		clientSideChar.promptText = replaceStr(clientSideChar.promptText, Controller.Player.InteractionMaster.GetKeyFromBinding("Use", true), weaponName, potentialEquipmentName, packName);
	//	ReplacePromptKeyBinds(clientSideChar.promptText);
}

simulated function UpdateHUDRadarData()
{
	local Character character;

	character = GetCharacter();

	if(character == None)
		return;

	if (character.bDontAllowCommandScreen)
		clientSideChar.ShowCommandMapKeyText = "";
	else if(clientSideChar.ShowCommandMapKeyText == "")
		clientSideChar.ShowCommandMapKeyText = GetHotKey("Button bObjectives");
	clientSideChar.zoomFactor = Controller.radarZoomScales[Controller.radarZoomIndex];

	if(Controller.Rook != None)
		clientSideChar.charLocation = Controller.Rook.Location;
	clientSideChar.charRotation = Controller.Rotation;
}

simulated function AddHUDMarker(Actor MarkedActor, optional int state, optional class<RadarInfo> radarInfoClass)
{
	local Vector screenPos;
	local ClientSideCharacter.MarkerData NewMarker;
	local Vector WorldLocation;

	if(MarkedActor == Controller.Pawn)
		return;

	WorldLocation = MarkedActor.Location;
	// rook specific changes
	if(Rook(MarkedActor) != None)
	{
		WorldLocation = Rook(MarkedActor).GetObjectiveLocation();
		NewMarker.Type = class<RadarInfo>(Rook(MarkedActor).GetRadarInfoClass());
	}
	
	if(radarInfoClass != None)
		NewMarker.Type = radarInfoClass;

	if(NewMarker.Type == None)
		return;

	// check for occlusion
	if(newMarker.Type.default.bOccluded && Controller.Pawn != None)
	{
		if(! FastTrace(WorldLocation, Controller.Pawn.Location + Controller.Pawn.EyePosition()))
			return;
	}

	// screen position
	screenPos = Controller.calculateScreenPosition(NewMarker.Type, WorldLocation);
	NewMarker.ScreenX = screenPos.X;
	NewMarker.ScreenY = screenPos.Y;
	// State
	NewMarker.State = 0;
	// Friendly
	NewMarker.Friendly = Controller.IsFriendly(MarkedActor);
	if(Rook(MarkedActor) != None && Rook(MarkedActor).team() != None)
		NewMarker.Team = Rook(MarkedActor).team().class;
	else
		NewMarker.Team = None;

	clientSideChar.markers[clientSideChar.markers.Length] = NewMarker;
}

simulated function UpdateHUDSensorData()
{
	local SensorListNode sln;
	local int count;
	local TribesReplicationInfo TRI;
	local ClientSideCharacter.POIInfo NewInfo;

	//debugSensorSystem();

	if(controller.bTeamMarkerColors)
		clientSideChar.UserPrefColorType = COLOR_Team;
	else
		clientSideChar.UserPrefColorType = COLOR_Relative;

	// update points of interest list in the client side character
	clientSideChar.POIData.Length = 0;
	for(count = 0; count < Controller.PointsOfInterest.Length; ++count)
	{
		if(Controller.PointsOfInterest[count].bPointEnabled)
		{
			NewInfo.RadarInfoClass = class<RadarInfo>(Controller.PointsOfInterest[count].GetRadarInfoClass());
			NewInfo.Location = Controller.PointsOfInterest[count].Location;
			NewInfo.LabelText = Controller.PointsOfInterest[count].LabelText;

			clientSideChar.POIData[clientSideChar.POIData.Length] = NewInfo;
		}
	}

	TRI = TribesReplicationInfo(Controller.PlayerReplicationInfo);

	if(TRI != None && TRI.team != None)
		clientSideChar.bSensorGridFunctional = TRI.team.bSensorGridFunctional;

	// Fill in the detected rooks marker array
	clientSideChar.markers.Length = 0;
	for(count = 0; count < Controller.RenderedRooks.Length; ++count)
	{
		if(Rook(Controller.RenderedRooks[count]) != None && Rook(Controller.RenderedRooks[count]).ShouldBeMarked(Controller))
			AddHUDMarker(Controller.RenderedRooks[count]);
	}

	// its important that the objective data is updated AFTER the sensor data
	UpdateHUDObjectiveData();

	// Fill in the client side character data for detected allies
	count = 0;
	sln = Controller.detectedFriendlyList;

	while (sln != None)
	{
		if (sln.relevantLastUpdate)
		{
			clientSideChar.detectedAlliesClass[count] = sln.sensedRookClass;
			clientSideChar.detectedAlliesXPosition[count] = sln.getXPosition();
			clientSideChar.detectedAlliesYPosition[count] = sln.getYPosition();
			clientSideChar.detectedAlliesHeight[count] = sln.getHeight();

			clientSideChar.detectedAlliesState[count] = 0;

			++count;
		}

		sln = sln.next;
	}

	clientSideChar.detectedAlliesClass.length = count;
	clientSideChar.detectedAlliesXPosition.length = count;
	clientSideChar.detectedAlliesYPosition.length = count;
	clientSideChar.detectedAlliesHeight.length = count;

	// Fill in the client side character data for detected enemies
	count = 0;
	sln = Controller.detectedEnemyList;

	while (sln != None)
	{
		if (sln.relevantLastUpdate)
		{
			clientSideChar.detectedEnemiesTeam[count] = sln.sensedRookTeamClass;
			clientSideChar.detectedEnemiesClass[count] = sln.sensedRookClass;
			clientSideChar.detectedEnemiesXPosition[count] = sln.getXPosition();
			clientSideChar.detectedEnemiesYPosition[count] = sln.getYPosition();
			clientSideChar.detectedEnemiesHeight[count] = sln.getHeight();

			clientSideChar.detectedEnemiesState[count] = 0;

			++count;
		}

		sln = sln.next;
	}

	clientSideChar.detectedEnemiesClass.length = count;
	clientSideChar.detectedEnemiesXPosition.length = count;
	clientSideChar.detectedEnemiesYPosition.length = count;
	clientSideChar.detectedEnemiesHeight.length = count;
}

simulated function UpdateHUDGameData()
{
	local ModeInfo mode;
	local TeamInfo ownTeam, otherTeam;

	// Set the 'ownTeamColor' based on the character initially, we ned it in SP
	if(controller.character != None && controller.character.team() != None)
		clientSideChar.ownTeamColor = controller.character.team().TeamColor;

	mode = ModeInfo(Controller.Level.Game);
	if (clientSideChar.gameClass == None && Controller.GameReplicationInfo != None)
		clientSideChar.gameClass = class<GameInfo>(DynamicLoadObject(Controller.GameReplicationInfo.GameClass, class'Class'));

	if (clientSideChar.gameClass != None && ClassIsChildOf(clientSideChar.gameClass, class'MultiplayerGameInfo'))
	{
		ownTeam = controller.getOwnTeam();
		if ( ownTeam != None)
		{
			clientSideChar.ownTeam = ownTeam.localizedName;
			clientSideChar.ownTeamIcon = ownTeam.ownershipMaterial;
			clientSideChar.ownTeamScore = ownTeam.Score;
			clientSideChar.ownTeamColor = ownTeam.TeamColor;
			clientSideChar.ownTeamHighlightColor = ownTeam.TeamHighlightColor;

			// Relative colors are determined only by own team
			clientSideChar.relativeFriendlyTeamColor = ownTeam.relativeFriendlyTeamColor;
			clientSideChar.relativeFriendlyHighlightColor = ownTeam.relativeFriendlyHighlightColor;
			clientSideChar.relativeEnemyTeamColor = ownTeam.relativeEnemyTeamColor;
			clientSideChar.relativeEnemyHighlightColor = ownTeam.relativeEnemyHighlightColor;

			otherTeam = controller.getOtherTeam();
			if (otherTeam != None)
			{
				clientSideChar.otherTeam = otherTeam.localizedName;
				clientSideChar.otherTeamIcon = otherTeam.ownershipMaterial;
				clientSideChar.otherTeamScore = otherTeam.Score;
				clientSideChar.otherTeamColor = otherTeam.TeamColor;
				clientSideChar.otherTeamHighlightColor = otherTeam.TeamHighlightColor;
			}

			if (mode != None)
			{
				clientSideChar.matchScoreLimit = mode.scoreLimit;
			}
		}

		if(Controller.GameReplicationInfo != None)
			clientSideChar.bAwaitingTournamentStart = TribesGameReplicationInfo(Controller.GameReplicationInfo).bAwaitingTournamentStart;
	}

	if(ClassIsChildOf(clientSideChar.gameClass, class'SinglePlayerGameInfo'))
		clientSideChar.levelDescription = Level.Summary.Description;
	else if(clientSideChar.gameClass != None)
		clientSideChar.levelDescription = clientSideChar.gameClass.default.GameDescription;

	// personal score data
	if(TribesReplicationInfo(Controller.PlayerReplicationInfo) != None)
	{
		clientSideChar.OffenseScore = TribesReplicationInfo(Controller.PlayerReplicationInfo).OffenseScore;
		clientSideChar.DefenseScore = TribesReplicationInfo(Controller.PlayerReplicationInfo).DefenseScore;
		clientSideChar.StyleScore = TribesReplicationInfo(Controller.PlayerReplicationInfo).StyleScore;
	}
}

defaultproperties
{
	bAllowCommandHUDSwitching = false
	quickKeyText = "¼Press '%1' to access quick favorites"

	TagBindings(0)=(Tag="<USE>",BindingText="Use")
	TagBindings(1)=(Tag="<JUMP>",BindingText="Jump")
	TagBindings(2)=(Tag="<FIRE>",BindingText="Fire")
	TagBindings(3)=(Tag="<ACTIVATE>",BindingText="activatePack")
	TagBindings(4)=(Tag="<THROWGRENADE>",BindingText="altFire")
	TagBindings(5)=(Tag="<FORWARD>",BindingText="MoveForward")
	TagBindings(6)=(Tag="<BACK>",BindingText="MoveBackward")
	TagBindings(7)=(Tag="<LEFT>",BindingText="StrafeLeft")
	TagBindings(8)=(Tag="<RIGHT>",BindingText="StrafeRight")
	TagBindings(9)=(Tag="<JET>",BindingText="Jetpack")
	TagBindings(10)=(Tag="<TILDE>",BindingText="SwitchToFallbackWeapon")
	TagBindings(11)=(Tag="<SKI>",BindingText="Ski")
	TagBindings(12)=(Tag="<MAP>",BindingText="Button bObjectives")
	TagBindings(13)=(Tag="<DEPLOY>",BindingText="equipDeployable")
	TagBindings(14)=(Tag="<ZOOM>",BindingText="Button bZoom")
	TagBindings(15)=(Tag="<ZOOMCYCLE>",BindingText="CycleZoomLevel")
	TagBindings(16)=(Tag="<ESCAPE>",BindingText="ShowEscapeMenu")
	TagBindings(17)=(Tag="<HELP>",BindingText="ShowHelpScreen")
}
