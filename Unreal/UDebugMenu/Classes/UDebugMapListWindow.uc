class UDebugMapListWindow extends UWindow.UWindowFramedWindow;


function Created() 
{
	bSizable = True;
	MinWinWidth = 200;
	Super.Created();
}

defaultproperties
{
	WindowTitle="Select a Map...";
	ClientClass=class'UDebugMapListCW'
}