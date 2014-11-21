//
// GUI component to render the character in the inventory
// station UI.
//
class TribesInventoryCharacterView extends GUI.GUIActorContainer;

// current values
var float			zoomLevel;
var Rotator			cameraRotation;

// 
var TribesInventoryCharacter	inventoryCharacter;
var TeamInfo					playerTeam;
var bool						bPlayerIsFemale;

//
// Initialise the charater properties
//
function InitCharacterProperties(TeamInfo team, bool bIsFemale)
{
	playerTeam = team;
	bPlayerIsFemale = bIsFemale;

	// set a timer to do a long wait animation (doesnt really work)
//	SetTimer(50, true);
}

//
// Spawn the actor
//
function SpawnActor()
{
    if( Actor != None)
        return;

    Actor = PlayerOwner().Spawn(ActorClass, , ActorName, vect(0,0,0));

	inventoryCharacter = TribesInventoryCharacter(Actor);
	if(inventoryCharacter != None)
		inventoryCharacter.bHidden = false;
}

event Hide()
{
	inventoryCharacter = None;
	playerTeam = None;

	Super.Hide();
}

//
// Draw the actor
//
function bool InternalOnDraw(Canvas canvas)
{
	local float oldOrgX, oldOrgY;
	local float oldClipX, oldClipY;

	oldClipX = canvas.ClipX;
	oldClipY = canvas.ClipY;
	oldOrgX = canvas.OrgX;
	oldOrgY = canvas.OrgY;

	canvas.SetOrigin(ActualLeft(), ActualTop());
	canvas.SetClip(canvas.OrgX + ActualWidth(), canvas.OrgY + ActualHeight());

    Canvas.DrawPositionedActor(Actor, false, true, , cameraRotation, zoomLevel);

	canvas.SetOrigin(oldOrgX, oldOrgY);
	canvas.SetClip(oldClipX, oldClipY);

	return true;
}

protected function PositionActor()	
{
}

//
// This timer is supposed to kick in periodically an do a 
// long wait animation, but it doesnt really work for 
// two reasons:
// 1. need to tick the actor to ensure that the idle animation resarts after this one has finished (easy!)
// 2. the actor automatically repositions itself to playe the animation (because of a recalced sphere, I think)
//
// It would be cool to get this working. TBD.
//
/*
function Timer()
{
	if(inventoryCharacter.HasAnim('start_round'))
		inventoryCharacter.PlayAnim('start_round');
}
*/

//
// Updates the loadout on the charcater
//
function UpdateLoadout(InventoryStationAccess.InventoryStationLoadout newLoadout)
{
	inventoryCharacter.UpdateLoadout(newLoadout, playerTeam, bPlayerIsFemale);
	if(inventoryCharacter.HasAnim('InvStation'))
		inventoryCharacter.LoopAnim('InvStation');
	else
		inventoryCharacter.LoopAnim('stand');
}

//
// Set help weapon
//
function SetHeldWeapon(class<Weapon> weaponClass)
{
	inventoryCharacter.SetHeldWeapon(weaponClass);
}

defaultproperties
{
	ActorClass				= class'TribesGUI.TribesInventoryCharacter'
	DrawType				= DT_Mesh
	bAcceptsInput			= false

	OnDraw					= InternalOnDraw
	zoomLevel				= 180
	cameraRotation			= (pitch=-1500,yaw=35000,roll=0)
}
