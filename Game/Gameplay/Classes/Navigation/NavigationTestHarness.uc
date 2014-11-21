class NavigationTestHarness extends Engine.Actor;

var HUD selfHUD;

var bool initialised;

var Controller workController;

var bool enabled;

var bool started;

function markPoint();

function initialise(HUD initHUD)
{
	selfHUD = initHUD;

	initialised = true;
}

function toggleEnabled()
{
	enabled= !enabled;
}

function restart()
{
	local Rook character;

	if (!enabled)
	{
		log("not enabled");
		return;
	}

	// spawn character
	character = spawn(class<Character>(DynamicLoadObject("AIClasses.AITestRunner", class'Class')), owner, ,
			selfHUD.playerOwner.viewTarget.location + vect(0, 0, -200));
	if (character != None)
	{
		workController = character.Controller;

		started = true;
	}
	else
	{
		log("Failed to spawn character. Is there enough room?");
	}
}

defaultProperties
{
	RemoteRole = ROLE_None

	initialised = true

	DrawType = DT_None

	enabled = false

	started = false;
}
