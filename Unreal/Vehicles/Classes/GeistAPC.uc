class GeistAPC extends SHalfTrack;

//#exec OBJ LOAD FILE=..\animations\GeistAPCAsset.ukx

defaultproperties
{
//	Mesh=Mesh'GeistAPCAsset.GeistAPCMesh2'
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

	EntryPositions(0)=(X=0,Y=-200,Z=10)

	ExitPositions(0)=(X=0,Y=-235,Z=100)
	ExitPositions(1)=(X=0,Y=235,Z=100)

//	IdleSound=sound'BuggySounds.Engine.AWBuggyIdle2'
	EngineRPMSoundRange=5000
//#if !IG_DISABLE_UNREAL_ACTOR_SOUND_MANAGEMENT // ckline: use IG_EFFECTS system instead of old Unreal per-actor sound specifications
//  SoundRadius=255
//	SoundVolume=255
//#endif
	IdleRPM=500
	RevMeterScale=4000

	MaxSteerAngle=25.0
	SteerSpeed=110.0
	FTScale=0.03
	StopThreshold=100
	TorqueCurve=(Points=((InVal=0,OutVal=5.0),(InVal=200,OutVal=6.0),(InVal=1800,OutVal=7.0),(InVal=2500,OutVal=0.0)))
	EngineBrakeFactor=0.0001
	EngineBrakeRPMScale=0.1

	TransRatio=0.2
	GearRatios[0]=-0.5
	GearRatios[1]=0.4
	GearRatios[2]=0.65
	GearRatios[3]=0.85
	GearRatios[4]=1.1
	ChangeUpPoint=2000
	ChangeDownPoint=1000

	TrackInertia=0.1
	TrackLongSlip=0.001
	TrackLatSlipFunc=(Points=((InVal=0.0,OutVal=0.0),(InVal=40.0,OutVal=0.03),(InVal=10000000000.0,OutVal=0.03)))
	TrackLongFrictionScale=0.7
	TrackLatFrictionScale=1.2

	TrackLinRatio=1.0
	MaxTrackBrakeTorque=10.0

	WheelPenScale=1.0
	WheelSoftness=0.01
	WheelInertia=0.1
	WheelLongFrictionFunc=(Points=((InVal=0,OutVal=0.0),(InVal=100.0,OutVal=1.0),(InVal=200.0,OutVal=0.7),(InVal=10000000000.0,OutVal=0.7)))
	WheelLongSlip=0.001
	WheelLatSlipFunc=(Points=((InVal=0.0,OutVal=0.0),(InVal=40.0,OutVal=0.03),(InVal=10000000000.0,OutVal=0.03)))
	WheelLongFrictionScale=0.7
	WheelLatFrictionScale=1.2
	WheelSuspensionTravel=25.0
	WheelSuspensionOffset=0.0

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
		KInertiaTensor(0)=3.0
		KInertiaTensor(1)=0.00
		KInertiaTensor(2)=0.0
		KInertiaTensor(3)=12.0
		KInertiaTensor(4)=0.000000
		KInertiaTensor(5)=12.0
		KCOMOffset=(X=-0.000000,Y=0.000000,Z=1.0)
		Name="KParams0"
    End Object
    KParams=KarmaParams'KParams0'

	Begin Object Class=SVehicleWheel Name=LFWheel
		BoneName="LF_Wheel"
		BoneOffset=(X=20.0,Y=0.0,Z=0.0)
		WheelRadius=65
		bPoweredWheel=false
		bHandbrakeWheel=false
		SteerType=ST_Steered
		SupportBoneName="LF_Axle"
		SupportBoneAxis=AXIS_Z
	End Object
	Wheels(0)=SVehicleWheel'LFWheel'

	Begin Object Class=SVehicleWheel Name=RFWheel
		BoneName="RF_Wheel"
		BoneOffset=(X=-20.0,Y=0.0,Z=0.0)
		WheelRadius=65
		bPoweredWheel=false
		bHandbrakeWheel=false
		SteerType=ST_Steered
		SupportBoneName="RF_Axle"
		SupportBoneAxis=AXIS_Z
	End Object
	Wheels(1)=SVehicleWheel'RFWheel'


	Begin Object Class=SVehicleWheel Name=LMTread
		BoneName="LM_Tread"
		BoneOffset=(X=-20.0,Y=0.0,Z=15.0)
		WheelRadius=32
		bPoweredWheel=true
		bHandbrakeWheel=false
		bTrackWheel=true
		SteerType=ST_Fixed
	End Object
	Wheels(2)=SVehicleWheel'LMTread'

	Begin Object Class=SVehicleWheel Name=RMTread
		BoneName="RM_Tread"
		BoneOffset=(X=20.0,Y=0.0,Z=15.0)
		WheelRadius=32
		bPoweredWheel=true
		bHandbrakeWheel=false
		bTrackWheel=true
		SteerType=ST_Fixed
	End Object
	Wheels(3)=SVehicleWheel'RMTread'


	Begin Object Class=SVehicleWheel Name=LRTread
		BoneName="LR_Tread"
		BoneOffset=(X=-20.0,Y=0.0,Z=15.0)
		WheelRadius=32
		bPoweredWheel=true
		bHandbrakeWheel=false
		bTrackWheel=true
		SteerType=ST_Fixed
	End Object
	Wheels(4)=SVehicleWheel'LRTread'

	Begin Object Class=SVehicleWheel Name=RRTread
		BoneName="RR_Tread"
		BoneOffset=(X=20.0,Y=0.0,Z=15.0)
		WheelRadius=32
		bPoweredWheel=true
		bHandbrakeWheel=false
		bTrackWheel=true
		SteerType=ST_Fixed
	End Object
	Wheels(5)=SVehicleWheel'RRTread'
}