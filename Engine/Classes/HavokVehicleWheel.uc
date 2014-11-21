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
     SuspensionStrength=50.000000
     SuspensionDampingCompression=3.000000
     SuspensionDampingRelaxation=3.000000
     MaxBrakingTorque=1500.000000
     WheelTorqueRatio=0.250000
     WheelRadius=35.000000
     WheelWidth=30.000000
     WheelMass=10.000000
     WheelFriction=1.250000
     WheelViscosityFriction=0.050000
     SuspensionTravel=50.000000
}
