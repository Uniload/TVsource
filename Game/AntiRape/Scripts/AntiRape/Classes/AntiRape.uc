class AntiRape extends Gameplay.Mutator config(AntiRape);

var bool CanRape;
var config int PlayerMin;
var config int TimerInterval;

function PostBeginPlay()
{
	Super.PostBeginPlay();
    
    if(!MultiplayerGameInfo(Level.Game).bTournamentMode)
    {
		UpdateDevices();
		SetTimer(TimerInterval, true);
	}
}

function Timer()
{
	if(Level.Game.numPlayers < PlayerMin && CanRape)
	{
		CanRape = false;
		UpdateDevices();
		Level.Game.BroadcastLocalized(self, class'AntiRapeGameMessage', 100);
	}
	else if(Level.Game.numPlayers >= PlayerMin && !CanRape)
	{
		CanRape = true;
		UpdateDevices();
		Level.Game.BroadcastLocalized(self, class'AntiRapeGameMessage', 101);
	}	
}

function UpdateDevices()
{
	local BaseDevice device;

	ForEach AllActors(Class'BaseDevice', device)
		if(device != None)
			device.bCanBeDamaged = CanRape;
}

defaultproperties
{
	CanRape = false
	PlayerMin = 12
	TimerInterval = 15
}