class TribesHUDManager extends Core.Object
	threaded
	transient;

var PlayerCharacterController Controller;
var TribesHUDBase activeHUD;
var HUDInteraction	interactionHandler;

// persistent HUD cache
var Array<class>			currHUDClasses;
var Array<TribesHUDBase>	hudObjects;

var String ActiveGameplayHUD;	// stores the non-command hud, for switching back to
///////////////////////////////////////////////////////////////////////////////
//
function Initialise(PlayerCharacterController pcc)
{
	local PointOfInterest POI;

	Controller = pcc;

	//
	// add the points of interest array to the controller
	//
	foreach Controller.AllActors(class'PointOfInterest', POI)
	{
		log("added point of interest "$POI);
		Controller.PointsOfInterest[Controller.PointsOfInterest.Length] = POI;
	}
}

function ShowDebugHUD(bool visible)
{
    if (visible)
        GotoState('ShowingDebugHUD');
    else
        GotoState('');
}

function Update()
{
	if(Controller.Level.NetMode == NM_DedicatedServer)
		return;

	if(activeHUD != None && activeHUD.bAllowCommandHUDSwitching)
	{
		if(Controller.bObjectives == 1)
		{
			if (Character(Controller.Pawn) != None && Character(Controller.Pawn).bDontAllowCommandScreen)
				return;

			GotoState('ShowingCommandMapHUD');
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
//
// Cleans up the hud stuffs
function Cleanup()
{
	local int i;

	if(InteractionHandler != None)
	{
		InteractionHandler.hudOwner = None;
		Controller.Player.InteractionMaster.RemoveInteraction(InteractionHandler);
	}

	for(i = 0; i < hudObjects.Length; ++i)
		hudObjects[i].Cleanup();
	hudObjects.Length = 0;
	currHUDClasses.Length = 0;
	ActiveHUD = None;
}

///////////////////////////////////////////////////////////////////////////////
//
function SetHUD(String NewHUDType)
{
	local class<HUD> NewHUDClass;
	local TribesHUDBase NewHUD;
	local int i;

	// empty huds should remove the old one and replace it with nothing
	if(NewHUDType == "")
	{
		if(ActiveHUD != None)
		{
			ActiveHUD.bHideHUD = true;
			ActiveHUD.HUDHidden();
		}

		ActiveGameplayHUD = "";
		ActiveHUD = None;
		Controller.currentHUDClass = newHUDType;
		UpdateHUDData();

		return;
	}

	if(! (Controller.commandHUDClass ~= NewHUDType) && !IsInState('ShowingDebugHUD'))
		ActiveGameplayHUD = NewHUDType;

	// ensure the clientSideChar is available
//	if(clientSideChar == None)
//		clientSideChar = new class'ClientSideCharacter';

	// create the class and set the hud
	NewHUDClass = class<TribesHUDBase>(DynamicLoadObject(newHUDType, class'Class'));

	// Paul: Grabbed the code from PlayerController.ClientSetHUD() and moved it here in order to
	// support persistent caching of HUDs. This is mainly because the changeover time
	// when switching HUDs is waaaay to slow.

	if((activeHUD == None) || ((NewHUDClass != None) && (NewHUDClass != activeHUD.Class)))
	{
		for(i = 0; i < currHUDClasses.Length; ++i)
		{
			if(currHUDClasses[i] == NewHUDClass)
			{
				NewHUD = hudObjects[i];
				break;
			}
		}

		if(NewHUD == None)
		{
			NewHUD = TribesHUDBase(Controller.spawn(NewHUDClass, Controller));
			if(NewHUD != None)
			{
				currHUDClasses[currHUDClasses.Length] = NewHUDClass;
				hudObjects[hudObjects.Length] = NewHUD;
			}
		}

		if(activeHUD != None)
		{
			activeHUD.bHideHUD = true;
			activeHUD.HUDHidden();
		}

		if(NewHUD != None)
		{
			activeHUD = NewHUD;
			activeHUD.bHideHUD = false;

			Controller.myHUD = activeHUD;

			// store the hud name for saving/loading games
			Controller.currentHUDClass = newHUDType;

			activeHUD.HUDShown();
		}
	}
}

//
// Update hud data gets called every tick
//
function UpdateHUDData()
{
	if(Controller.Level.NetMode == NM_DedicatedServer)
		return;

	if(interactionHandler == None)
		interactionHandler = HUDInteraction(Controller.Player.InteractionMaster.AddInteraction("Gameplay.HUDInteraction", Controller.Player));

	if(activeHUD != None && ! activeHUD.bHideHUD)
		activeHUD.UpdateHUDData();

	// any keys not assigned before now will likely be incorrect if
	// the user has modified their bindings while playing!
	Controller.clientSideChar.bHotkeysUpdated = true;

	if(interactionHandler != None)
	{
		if(activeHUD != None && ! activeHUD.bHideHUD && activeHUD.NeedsKeyInput())
		{
			interactionHandler.hudOwner = activeHUD;
			if(! interactionHandler.IsInState('Enabled'))
				interactionHandler.GotoState('Enabled');
		}
		else
		{
			interactionHandler.hudOwner = None;
			interactionHandler.GotoState('');
		}
	}
}

state ShowingDebugHUD
{
	function BeginState()
	{
		SetHUD("TribesGUI.TribesDebugHUD");
	}

	function EndState()
	{
		SetHUD(ActiveGameplayHUD);
	}
}

state ShowingCommandMapHUD
{
	function BeginState()
	{
		SetHUD(Controller.commandHUDClass);
		Controller.serverCommandHUDShown();
	}

	function Update()
	{
		if(Controller.bObjectives != 1)
			GotoState('');
	}

	function EndState()
	{
		SetHUD(ActiveGameplayHUD);
		Controller.serverCommandHUDHidden();
	}
}