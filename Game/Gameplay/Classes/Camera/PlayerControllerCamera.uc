//
// A camera that takes control of the players viewport
//
class PlayerControllerCamera extends BaseCamera
	placeable;

var PlayerCharacterController controlledPCC;
var Pawn playerPawn;

var() float FOV;
var() float viewDuration;
var() bool allowPlayerControlledReturn;

function takeControl(PlayerCharacterController pcc)
{
	AssertWithDescription(!pcc.IsInState('CameraControlled'), label $ " tried to take control of the players view. The Players view is already controlled by " $ pcc.controllingCamera.label $ ". A camera must return control to the player before another camera can take control");

	playerPawn = pcc.pawn;

	pcc.unpossess();
	pcc.controllingCamera = self;
	pcc.GotoState('CameraControlled');
	pcc.SetFOV(FOV);
	pcc.myHud.bHideHud = true;

	controlledPCC = pcc;

	GotoState('Play');
}

// Allow the player to control when the camera is returned
function playerControlledReturn()
{
	if (allowPlayerControlledReturn)
		endControl();
}

// Allow a scripting action to return the camera to the player
function actionControlledReturn()
{
	endControl();
}

function private endControl()
{
	if (IsInState('Play'))
	{
		controlledPCC.myHud.bHideHud = false;
		controlledPCC.ResetFOV();

		SetTimer(0.0, false);
		GotoState('');

		controlledPCC.possess(playerPawn);
	}
}

state Play
{
	function BeginState()
	{
		controlledPCC.SetLocation(Location);
		controlledPCC.SetRotation(Rotation);

		SetTimer(viewDuration, false);
	}

	function Timer()
	{
		endControl();
	}
}

defaultproperties
{
	FOV = 90.0
	allowPlayerControlledReturn = true

	bHidden = true
	bDirectional = true
	Texture = Texture'Engine_res.S_Camera'
}