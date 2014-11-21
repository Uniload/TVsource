class Armadillo extends SCar;

//#exec OBJ LOAD FILE=..\animations\COGArmadilloAsset.ukx
//#exec OBJ LOAD FILE=..\sounds\BuggySounds.uax

defaultproperties
{
//	Mesh=Mesh'COGArmadilloAsset.Armadillo3'
	DrawScale=1.0
	DrawScale3D=(X=1.0,Y=1.0,Z=1.0)

	FPCamPos=(X=0,Y=0,Z=180)
	TPCamLookat=(X=-100,Y=0,Z=140)
	TPCamDistance=700

	bDrawDriverInTP=true
	bDrawMeshInFP=false

	MaxViewYaw=16000
	MaxViewPitch=16000

	DrivePos=(X=0,Y=0,Z=80)

//	IdleSound=sound'BuggySounds.Engine.AWBuggyIdle2'
	EngineRPMSoundRange=5000
//#if !IG_DISABLE_UNREAL_ACTOR_SOUND_MANAGEMENT // ckline: use IG_EFFECTS system instead of old Unreal per-actor sound specifications
//  SoundRadius=255
//	SoundVolume=255
//#endif
	IdleRPM=500
	RevMeterScale=4000

	EntryPositions(0)=(X=0,Y=-200,Z=10)

	ExitPositions(0)=(X=0,Y=-235,Z=100)
	ExitPositions(1)=(X=0,Y=235,Z=100)

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

	VehicleMass=8.0

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
		KInertiaTensor(0)=2.0
		KInertiaTensor(1)=0.000000
		KInertiaTensor(2)=0.000000
		KInertiaTensor(3)=10
		KInertiaTensor(4)=0.000000
		KInertiaTensor(5)=14.0
		KCOMOffset=(X=0.0,Y=0.0,Z=0.0)
        Name="KParams0"
    End Object
    KParams=KarmaParams'KParams0'

	Begin Object Class=SVehicleWheel Name=LFWheel
		BoneName="LF_Wheel"
		BoneOffset=(X=20.0,Y=0.0,Z=0.0)
		WheelRadius=53
		bPoweredWheel=true
		bHandbrakeWheel=false
		SteerType=ST_Steered
		SupportBoneName="LF_Strut"
		SupportBoneAxis=AXIS_Z
	End Object
	Wheels(0)=SVehicleWheel'LFWheel'

	Begin Object Class=SVehicleWheel Name=RFWheel
		BoneName="RF_Wheel"
		BoneOffset=(X=-20.0,Y=0.0,Z=0.0)
		WheelRadius=53
		bPoweredWheel=true
		bHandbrakeWheel=false
		SteerType=ST_Steered
		SupportBoneName="RF_Strut"
		SupportBoneAxis=AXIS_Z
	End Object
	Wheels(1)=SVehicleWheel'RFWheel'


	Begin Object Class=SVehicleWheel Name=LMWheel
		BoneName="LM_Wheel"
		BoneOffset=(X=20.0,Y=0.0,Z=0.0)
		WheelRadius=53
		bPoweredWheel=true
		bHandbrakeWheel=false
		SteerType=ST_Fixed
		SupportBoneName="LM_Strut"
		SupportBoneAxis=AXIS_Z
	End Object
	Wheels(2)=SVehicleWheel'LMWheel'

	Begin Object Class=SVehicleWheel Name=RMWheel
		BoneName="RM_Wheel"
		BoneOffset=(X=-20.0,Y=0.0,Z=0.0)
		WheelRadius=53
		bPoweredWheel=true
		bHandbrakeWheel=false
		SteerType=ST_Fixed
		SupportBoneName="RM_Strut"
		SupportBoneAxis=AXIS_Z
	End Object
	Wheels(3)=SVehicleWheel'RMWheel'


	Begin Object Class=SVehicleWheel Name=LRWheel
		BoneName="LR_Wheel"
		BoneOffset=(X=20.0,Y=0.0,Z=0.0)
		WheelRadius=53
		bPoweredWheel=true
		bHandbrakeWheel=false
		SteerType=ST_Fixed
		SupportBoneName="LR_Strut"
		SupportBoneAxis=AXIS_Z
	End Object
	Wheels(4)=SVehicleWheel'LRWheel'

	Begin Object Class=SVehicleWheel Name=RRWheel
		BoneName="RR_Wheel"
		BoneOffset=(X=-20.0,Y=0.0,Z=0.0)
		WheelRadius=53
		bPoweredWheel=true
		bHandbrakeWheel=false
		SteerType=ST_Fixed
		SupportBoneName="RR_Strut"
		SupportBoneAxis=AXIS_Z
	End Object
	Wheels(5)=SVehicleWheel'RRWheel'
}