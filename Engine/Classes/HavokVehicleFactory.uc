//=============================================================================
// HavokVehicle spawner location.
//=============================================================================

class HavokVehicleFactory extends Actor 
	placeable;

var()	class<HavokVehicle>    VehicleClass;
var()	int					   MaxVehicleCount;

var		int					VehicleCount;

event Trigger( Actor Other, Pawn EventInstigator )
{
	local HavokVehicle CreatedVehicle;

	if(VehicleClass == None)
	{
		Log("HavokVehicleFactory:"@self@"has no VehicleClass");
		return;
	}

	if(!EventInstigator.IsA('UnrealPawn'))
		return;

	if(VehicleCount >= MaxVehicleCount)
	{
		// Send a message saying 'too many vehicles already'
		return;
	}

	if(VehicleClass != None)
	{
		CreatedVehicle = spawn(VehicleClass, , , Location, Rotation);
		VehicleCount++;
		CreatedVehicle.ParentFactory = self;
	}
}

defaultproperties
{
     MaxVehicleCount=1
     bHidden=True
     bNoDelete=True
     RemoteRole=ROLE_None
     Texture=Texture'Engine_res.Havok.S_HkVehicleFactory'
     bDirectional=True
}
