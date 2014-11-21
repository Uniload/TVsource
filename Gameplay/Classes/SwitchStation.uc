class SwitchStation extends BaseDevice
	native;

var() float useableObjectCollisionHeight;
var() float useableObjectCollisionRadius;

// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)

function PostBeginPlay()
{
	local SwitchStationUseableObject ssuo;

	ssuo = Spawn(class'SwitchStationUseableObject', self,, Location, Rotation);

	ssuo.SetCollisionSize(useableObjectCollisionRadius, useableObjectCollisionHeight);

	UseablePoints[0] = ssuo.GetUseablePoint();
	UseablePointsValid[0] = UP_Valid;
}

//
// Useable points wil only be displayed if the switch is on the opposing team
//
simulated function bool CanBeUsedBy(Character CharacterUser)
{
	return (ownerBase != None) && ownerBase.team.IsFriendly(CharacterUser.team());
}

function useSwitch(Pawn user)
{
	local Character char;
	local TeamInfo newTeam;

	char = Character(user);
	
	// do nothing if used by non-character
	if (char == None)
		return;

	if (ownerBase == None)
	{
		log("Switch "$label$" cannot be used as it has no base");
	}

	// switch ownership of all devices in our owner base (includes us) to the team of the user
	newTeam = char.team();
	if (ownerBase.team != newTeam)
	{
		PlayBDAnim('Switch');
		ownerBase.team = char.team();
	}
}

cpptext
{
	virtual UBOOL canBeSeenBy(APawn* pawn) {return false;}	// AI's can't see SwitchStation's

}


defaultproperties
{
     useableObjectCollisionHeight=80.000000
     useableObjectCollisionRadius=150.000000
     bAIThreat=False
     bCanBeDamaged=False
}
