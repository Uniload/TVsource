class Lynx extends SCar
	native;

//#exec OBJ LOAD FILE=..\animations\LynxAsset.ukx
//#exec OBJ LOAD FILE=..\sounds\BuggySounds.uax

defaultproperties
{
//	Mesh=Mesh'LynxAsset.JeepMesh2'
	DrawScale=1.0
	DrawScale3D=(X=1.0,Y=1.0,Z=1.0)

	FPCamPos=(X=-10,Y=-30,Z=140)
	TPCamLookat=(X=-100,Y=0,Z=100)
	TPCamDistance=600

	bDrawDriverInTP=true
	bDrawMeshInFP=true

	MaxViewYaw=16000
	MaxViewPitch=16000

	DrivePos=(X=-30,Y=-30,Z=80)

//	IdleSound=sound'BuggySounds.Engine.AWBuggyIdle2'
	EngineRPMSoundRange=5000
//#if !IG_DISABLE_UNREAL_ACTOR_SOUND_MANAGEMENT // ckline: use IG_EFFECTS system instead of old Unreal per-actor sound specifications
//  SoundRadius=255
//	SoundVolume=255
//#endif
	IdleRPM=500
	RevMeterScale=4000

	SteerBoneName="SteeringWheel"
	SteerBoneAxis=AXIS_Z
	SteerBoneMaxAngle=90

	EntryPositions(0)=(X=0,Y=-165,Z=10)

	ExitPositions(0)=(X=0,Y=-165,Z=100)
	ExitPositions(1)=(X=0,Y=165,Z=100)

	WheelPenScale=1.0
	WheelSoftness=0.01
	WheelRestitution=0.1
	WheelAdhesion=0.0
	WheelLongFrictionFunc=(Points=((InVal=0,OutVal=0.0),(InVal=100.0,OutVal=1.0),(InVal=200.0,OutVal=0.7),(InVal=10000000000.0,OutVal=0.7)))
	WheelLongFrictionScale=0.7
	WheelLatFrictionScale=1.2
	WheelLongSlip=0.001
	WheelLatSlipFunc=(Points=((InVal=0.0,OutVal=0.0),(InVal=40.0,OutVal=0.03),(InVal=10000000000.0,OutVal=0.03)))
	WheelHandbrakeSlip=2.0
	WheelHandbrakeFriction=0.7
	WheelSuspensionTravel=25.0
	WheelSuspensionOffset=12.0

	HandbrakeThresh=200
	FTScale=0.03
	ChassisTorqueScale=1.0

	MinBrakeFriction=1.5
	MaxBrakeTorque=20.0
	MaxSteerAngle=25
	SteerSpeed=110
	StopThreshold=100
	TorqueCurve=(Points=((InVal=0,OutVal=5.0),(InVal=200,OutVal=6.0),(InVal=1800,OutVal=7.0),(InVal=2500,OutVal=0.0)))
	EngineBrakeFactor=0.0001
	EngineBrakeRPMScale=0.1
	EngineInertia=0.1
	WheelInertia=0.1

	TransRatio=0.2
	GearRatios[0]=-0.5
	GearRatios[1]=0.4
	GearRatios[2]=0.65
	GearRatios[3]=0.85
	GearRatios[4]=1.1
	ChangeUpPoint=2000
	ChangeDownPoint=1000
	LSDFactor=1.0

	VehicleMass=4.0

    Begin Object Class=KarmaParamsRBFull Name=KParams0
		KStartEnabled=True
		KFriction=0.5
		KLinearDamping=0.05
		KAngularDamping=0.05
		bKNonSphericalInertia=True
        bHighDetailOnly=False
        bClientOnly=False
		bKDoubleTickRate=True
		SafeTimeMode=KST_Always
		KInertiaTensor(0)=1.0
		KInertiaTensor(1)=0.0
		KInertiaTensor(2)=0.0
		KInertiaTensor(3)=3.0
		KInertiaTensor(4)=0.0
		KInertiaTensor(5)=3.5
		KCOMOffset=(X=-0.25,Y=0.0,Z=0.0)
        Name="KParams0"
    End Object
    KParams=KarmaParams'KParams0'

	Begin Object Class=SVehicleWheel Name=RRWheel
		BoneName="RtRear"
		BoneOffset=(X=-20.0,Y=0.0,Z=0.0)
		WheelRadius=45
		bPoweredWheel=true
		bHandbrakeWheel=true
		SteerType=ST_Fixed
		SupportBoneName="RtRearAxle"
	End Object
	Wheels(0)=SVehicleWheel'RRWheel'

	Begin Object Class=SVehicleWheel Name=LRWheel
		BoneName="LftRear"
		BoneOffset=(X=20.0,Y=0.0,Z=0.0)
		WheelRadius=45
		bPoweredWheel=true
		bHandbrakeWheel=true
		SteerType=ST_Fixed
		SupportBoneName="LftRearAxle"
	End Object
	Wheels(1)=SVehicleWheel'LRWheel'

	Begin Object Class=SVehicleWheel Name=RFWheel
		BoneName="RtFront"
		BoneOffset=(X=-20.0,Y=0.0,Z=0.0)
		WheelRadius=45
		bPoweredWheel=true
		SteerType=ST_Steered
		SupportBoneName="RtFrontAxle"
	End Object
	Wheels(2)=SVehicleWheel'RFWheel'

	Begin Object Class=SVehicleWheel Name=LFWheel
		BoneName="LftFront"
		BoneOffset=(X=20.0,Y=0.0,Z=0.0)
		WheelRadius=45
		bPoweredWheel=true
		SteerType=ST_Steered
		SupportBoneName="LftFrontAxle"
	End Object
	Wheels(3)=SVehicleWheel'LFWheel'
}