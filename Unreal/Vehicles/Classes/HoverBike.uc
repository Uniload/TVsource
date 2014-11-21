class HoverBike extends SHover;

//#exec OBJ LOAD FILE=..\animations\GeistHoverAsset.ukx

defaultproperties
{
//	Mesh=Mesh'GeistHoverAsset.GeistHover2'

	FPCamPos=(X=0,Y=0,Z=200)
	TPCamLookat=(X=0,Y=0,Z=120)
	TPCamDistance=600

	bDrawDriverInTP=true
	bDrawMeshInFP=true

	MaxViewYaw=16000
	MaxViewPitch=16000

	DrivePos=(X=0.0,Y=0.0,Z=130.0)

	ExitPositions(0)=(X=0,Y=-200,Z=100)
	ExitPositions(1)=(X=0,Y=200,Z=100)

	EntryPositions(0)=(X=0,Y=-165,Z=10)

	FrontThrustOffset=(X=110,Y=0,Z=10)
	RearThrustOffset=(X=-110,Y=0,Z=10)

	HoverSoftness=0.05
	HoverPenScale=1.5
	HoverCheckDist=130

	UprightStiffness=500
	UprightDamping=300

	MaxThrust=45.0
	MaxSteerTorque=120.0
	ForwardDampFactor=0.01
	LateralDampFactor=0.5
	SteerDampFactor=60.0
	PitchTorqueFactor=35.0
	PitchDampFactor=0.0
	BankTorqueFactor=50.0
	BankDampFactor=40.0

	StopThreshold=100
	VehicleMass=4.0

	Begin Object Class=KarmaParamsRBFull Name=KParams0
		KStartEnabled=True
		KFriction=0.5
		KLinearDamping=0
		KAngularDamping=0
		bKNonSphericalInertia=False
        bHighDetailOnly=False
        bClientOnly=False
		bKDoubleTickRate=True
		bKStayUpright=True
		bKAllowRotate=True
		SafeTimeMode=KST_Always
		KInertiaTensor(0)=1.3
		KInertiaTensor(1)=0.0
		KInertiaTensor(2)=0.0
		KInertiaTensor(3)=4.0
		KInertiaTensor(4)=0.0
		KInertiaTensor(5)=4.5
		KCOMOffset=(X=0.0,Y=0.0,Z=0.0)
        Name="KParams0"
    End Object
    KParams=KarmaParams'KParams0'
}