class MPAreaTrigger extends TriggerRadius;

var IMPAreaTriggerable		listener;
var float					triggerFrequency;
var (EffectEvents) Name		playerInAreaEffectEvent			"The name of an effect event that loops on players in the area";

struct characterPresence
{
	var Character character;
	var float markerTime;
};

var array<characterPresence>	charList;		

function PostBeginPlay()
{
	local Character c;

	Super.PostBeginPlay();
	SetTimer(triggerFrequency, true);

	// Evaluate everyone within radius and add them
	ForEach TouchingActors(class'Character', c)
	{
		addCharacter(c);
	}
}

simulated function Touch(Actor Other)
{
	local Character c;
	
	if (listener == None)
		return;

	listener.OnAreaEnteredByActor(Other);

	c = Character(Other);
	if (c == None || c.team() == None || c.health <= 0)
		return;

	addCharacter(c);
	super.Touch(Other);

	c.TriggerEffectEvent(playerInAreaEffectEvent);

	if (listener != None)
		listener.OnAreaEntered(c);
}

simulated function UnTouch(Actor Other)
{
	local Character c;
	local int i;

	if (listener == None)
		return;

	listener.OnAreaExitedByActor(Other);

	c = Character(Other);
	if (c == None || c.team() == None)
		return;

	removeCharacter(c);
	super.UnTouch(Other);

	// Superclass doesn't remove from touching, so do it manually
	for (i = 0; i < Touching.Length; ++i)
	{
		if (Touching[i] == Other)
		{
			Touching.Remove(i, 1);
			break;
		}
	}

	c.UnTriggerEffectEvent(playerInAreaEffectEvent);
	listener.OnAreaExited(c);
}

function addCharacter(Character c)
{
	local characterPresence cp;
	local int i;

	// For some reason Touch is being called multiple times, so make sure not to add it
	// more than once
	for (i=0; i<charList.Length; i++)
	{
		if (charList[i].character == c)
			return;
	}

	cp.character = c;
	cp.markerTime = Level.TimeSeconds;

	charList[charList.Length] = cp;
	//Log(self$" adding "$c);
}

function removeCharacter(Character c)
{
	local int i;

	for (i=0; i<charList.Length; i++)
	{
		if (charList[i].character == c)
		{
			charList.remove(i, 1);
			//Log(self$" removing "$c);
		}
	}
}

function bool containsCharacter(Character c)
{
	local int i;

	for (i=0; i<charList.Length; i++)
	{
		if (charList[i].character == c && c.health > 0)
			return true;
	}

	return false;
}

function float getCharacterMarkerTime(Character c)
{
	local int i;

	for (i=0; i<charList.Length; i++)
	{
		if (charList[i].character == c)
			return charList[i].markerTime;
	}

	return 0;
}

function bool enoughTimeElapsedSinceMarkerTime(Character c, float time, optional bool resetMarkerTimeWhenTrue)
{
	local int i;

	for (i=0; i<charList.Length; i++)
	{
		if (charList[i].character == c)
		{
			if (Level.TimeSeconds - charList[i].markerTime > time)
			{
				if (resetMarkerTimeWhenTrue)
					charList[i].markerTime = Level.TimeSeconds;
				return true;
			}
			return false;
		}
	}

	return false;
}

function Timer()
{
	if (listener == None)
	{
		// This will be the case if the listener has been destroyed, for example as a result of filtering.
		// Get rid of the area trigger.
		SetTimer(0, false);
		destroy();
	}
	else
		listener.OnAreaTick();
}

function setTriggerFrequency(float f)
{
	triggerFrequency = f;
	SetTimer(triggerFrequency, true);
}

function int numPlayers(optional TeamInfo searchTeam)
{
	local Character Other;
	local int n, i;

	// Note that this does *not* count neutral characters
	for (i=0; i<charList.Length; i++)
	{
		Other = charList[i].character;
		if (Other.team() != None && (searchTeam == None || Other.team() == searchTeam))
			n++;
	}
	return n;
}

// Look at all characters inside this trigger.  If there are only characters from a single
// team, return what that team is.  Otherwise, return None.  Also return None if there's
// nobody in the trigger.  Consider includeCharacter but don't consider excludeCharacter.
function TeamInfo onlyRemainingTeam(optional Character includeCharacter, optional Character excludeCharacter)
{
	local TeamInfo searchTeam;
	local Character Other;
	local int i;

	if (includeCharacter != None)
		searchTeam = includeCharacter.team();

	for (i=0; i<charList.Length; i++)
	{
		Other = charList[i].character;

		//Log("AreaTrigger contains "$Other$" but will exclude "$excludeCharacter);
		if (Other != excludeCharacter && Other.health > 0)
		{
			// Init searchTeam
			if (searchTeam == None)
				searchTeam = Other.team();
			
			//Log("AreaTrigger comparing "$searchTeam$" to "$Other.team()$" for character "$Other);
			if (searchTeam != Other.team())
			{
				//Log("AreaTrigger found no only remaining team");
				return None;
			}
		}
	}
	//Log("AreaTrigger found only remaining team = "$searchTeam);
	return searchTeam;
}

defaultproperties
{
	CollisionHeight = 1000
	CollisionRadius = 1000
	triggerFrequency = 1
	playerInAreaEffectEvent		= InArea
	bCanDeadTriggerExit = true
}