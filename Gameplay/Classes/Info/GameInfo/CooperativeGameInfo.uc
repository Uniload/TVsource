class CooperativeGameInfo extends MultiplayerGameInfo;

defaultproperties
{
	Label						= "GAMEINFO"
	PlayerControllerClassName	= "Gameplay.PlayerCharacterController"
	DefaultPlayerClassName		= "Gameplay.MultiplayerCharacter"
    bDelayedStart				= true
	MapListType					= "Gameplay.MapList"
	CheatClass					= class'TribesCheatManager'
}