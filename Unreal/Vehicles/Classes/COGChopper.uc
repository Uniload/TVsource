class COGChopper extends SCopter;

defaultproperties
{
//	Mesh=Mesh'COGChopperAsset.COG_Copter2'

	TPCamDistance=1000

	bDrawDriverInTP=false
	bDrawMeshInFP=false

	UprightStiffness=500
	UprightDamping=300

	MaxThrustForce=100.0
	LongDamping=0.05

	MaxStrafeForce=80.0
	LatDamping=0.8

	MaxRiseForce=60.0
	UpDamping=0.2

	TurnTorqueFactor=600.0
	TurnTorqueMax=200.0
	TurnDamping=50.0
	MaxYawRate=1.5

	PitchTorqueFactor=200.0
	PitchTorqueMax=35.0
	PitchDamping=20.0

	RollTorqueTurnFactor=450.0
	RollTorqueStrafeFactor=50.0
	RollTorqueMax=50.0
	RollDamping=30.0

	StopThreshold=100
	VehicleMass=4.0

	EntryPositions(0)=(X=0,Y=-165,Z=-80)

	ExitPositions(0)=(X=0,Y=-165,Z=100)
	ExitPositions(1)=(X=0,Y=165,Z=100)

    Begin Object Class=KarmaParamsRBFull Name=KParams0
		KStartEnabled=True
		KFriction=0.5
		KLinearDamping=0.0
		KAngularDamping=0.0
		bKNonSphericalInertia=True
        bHighDetailOnly=False
        bClientOnly=False
		bKDoubleTickRate=True
		bKStayUpright=True
		bKAllowRotate=True
		SafeTimeMode=KST_Always
		KInertiaTensor(0)=1.0
		KInertiaTensor(1)=0.0
		KInertiaTensor(2)=0.0
		KInertiaTensor(3)=3.0
		KInertiaTensor(4)=0.0
		KInertiaTensor(5)=3.5
		KCOMOffset=(X=-0.25,Y=0.0,Z=0.0)
		KActorGravScale=0.0
        Name="KParams0"
    End Object
    KParams=KarmaParams'KParams0'		
}