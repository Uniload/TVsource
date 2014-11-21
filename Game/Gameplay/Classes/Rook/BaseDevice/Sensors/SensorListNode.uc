class SensorListNode extends Engine.Actor;

// Not replicated, only valid on server! This is used on the server
// to match SensorListNodes to the rook they represent.
var Rook sensedRook;
var class sensedRookClass;
var class<TeamInfo> sensedRookTeamClass;

var bool relevantLastUpdate;

var SensorListNode next;

// Not replicated, only valid on server! The client only ever reads
// this list from beginning to end, so only needs the next property
var SensorListNode prev;	

enum EHeightDiff
{
	HD_ABOVE,
	HD_LEVEL,
	HD_BELOW
};

var private EHeightDiff height;

var byte xPosition;
var byte yPosition;

var byte localX;
var byte localY;

var float xTime;
var float yTime;

var float lastUpdateTimeX;
var float lastUpdateTimeY;

var float xPos;
var float yPos;
var float xOld;
var float yOld;
var float xNew;
var float yNew;

replication
{
	reliable if (Role == ROLE_Authority && bNetOwner)
		relevantLastUpdate, next, sensedRookClass, sensedRookTeamClass, height, xPosition, yPosition;
}

overloaded function construct(PlayerCharacterController _owner, Rook _sensedRook)
{
	super.construct(_owner);

	set(_sensedRook);
}

simulated function Tick(float Delta)
{
	local float mapExtent;

	if (Level.NetMode == NM_DedicatedServer)
		return;

	mapExtent = Level.GetMapTextureExtent();

	if (xPosition != localX)
	{
		xTime = 0.0;
			
		xNew = (float(xPosition) / 255.0) * mapExtent - (mapExtent * 0.5);

		xNew += Level.GetMapTextureOrigin().X;

		if (Level.TimeSeconds - lastUpdateTimeX > 2.0) // Snap if we haven't received an update recently
			xOld = xNew;
		else
			xOld = xPos;

		localX = xPosition;

		lastUpdateTimeX = Level.TimeSeconds;
	}

	if (yPosition != localY)
	{
		yTime = 0.0;

		yNew = (float(yPosition) / 255.0) * mapExtent - (mapExtent * 0.5);

		yNew += Level.GetMapTextureOrigin().Y;

		if (Level.TimeSeconds - lastUpdateTimeY > 2.0) // Snap if we haven't received an update recently
			yOld = yNew;
		else
			yOld = yPos;

		localY = yPosition;

		lastUpdateTimeY = Level.TimeSeconds;
	}

	if (xTime < 0.5)
	{
		xPos = Lerp(xTime / 0.5, xOld, xNew);
		xTime += Delta;
	}

	if (yTime < 0.5)
	{
		yPos = Lerp(yTime / 0.5, yOld, yNew);
		yTime += Delta;
	}
}

function update()
{
	local bool isRelevant;

	isRelevant = PlayerCharacterController(Owner).isRookRelevant(sensedRook);

	if (isRelevant || relevantLastUpdate)
		updateWhenRelevant();

	relevantLastUpdate = isRelevant;

	sensedRook.sensorUpdateFlag = true;
}

protected function updateWhenRelevant()
{
	local int intHeight;
	local Vector mapSpaceLocation;
	local float mapExtent;
	local float halfMapExtent;

	intHeight = PlayerCharacterController(Owner).calculateHeight(sensedRook.Location.Z);

	if (intHeight == 1)
		height = HD_ABOVE;
	else if (intHeight == -1)
		height = HD_BELOW;
	else
		height = HD_LEVEL;

	mapSpaceLocation = sensedRook.Location - Level.GetMapTextureOrigin();

	mapExtent = Level.GetMapTextureExtent();
	halfMapExtent = mapExtent * 0.5;

	xPosition = byte(((mapSpaceLocation.X + halfMapExtent) / mapExtent) * 255.0 + 0.5);
	yPosition = byte(((mapSpaceLocation.Y + halfMapExtent) / mapExtent) * 255.0 + 0.5);
}

function set(Rook newRook)
{
	sensedRook = newRook;
	sensedRookClass = sensedRook.GetRadarInfoClass();
	sensedRookTeamClass = sensedRook.team().class;

	updateWhenRelevant();
}

function detachNode()
{
	if (prev != None)
		prev.next = next;

	if (next != None)
		next.prev = prev;
}

simulated function int getHeight()
{
	if (height == HD_ABOVE)
		return 1;
	else if (height == HD_BELOW)
		return -1;

	return 0;
}

simulated function float getXPosition()
{
	return xPos;
}

simulated function float getYPosition()
{
	return yPos;
}

defaultproperties
{
	RemoteRole = ROLE_SimulatedProxy
	bOnlyRelevantToOwner = true
	bReplicateMovement = false

	bHidden = true
}