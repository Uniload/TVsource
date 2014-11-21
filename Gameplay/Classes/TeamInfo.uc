class TeamInfo extends Engine.Info
	placeable
	native;

const MAX_RESPAWN_VEHICLES_DEFINE = 10;

struct native RoleData
{
	var() class<CombatRole>	role							"The role that this data applies to";
	var() Mesh				mesh							"The mesh used for characters with this role when playing for this team";
	var() Mesh				femaleMesh						"The mesh used for female characters with this role when playing for this team";
	var() class<Jetpack>	jetpack							"The jetpack used for characters with this role when playing for this team";
	var() class<Jetpack>	femaleJetpack					"The jetpack mesh used for female characters with this role when playing for this team";
	var() Mesh				armsMesh						"The arms used for the characters with this role when playing for this team";
	var() Material			armorIcon						"The Icon representation for this combat roles armor";
};

var() Array<RoleData>				combatRoleData;
var() localized string				localizedName;
var() Material						ownershipMaterial			"The material used for the ownership badge on Base Devices owned by this team";
var() Material						baseDeviceIllumMaterial		"The material used for self-illumination on Base Devices owned by this team";
var() Material						altOwnershipMaterial		"An alternate material used for the ownership badge on Base Devices owned by this team; if specified, overrides ownershipMaterial";
var() Material						altBaseDeviceIllumMaterial	"An alternate material used for self-illumination on Base Devices owned by this team; if specified, overrides baseDeviceIllumMaterial";
var() Color							territoryTendrilColor		"Color of this team's terriory capture tendril";

var float							objectivesUpdateRate;
var ObjectivesList					objectives;				// Team objectives
var int								score;
var bool							bWonLastRound;

var const int						MAX_BASES;
var	array<BaseInfo>					bases;					// Bases available for this team

// Parallel arrays
var	BaseInfo						respawnBases[10];			// bases which are available for respawn
var string							respawnBaseNames[10];		// names of the respawn bases
var Vector							respawnBaseLocations[10];	// locations of the respawn bases

// 10 has been choosen - should be maximum number of respawn point vehicles available in any level
var const int						MAX_RESPAWN_VEHICLES;
var Vehicle							respawnVehicles[MAX_RESPAWN_VEHICLES_DEFINE];

//var private SensorTower teamSensor;
var private Array<SensorTower> sensorGrid;
var(SensorSystem) float sensorGridRate;
var private float lastUpdateTime;
var private Array<Rook> detectedEnemies;
var private Array<Rook> detectedFriendlies;
var bool bSensorGridFunctional;

var int numPlayerStarts;

var() Material buggySkin;
var() Material podSkin;
var() Material tankSkin;
var() Material assaultShipSkin;

var() TeamInfo onlyDamagedByTeam			"Only the specified team will be able to damage members of this team.";

var bool bNoMoreCarryables;

var() color TeamColor;
var() color TeamHighlightColor;
var() color RelativeFriendlyTeamColor;
var() color RelativeFriendlyHighlightColor;
var() color RelativeEnemyTeamColor;
var() color RelativeEnemyHighlightColor;

var int TeamIndex;

replication
{
	reliable if (ROLE == ROLE_Authority)
		objectives, score, ownershipMaterial, sensorGridRate, bWonLastRound, 
		respawnVehicles, respawnBases, /*respawnBaseNames, respawnBaseLocations,*/
		bNoMoreCarryables, bSensorGridFunctional, TeamIndex;
}


// PostBeginPlay
function PostBeginPlay()
{
	Super.PostBeginPlay();

	// init objectives
	objectives = spawn(class'ObjectivesList');

	if (ownershipMaterial == None)
		ownershipMaterial = Material(DynamicLoadObject("BaseObjects.OwnershipScreen", class'Shader'));
}

function evaluatePlayerStarts()
{
	local PlayerStart p;

	// Figure out how many playerStarts are left for this team after any filtering has taken place
	ForEach DynamicActors(class'PlayerStart', p)
	{
		if (p.team == self || (p.baseInfo != None && p.baseInfo.team == self))
			numPlayerStarts++;
	}
}

simulated function String GetHumanReadableName()
{
	return localizedName;
}

// isFriendly
// returns true if the given team is friendly to this team
simulated function bool isFriendly(TeamInfo t)
{
	return t == self || t == None;
}

// getMeshForRole
// returns the mesh that a character on this team should use for the given role
simulated function Mesh getMeshForRole(class<CombatRole> c, bool bIsFemale)
{
	local int i;

	for (i = 0; i < combatRoleData.Length; i++)
	{
		if (combatRoleData[i].role == c)
		{
			if (bIsFemale)
				return combatRoleData[i].femaleMesh;
			else
				return combatRoleData[i].mesh;
		}
	}
}

// getJetpackMeshForRole
// returns the jetpack mesh that a character of this team should use for the given role
simulated function Jetpack getJetpackForRole(Actor ownerActor, class<CombatRole> c, bool bIsFemale)
{
	local int i;

	for (i = 0; i < combatRoleData.Length; i++)
	{
		if (combatRoleData[i].role == c)
		{
			if (bIsFemale)
			{
				if (combatRoleData[i].femaleJetpack != None)
					return Spawn(combatRoleData[i].femaleJetpack, ownerActor);
				else
					return None;
			}
			else
			{
				if (combatRoleData[i].jetpack != None)
					return Spawn(combatRoleData[i].jetpack, ownerActor);
				else
					return None;
			}
		}
	}
}

// getArmsMeshForRole
// returns the arms mesh that a character of this team should use for the given role
simulated function Mesh getArmsMeshForRole(class<CombatRole> c)
{
	local int i;

	for (i = 0; i < combatRoleData.Length; i++)
		if (combatRoleData[i].role == c)
			return combatRoleData[i].armsMesh;
}

// GetArmorIconForRole
// Returns the armor icon which this team should use for the given role
simulated function Material GetArmorIconForRole(class<CombatRole> c)
{
	local int i;

	for (i = 0; i < combatRoleData.Length; i++)
		if (combatRoleData[i].role == c)
			return combatRoleData[i].armorIcon;
}

function Tick(float Delta)
{
	// Level.IsEntry doesnt always work for some reason. 
	// Have to check the outer name
	if(Level.Outer.Name == 'Entry')
		return;

	objectives.updateObjectives(objectivesUpdateRate, self);
	tickSensors();
}

// -------------------------------------------------------------------------------------
// Sensor System
// -------------------------------------------------------------------------------------

function addTeamSensor(SensorTower newTeamSensor)
{
	local int i;

	for (i = 0; i < sensorGrid.Length; ++i)
		if (sensorGrid[i] == newTeamSensor)
			return;

	sensorGrid[sensorGrid.Length] = newTeamSensor;
}

function removeTeamSensorSensorTower(SensorTower oldTeamSensor)
{
	local int i;

	for (i = 0; i < sensorGrid.Length; ++i)
	{
		if (sensorGrid[i] == oldTeamSensor)
		{
			sensorGrid.Remove(i, 1);
			return;
		}
	}
}

function bool sensorGridFunctional()
{
	local int i;

	for (i = 0; i < sensorGrid.Length; ++i)
		if (sensorGrid[i].isFunctional())
		{
			bSensorGridFunctional = true;
			return true;
		}

	bSensorGridFunctional = false;
	return false;
}

//function setTeamSensor(SensorTower newTeamSensor)
//{
//	teamSensor = newTeamSensor;
//}

// start point for all sensor ticking. we can optimise sensor code by making it native as neccesary in here
native function tickSensors();

function bool sensorIsFriendlyRook(Rook r)
{
	// use last occupant team if vehicle
	if (r.isA('Vehicle') && Vehicle(r).lastOccupantTeam != None)
		return isFriendly(Vehicle(r).lastOccupantTeam);

	return isFriendlyRook(r);
}


function bool isFriendlyRook(Rook r) // Handles vehicles (i.e. an enemy vehicle with a friendly driver is a friend)
{
	if (r.getControllingCharacter() != None)
		return isFriendly(r.getControllingCharacter().team());
	else
		return isFriendly(r.team());
}

event updateSensors()
{
	local Rook currRook;
	local Controller c;
	local PlayerCharacterController pcc;

	currRook = Rook(Level.pawnList);

	detectedEnemies.Length = 0;
	detectedFriendlies.Length = 0;

	while (currRook != None)
	{
		if (currRook.canBeSensed() && currRook.isAlive())
		{
			if (sensorIsFriendlyRook(currRook))
			{
				detectedFriendlies[detectedFriendlies.Length] = currRook;
			}
			else if (sensorGridFunctional() && currRook.bIsDetectableByEnemies)
			{
				detectedEnemies[detectedEnemies.Length] = currRook;
			}
		}

		currRook = Rook(currRook.nextPawn);
	}

	// Update the sensor info for each player member of the team
	for (c = Level.ControllerList; c != None; c = c.nextController)
	{
		pcc = PlayerCharacterController(c);

		if (pcc != None && pcc.Character != None && isFriendly(pcc.Character.team()))
			updateTeamMemberSensorInfo(pcc);
	}
}

function updateTeamMemberSensorInfo(PlayerCharacterController pcc)
{
	local SensorListNode sln;
	local int i;

	sln = pcc.detectedEnemyList;

	// Update the currently sensed enemies
	while (sln != None)
	{
		if (pcc.Pawn == sln.sensedRook || class'Pawn'.static.checkDead(sln.sensedRook))
		{
			pcc.removeDetectedEnemy(sln);
		}
		else
		{
			for (i = 0; i < detectedEnemies.length; ++i)
			{
				if (detectedEnemies[i] == sln.sensedRook)
				{
					sln.update();
					break;
				}
			}

			// If the rook is no longer being detected remove it from the list
			if (i == detectedEnemies.length)
				pcc.removeDetectedEnemy(sln);
		}

		sln = sln.next;
	}

	// Add any newly detected enemies to the characters detectedEnemyList
	for (i = 0; i < detectedEnemies.length; ++i)
	{
		// If this rook hasn't been updated yet
		if (!detectedEnemies[i].sensorUpdateFlag)
			pcc.addDetectedEnemy(detectedEnemies[i]);

		detectedEnemies[i].sensorUpdateFlag = false;
	}

	sln = pcc.detectedFriendlyList;

	// Update the currently sensed friendlies
	while (sln != None)
	{
		if (pcc.Pawn == sln.sensedRook || class'Pawn'.static.checkDead(sln.sensedRook))
		{
			pcc.removeDetectedFriendly(sln);
		}
		else
		{
			for (i = 0; i < detectedFriendlies.length; ++i)
			{
				if (detectedFriendlies[i] == sln.sensedRook)
				{
					sln.update();
					break;
				}
			}

			// If the rook is no longer being detected remove it from the list
			if (i == detectedFriendlies.length)
				pcc.removeDetectedFriendly(sln);
		}

		sln = sln.next;
	}

	// Add any newly detected friendlies to the characters detectedFriendlyList
	for (i = 0; i < detectedFriendlies.length; ++i)
	{
		// If this rook hasn't been updated yet
		if (!detectedFriendlies[i].sensorUpdateFlag)
			pcc.addDetectedFriendly(detectedFriendlies[i]);

		detectedFriendlies[i].sensorUpdateFlag = false;
	}
}

// -------------------------------------------------------------------------------------
// End Sensor System
// -------------------------------------------------------------------------------------

// -----------------------------------
// Vehicle Respawn
//

function addVehicleRespawn(Vehicle respawnVehicle)
{
	local int index;

	// verify not already there
	for (index = 0; index < MAX_RESPAWN_VEHICLES; ++index)
	{
		if (respawnVehicles[index] == respawnVehicle)
		{
			warn("attempted to add" @ respawnVehicle @ "to respawn vehicle list but it is already there");
			return;
		}
	}

	// add it
	for (index = 0; index < MAX_RESPAWN_VEHICLES; ++index)
	{
		if (respawnVehicles[index] == None)
		{
			respawnVehicles[index] = respawnVehicle;
			break;
		}
	}
	if (index == MAX_RESPAWN_VEHICLES)
		warn("exceeded size of respawn vehicle array");

	Log("added vehicle respawn" @ respawnVehicle @ "to" @ self);
}

// Can be called even if respawnVehicle has already been removed.
function removeVehicleRespawn(Vehicle respawnVehicle)
{
	local int index;

	// find the vehicle and remove it
	for (index = 0; index < MAX_RESPAWN_VEHICLES; index++)
	{
		if (respawnVehicles[index] == respawnVehicle)
		{
			respawnVehicles[index] = None;
			break;
		}
	}
}

simulated function bool validVehicleRespawnIndex(int index)
{
	return respawnVehicles[index] != None && respawnVehicles[index].canCharacterRespawnAt();
}

simulated function int getNumVehicleRespawns()
{
	local int index;
	local int result;

	for (index = 0; index < MAX_RESPAWN_VEHICLES; index++)
		if (respawnVehicles[index] != None)
			++result;

	return result;
}

// 
// End Vehicle Respawn
// -----------------------------------

// -----------------------------------
// Bases
//

function addBase(BaseInfo base)
{
	local int i;

	// check first, to see if we have the base
	for(i = 0; i < bases.Length; ++i)
	{
		if(bases[i] == base)
			return;
	}

	// dont already have the base, add it
	bases[bases.Length] = base;
	Log("Added base "$base);

	// update the respawn bases & names array
	if(base.bValidRespawnBase && base.spawnArray != None)
	{
		for(i = 0; i < MAX_BASES; ++i)
		{
			if (respawnBases[i] == None)
			{
				Log("Added respawn base "$base$ " at index "$i);
				respawnBases[i] = base;
				respawnBaseNames[i] = string(respawnBases[i].label);
				respawnBaseLocations[i] = respawnBases[i].spawnArray.Location;
				break;
			}
		}
	}
}

function removeBase(BaseInfo base)
{
	local int i;

	// find the base and remove it, and allow multiple removes
	for(i = 0; i < bases.Length; i++)
	{
		if(bases[i] == base)
			bases.Remove(i, 1);
	}

	// update the base names array
	if(base.bValidRespawnBase)
	{
		for(i = 0; i < MAX_BASES; ++i)
		{
			if(respawnBases[i] == base)
			{
				respawnBases[i] = None;
				respawnBaseNames[i] = "";
				respawnBaseLocations[i] = Vect(0,0,0);
				break;
			}
		}
	}
}

simulated function bool validRespawnBaseIndex(int index)
{
	return respawnBases[index] != None;
}

simulated function int getNumRespawnBases()
{
	local int i, numBases;

	for (i=0; i<MAX_BASES; i++)
	{
		if (respawnBases[i] != None)
			numBases++;
	}

	return numBases;
}

// End Bases
// -----------------------------------

function int numPlayers()
{
	local int i;
	local int numPlayers;
	local TribesReplicationInfo tri;

	for (i=0; i<Level.Game.GameReplicationInfo.PRIArray.Length; i++)
	{
		tri = TribesReplicationInfo(Level.Game.GameReplicationInfo.PRIArray[i]);

		if (tri != None && tri.team == self)
			numPlayers++;
	}

	return numPlayers;
}

function int numActivePlayers()
{
	local PlayerCharacterController pc;
	local int i;

	ForEach Level.AllControllers(class'PlayerCharacterController', pc)
	{
		if (pc.Pawn != None && self == Rook(pc.Pawn).team())
			i++;
	}

	return i;
}

function int numTotalLives()
{
	local PlayerCharacterController pc;
	local int i;

	ForEach Level.AllControllers(class'PlayerCharacterController', pc)
	{
		if (TribesReplicationInfo(pc.PlayerReplicationInfo).team == self)
		{
			// If respawnsLeft is < 0, then just return -1 to indicate that respawn
			// restrictions are disabled
			if (pc.livesLeft < 0)
				return -1;

			i += pc.livesLeft;
		}
	}

	return i;
}

// PRECACHING
simulated function UpdatePrecacheRenderData()
{
	local int i;
	Super.UpdatePrecacheRenderData();
	
	// precache all team mesh data
	// NOTE: Only precache coree team meshes in MP matches
	if (Level.NetMode != NM_Standalone)
	{
		for (i=0; i < combatRoleData.Length; ++i)
		{
			Level.AddPrecacheMesh(combatRoleData[i].mesh);
			Level.AddPrecacheMesh(combatRoleData[i].femaleMesh);
			Level.AddPrecacheMesh(combatRoleData[i].armsMesh);
			Level.AddPrecacheMaterial(combatRoleData[i].armorIcon);
			if (combatRoleData[i].jetpack != None)
				Level.AddPrecacheStaticMesh(combatRoleData[i].jetpack.default.StaticMesh);
			if (combatRoleData[i].femaleJetpack != None)
				Level.AddPrecacheStaticMesh(combatRoleData[i].femaleJetpack.default.StaticMesh);
		}

		// precache vehicle skins
		Level.AddPrecacheMaterial(buggySkin);
		Level.AddPrecacheMaterial(podSkin);
		Level.AddPrecacheMaterial(tankSkin);
		Level.AddPrecacheMaterial(assaultShipSkin);
	}

	// precache ownership stuff
	Level.AddPrecacheMaterial(ownershipMaterial);
	Level.AddPrecacheMaterial(baseDeviceIllumMaterial);
	Level.AddPrecacheMaterial(altOwnershipMaterial);
	Level.AddPrecacheMaterial(altBaseDeviceIllumMaterial);
}

defaultproperties
{
     territoryTendrilColor=(B=255,G=255,R=255,A=255)
     objectivesUpdateRate=0.500000
     MAX_BASES=10
     MAX_RESPAWN_VEHICLES=10
     sensorGridRate=0.500000
     TeamColor=(B=255,G=255,R=255,A=255)
     TeamHighlightColor=(G=255,R=255,A=255)
     relativeFriendlyTeamColor=(B=20,G=220,R=20,A=255)
     relativeFriendlyHighlightColor=(G=255,A=255)
     relativeEnemyTeamColor=(B=20,G=20,R=220,A=255)
     relativeEnemyHighlightColor=(R=255,A=255)
     bAlwaysRelevant=True
     RemoteRole=ROLE_SimulatedProxy
     bHiddenEd=True
     bReplicateLabel=True
}
