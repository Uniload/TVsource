class MPMetaCarryable extends MPCarryable;

var(MPMetaCarryable) int				maxCarryables	"The maximum number of carryables that can be carried in this metacarryable";
var(MPMetaCarryable) int				numCarryables	"The current number of carryables stored in this metacarryable";
var(MPMetaCarryable) class<MPCarryable>	carryableClass	"The class of MPCarryable stored in this metacarryable";
var(MPMetaCarryable) bool				bAutoFill		"If true, this metacarryable will fill itself up when it is introduced into the world";

// Stores instances of each carryable being carried
// Assume for now that a metacarryable never carries another metacarryable
var array<MPCarryable>	carryables;
var bool bHasHomeLocation;

function PostBeginPlay()
{
	local MPCarryable c;
	local int i;

	Super.PostBeginPlay();

	// Check to see if there should be some stored instances in this metacarryable
	// Note that this approach requires that there is a difference between a placed instance
	// in the editor (which require autofilling) and a dynamically spawned instance (which
	// must not autofill since existing instances get added)
	if (bAutoFill)
	{
		Log("Metacarryable "$self$" filling instances "$maxCarryables);
		for (i=0; i<maxCarryables && numCarryables < maxCarryables; i++)
		{
			c = spawn(carryableClass,,,Location);

			if (c == None)
			{
				Log("MetaCarryable error:  could not autofill with class "$carryableClass);
				return;
			}

			// MJ TODO:  There are cases where individual instances will returnToHome and
			// overlap each other.  Not sure what the best solution to this is (spread them out a bit?)
			c.homeLocation = Location;
			bHasHomeLocation = true;
			add(c);
		}
	}
}

function returnToHome(optional bool bSignificant)
{
	local int i;

	// Return all stored carryables
	for (i=0; i<carryables.Length; i++)
		carryables[i].returnToHome();

	// If it has a home, return it; otherwise, destroy it
	if (bHasHomeLocation)
		super.returnToHome(bSignificant);
	else
	{
		//Log("Destroying metaCarryable "$self$" in returnToHome()");
		destroy();
	}
}

function add(MPCarryable c)
{
	if (numCarryables >= maxCarryables)
	{
		Log("MetaCarryable warning:  exceeding carryable capacity on adding "$c);
		return;
	}

	// If this is the first carryable added, do some initialization
	if (carryables.Length == 0)
	{
		if (carryableClass == None)
			carryableClass = c.Class;

		if (c.carrier != None)
		{
			carrier = c.carrier;
			setOwner(c.Owner);
		}
	}
	carryables[carryables.Length] = c;
	numCarryables = numCarryables + 1;

	// Lock the carryable
	c.GotoState('Locked');
}

function pickup(Character c)
{
	local int i,j;
	local int maxPickup;

	if (carryableClass != None)
		maxPickup = carryableClass.default.maxCarried;
	else if (c.carryableReference != None)
		maxPickup = c.carryableReference.maxCarried;
	else
		maxPickup = 0;

	//Log("Metacarryable pickup "$self$", max = "$maxPickup$", len = "$carryables.Length);
	// Empty the carryable as much as possible
	for (i=0; i<carryables.Length && c.numCarryables < maxPickup; i++)
	{
		//Log("Picking up "$carryables[i]);
		if (carryables[i].attemptPickup(c))
			numCarryables--;
	}

	// Drop the remaining carryables
	// Consider composing them into denominations first; for now just drop them as singles
	for (j=0; j<numCarryables; j++)
	{
		//Log("Dropping "$carryables[i+j]);
		carryables[i+j].bCollideWorld = true;
		carryables[i+j].unifiedSetPosition(Location);
		carryables[i+j].drop(true);
	}

	// Get rid of the metacarryable
	carryables.Length = 0;
	destroy();
}

function bool canCombineWith(class<MPCarryable> targetClass)
{
	return carryableClass == targetClass;
}

function int getNumCarryables()
{
	local int i;
	local int total;

	for (i=0; i<carryables.Length; i++)
		total += carryables[i].getNumCarryables();

	Log(self$" has carryables: "$total);
	return total;
}

function int getMaxCarried()
{
	return carryableClass.default.maxCarried;
}

defaultproperties
{
	maxCarryables	= 5
}