class antics extends Gameplay.Mutator config(antics);

var config bool AutoBan; // Auto banning of cheaters.
var config bool AutoKick; // Auto kicking of cheaters.
var int CheaterThreshold; // Number of violations before a client is considered a cheater.
// var anticsIRC IRC; // IRC connection.
var config bool PermaBan; // Determines whether the ban will be a session or permanent ban.
var string ServerPackage; // Server package name.
var config int ValidationInterval; // Validation interval, in minutes.

function PreBeginPlay()
{
	// TODO: Research Super.PreBeginPlay() further.

	AddServerPackage();
	LoadCharacterController();	
	
	SetTimer(ValidationInterval * 60, true);
}

function PostBeginPlay()
{
	// TODO: Research Super.PostBeginPlay() further.
	
	Super.PostBeginPlay();
	
	//IRC = Spawn(class'anticsIRC');
	//IRC.Connect();
	
	SaveConfig();
}

function AddServerPackage()
{
	local bool addServerPackage;
	local int i;
	
	addServerPackage = true;
	
	for(i = 0; i < class'Engine.GameEngine'.default.ServerPackages.Length; i++)
	{
		if(class'Engine.GameEngine'.default.ServerPackages[i] == ServerPackage)
		{
			addServerPackage = false;
			break;
		}
	}
	
	if(addServerPackage)
	{
		class'Engine.GameEngine'.default.ServerPackages[class'Engine.GameEngine'.default.ServerPackages.Length] = ServerPackage;
		class'Engine.GameEngine'.static.StaticSaveConfig();
		log("Server requires a restart for setup to complete!", 'antics');
		
		// TODO: Figure out how to reboot a server.
		// Quit();
	}
}

function LoadCharacterController()
{
	local Gameplay.ModeInfo MI;
	
	foreach AllActors(class'Gameplay.ModeInfo', MI)
	{
		if (MI != None)
		{
			MI.PlayerControllerClassName = ServerPackage $ ".anticsCharacterController";
			log("Character controller loaded successfully!", 'antics');
			break;
		}
	}
}

function Timer()
{	
	ValidateClients();
}

function ValidateClients()
{
	local Controller C;
	//local string IRCMessage;
	
	for(C = Level.ControllerList; C != None; C = C.NextController)
	{
		
		//IRCMessage = "1,13<<CHEATER DETECTED>> Name: " $ C.PlayerReplicationInfo.PlayerName $ " NEW INFO " $ CheaterThreshold $ " < " $ anticsCharacterController(C).ViolationCount $ "";
		//log(IRCMessage, 'antics');
		//IRC.SendMessage(IRCMessage);
		
		
		if(anticsCharacterController(C).ViolationCount > CheaterThreshold)
		{
			LogCheater(C);
			DisciplineCheater(C);
		}
	}
}

function LogCheater(Controller C)
{
	local string IPAddressLong, IPAddress, IPAddressPort, IRCMessage;
	
	IPAddressLong = PlayerController(C).GetPlayerNetworkAddress();
	Div(IPAddressLong, ":", IPAddress, IPAddressPort);
			
	if(anticsCharacterController(C).LogCheater)
	{
		//IRCMessage = "1,13<<CHEATER DETECTED>> Name: " $ C.PlayerReplicationInfo.PlayerName $ " IP: " $ IPAddress $ "";
		//IRC.SendMessage(IRCMessage);
		//log(IRCMessage, 'antics');
		anticsCharacterController(C).LogCheater = false;
	}
}

function DisciplineCheater(Controller C)
{
	if(AutoBan)
	{
		Level.Game.AccessControl.BanPlayer(PlayerController(C), !PermaBan);
		log("Player '" $ C.PlayerReplicationInfo.PlayerName $ "' has been banned for cheating.", 'antics');
		Level.Game.BroadcastLocalized(self, class'anticsGameMessage', 32, C.PlayerReplicationInfo);
		return;
	}
	else if(AutoKick)
	{
		Level.Game.AccessControl.KickPlayer(PlayerController(C));
		log("Player '" $ C.PlayerReplicationInfo.PlayerName $ "' has been kicked for cheating.", 'antics');
		Level.Game.BroadcastLocalized(self, class'anticsGameMessage', 31, C.PlayerReplicationInfo);
	}
	else
	{
		log("No action has been taken against '" $ C.PlayerReplicationInfo.PlayerName $ "' for cheating.", 'antics');
		Level.Game.BroadcastLocalized(self, class'anticsGameMessage', 30, C.PlayerReplicationInfo);
	}
}

defaultproperties
{
     AutoKick=True
     CheaterThreshold=200
     ServerPackage="laxx_antics_v1"
     ValidationInterval=1
}
