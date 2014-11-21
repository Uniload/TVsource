//=============================================================================
// SavedMove is used during network play to buffer recent client moves,
// for use when the server modifies the clients actual position, etc.
//
// Modified from the Engine.SavedMove
//=============================================================================
class SavedMove extends Core.DeleteableObject
	dependsOn(Character);

var float TimeStamp;		// Time of this move.
var float Delta;			// Distance moved.
var float forward;
var float strafe;
var bool bSki;
var bool bThrust;
var bool bJump;
var float accumulator;
var Rotator rotation;
var vector SavedLocation;
var vector StartVelocity;
var Character.MovementState movement;

final function Clear()
{
	TimeStamp = 0;
	Delta = 0;
	forward = 0;
	strafe = 0;
	bSki = false;
	bThrust = false;
	bJump = false;
	rotation.Yaw = 0;
	rotation.Pitch = 0;
	rotation.Roll = 0;
	movement = MovementState_Stand;
}

final function PostUpdate(PlayerController P)
{
	local Character c;

	if (p.Pawn == None)
		return;

	c = Character(P.Pawn);

	if ( P.Pawn != None && c != None )
	{
		SavedLocation = c.movementObject.getEndPosition();
		accumulator = c.movementObject.getAccumulator();
	}
}

final function SetMoveFor(float LevelTimeseconds, PlayerController P, float DeltaTime, float newForward, float newStrafe)
{
	local Character c;
	c = Character(P.Pawn);

	forward = newForward;
	strafe = newStrafe;

	Delta = DeltaTime;

	if (P != None)
	{
		rotation = P.Rotation;
		bSki = (P.bSki > 0);
		bThrust = (P.bJetpack > 0);
		bJump = (P.bJump > 0);
	}

	TimeStamp = LevelTimeSeconds;

	if (c != None)
	{
		movement = MovementState(c.movement);
		StartVelocity = c.Velocity;
	}
}

// Returns true if this move is 'important', i.e. a good candidate to be sent redundantly
final function bool isImportant(Rotator curRotate, bool curThrust, bool curJump, bool curSki, float curForward, float curStrafe)
{
    return (bThrust != curThrust) || (bJump != curJump) || (bSki != curSki) || 
		Abs(forward - curForward) > 0.1 || Abs(strafe - curStrafe) > 0.1 ||
		Abs(curRotate.Pitch - rotation.Pitch) > 128 || Abs(curRotate.Yaw - rotation.Yaw) > 128;
}

// Returns true if the two moves can be combined
final function bool canCombine(Pawn pawn, SavedMove other)
{
	if (Pawn == None)
		return true;

	return Pawn.Physics == PHYS_Movement && !other.isImportant(rotation, bThrust, bJump, bSki, forward, strafe);
}

final function combine(SavedMove other)
{
	Delta += other.Delta;
}

final function combineTurret(SavedMove other)
{
	forward += other.forward;
	strafe += other.strafe;
	Delta += other.Delta;
}

final function encodeImportantData(float LevelTimeseconds, out int data, out byte delta)
{
	data = 0;

	// 1 bit each (3 bits)
	if (bThrust)
		data = data | 1;
	if (bSki)
		data = data | 2;
	if (bJump)
		data = data | 4;
	// 2 bits each (4 bits)
	if (forward > 0)
		data = data | 8;
	else if (forward < 0)
		data = data | 16;
	if (strafe > 0)
		data = data | 32;
	else if (strafe < 0)
		data = data | 64;
	// 16 bits Yaw, 8 bits Pitch
	data = data | (int((((Rotation.Yaw % 65535) / 65535.0) * 32767)) << 7);
	data = data | (int((((Rotation.Pitch % 65535) / 65535.0) * 255)) << 23);
	// 1 bit spare

	// generate delta
	delta = FMin(255, (LevelTimeSeconds - TimeStamp) * 500);
}

static final function decodeImportantData(int data, byte compressedDelta, out int bThrust, out int bSki, out int bJump, out float forward, out float strafe, out int Pitch, out int Yaw, out float delta)
{
	bThrust = data & 1;
	bSki = data & 2;
	bJump = data & 4;
	
	if ((data & 8) != 0)
		forward = 1;
	else if ((data & 16) != 0)
		forward = -1;
	else
		forward = 0;
	
	if ((data & 32) != 0)
		strafe = 1;
	else if ((data & 64) != 0)
		strafe = -1;
	else
		strafe = 0;
	
	Yaw = ((data >> 7) & 32767) * 2;
	Pitch = ((data >> 23) & 255) * 256;

	delta = float(compressedDelta)/500;
}

final function debugEncoding(int data, byte deltaIn)
{
	local int bThrustTest;
	local int bSkiTest;
	local int bJumpTest;
	local float forwardTest;
	local float strafeTest;
	local int PitchTest;
	local int YawTest;
	local float deltaTest;
	
	decodeImportantData(data, delta, bThrustTest, bSkiTest, bJumpTest, forwardTest, strafeTest, PitchTest, YawTest, deltaTest);

	log("Old ="@bThrust@bSki@bJump@forward@strafe@Rotation.Pitch@Rotation.Yaw@deltaIn);
	log("New ="@bThrustTest@bSkiTest@bJumpTest@forwardTest@strafeTest@PitchTest@YawTest@deltaTest);
}

final function bool changesAcceleration()
{
	return bJump || bThrust || bSki || forward != 0 || strafe != 0;
}

final function int compressedView()
{
	return ((Rotation.Yaw & 0xFFFF) << 16) | (Rotation.Pitch & 0xFFFF);
}

final static function int decodeViewYaw(int data)
{
	return (data >> 16) & 0xFFFF;
}

final static function int decodeViewPitch(int data)
{
	return data & 0xFFFF;
}

defaultproperties
{
}
