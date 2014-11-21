class HavokVehicleWheel extends Core.Object
#if IG_TRIBES3 // Alex:
	editinlinenew
#endif
	native;

// PARAMS
var()	float	SuspensionStrength; // 50
var()	float	SuspensionDampingCompression; // 3
var()	float	SuspensionDampingRelaxation; //3
var()	float	MaxBrakingTorque;//1500
var()	bool	HasHandbrake; // connected to handbrake?
var()   float   WheelTorqueRatio; // 0== not driven, 1 == takes all the torque, so make sure that all the wheels add up to about 1 and that opposing wheels are the same if you want to drive straight!
var()	float	WheelRadius; // unreal units
var()	float	WheelWidth; // unreal units
var()	int		WheelAxleNumber; // 0 or 1 usually (specifies a grouping of wheels)
var()	float	WheelMass; //10
var()	float	WheelFriction; // 1.25
var()	float	WheelViscosityFriction; // 0.05

var()	enum	EHavokSteerType
{
	HK_STEER_Fixed,
	HK_STEER_Steered,
} SteerType; // How steering affects this wheel.

var()					name	BoneName;
var()					vector	BoneOffset; // Offset from wheel bone to the middle of tyre. NB: Not affected by scale.

var()					float	SuspensionTravel;
var()					float   SuspensionOffset;
var()					name	SupportBoneName; // Name of strut etc. that will be rotated around local X as wheel goes up and down.
var()					EAxis	SupportBoneAxis; // Local axis to rotate support bone around.

// OUTPUT
// Calculated on startup
var						vector	WheelPosition; // Wheel center in actor ref frame. Calculated using BoneOffset above.
var						float	SupportPivotDistance; // If a SupportBoneName is specified, this is the distance used to calculate the anglular displacement.

// Calculated each frame
var						float	SuspensionPosition; // Output vertical position of wheel
var						float	CurrentRotation;

defaultproperties
{
	SteerType=HK_STEER_Fixed
	SuspensionTravel=50.0
	WheelRadius=35
	WheelTorqueRatio=0.25 // for 4 wheels this gives all wheels the same. set to 0 for no power to this wheel
	WheelWidth=30
	SupportBoneAxis=AXIS_X
	BoneOffset=(X=0,Y=0,Z=0)
	WheelAxleNumber = 0
	WheelMass=10
	WheelFriction=1.25
	WheelViscosityFriction=0.05
	SuspensionStrength=50
	SuspensionDampingCompression=3
	SuspensionDampingRelaxation=3
	MaxBrakingTorque=1500
	HasHandbrake=false
}
