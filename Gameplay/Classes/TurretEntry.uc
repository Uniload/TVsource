class TurretEntry extends UseableObject
	notplaceable;

var localized string promptArmor;
var localized string promptHostile;

var float EntryTriggerDelay;
var	float TriggerTime;
//var bool  bCarFlipTrigger;

function Touch(Actor Other)
{
	// copied from BulldogTrigger
	local Pawn user;

	super.Touch(Other);

	if (Other.Instigator != None)
	{
		user = Pawn(Other);

		if (user == None)
			return;

		if (EntryTriggerDelay > 0 )
		{
			if (Level.TimeSeconds - TriggerTime < EntryTriggerDelay)
				return;
			TriggerTime = Level.TimeSeconds;
		}

		// send a string message to the toucher
		
	}
}

function bool CanBeUsedBy(Pawn user)
{
	local Character characterUser;
	local Turret t;

	t = Turret(Owner);

	characterUser = Character(user);

	if(characterUser != None && 
		t != None &&
		t.IsFriendly(characterUser) && 
		t.IsFunctional() && 
		t.GetControllingCharacter() == None && 
		characterUser.armorClass.default.bCanUseTurrets)
			return true;

	return false;
}

function UsedBy(Pawn user)
{
	local Character characterUser;

	characterUser = Character(user);
	if (characterUser == None)
		return;

	if (Turret(owner).tryToControl(characterUser))
		super.UsedBy(user);
}

// prompts
static function string getPrompt(byte promptIndex, class<Actor> dataClass)
{
	switch (promptIndex)
	{
	case 10:
		return default.promptArmor;
	case 11:
		return default.promptHostile;
	default:
		return super.getPrompt(promptIndex, dataClass);
	}
}

function byte GetPromptIndex(Character PotentialUser)
{
	local Turret t;

	t = Turret(Owner);

	if (t != None && PotentialUser != None)
	{
		if (!PotentialUser.armorClass.default.bCanUseTurrets)
			return 10;
		else if (!t.IsFriendly(PotentialUser))
			return 11;
	}
	
	return Super.GetPromptIndex(PotentialUser);
}

defaultproperties
{
     promptArmor="Your armor does not allow you to man turrets."
     promptHostile="Members of your team cannot man this turret."
     EntryTriggerDelay=0.100000
     bOnlyAffectPawns=True
     RemoteRole=ROLE_None
     bHardAttach=True
     CollisionRadius=80.000000
     CollisionHeight=400.000000
     bCollideActors=False
}
