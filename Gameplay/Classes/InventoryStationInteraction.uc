class InventoryStationInteraction extends UWindow.UWindowRootWindow;

var InventoryStationDialog clientArea;

function Created()
{
	Super.Created();

	bLeaveOnScreen = true;

	clientArea = InventoryStationDialog(CreateWindow(class'InventoryStationDialog',
			5, 5, 630, 550));
	ShowModal(clientArea);

	GotoState('InventoryStationInterface');
}

function initialise(InventoryStationAccess station)
{
//	clientArea.initialise(station);
}

state InventoryStationInterface extends UWindows
{
	function BeginState()
	{
		// effectively same as super class behaviour but does not pause game
	
		bVisible = true;
		bRequiresTick = true;
		
		bWindowVisible = true;
		bUWindowActive = true;

		ViewportOwner.bShowWindowsMouse = true;
		ViewportOwner.bSuspendPrecaching = true;
	}

	function Tick(float deltaSeconds)
	{
		Super.Tick(deltaSeconds);

		if (!ViewportOwner.bShowWindowsMouse)
			ViewportOwner.bShowWindowsMouse = true;
	}
	
	function EndState()
	{
		// effectively same as super class behaviour but does not unpause game

		bVisible = false;
		bRequiresTick = false;

		bUWindowActive = false;
		bWindowVisible = false;

		ViewportOwner.bShowWindowsMouse = false;
		ViewportOwner.bSuspendPrecaching = false;		
	}
}

defaultproperties
{
     LookAndFeelClass="UDebugMenu.UDebugBlueLookAndFeel"
     bAllowConsole=False
}
