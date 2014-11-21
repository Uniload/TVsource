//=============================================================================
// Player start location.
//=============================================================================
class SinglePlayerStart extends PlayerStart
	placeable;

var() string PlayerControllerClassName;
var() class<SingleplayerCharacter> PawnClass;


// defaultPawnClassName
// return the default pawn class for the start point
function string defaultPawnClassName()
{
	return string(PawnClass.Outer) $ "." $ string(PawnClass.Name);
}


defaultproperties
{
	bSinglePlayer=True
	bCoop=True
	PlayerControllerClassName="Gameplay.PlayerCharacterController"
	PawnClass=class'SingleplayerCharacter'
}
