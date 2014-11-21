class UseableObject extends Engine.Actor;

var(UseableObject) localized string	 prompt			"Prompt shown to the user when they are within range of using this object. Specific objects may specify other prompts, this is the default.";
var(UseableObject) float	priority		"What priority this Useableobject has over another if they are conflicting";
var(UseableObject) Vector	markerOffset	"The offset of the objects representation in the game world from the useable object center";

// true implies this object should always be used regardless of priority
var bool bAlwaysUse;

// true implies this object should never be shown if it cannot be used
var bool bDoNotPromptWhenNotUseable;

function InventoryStationAccess getCorrespondingInventoryStation()
{
	return None;
}

function UsedBy(Pawn user)
{
	if (owner != None)
		owner.dispatchMessage(new class'MessageUsed'(owner.Label, user.Label));
	else
		dispatchMessage(new class'MessageUsed'(Label, user.Label));
}

//
// Called to check if the UseableObject can be used
// by a specific actor.
//
function bool CanBeUsedBy(Pawn user)
{
	return true;
}

function class<Actor> GetPromptDataClass()
{
	return None;
}

simulated function Vector GetUseablePoint()
{
	return Location + (markerOffset >> Rotation);
}

function byte GetPromptIndex(Character PotentialUser)
{
	if(CanBeUsedBy(PotentialUser))
		return 0;
	else
		return 255;
}

// returns a prompt string based on the prompt index
static function string GetPrompt(byte PromptIndex, class<Actor> dataClass)
{
	if(PromptIndex == 255)
		return "";

	return default.prompt;
}

defaultproperties
{
     Prompt="Press '%1' to use this object"
     bHidden=True
     Texture=Texture'Engine_res.S_Trigger'
     bCollideActors=True
}
