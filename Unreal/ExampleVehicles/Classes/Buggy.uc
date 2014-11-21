class Buggy extends Vehicles.SCar;


defaultproperties
{
	Mesh=SkeletalMesh'SimpleVehicles_K.car'
	DrawScale=1.0
	DrawScale3D=(X=1.0,Y=1.0,Z=1.0)

	FPCamPos=(X=-10,Y=-30,Z=140)
	TPCamLookat=(X=-100,Y=0,Z=100)
	TPCamDistance=600

	bDrawDriverInTP=true
	bDrawMeshInFP=true

	MaxViewYaw=16000
	MaxViewPitch=16000

	DrivePos=(X=0,Y=0,Z=-9999)

	//IdleSound=sound'BuggySounds.Engine.AWBuggyIdle2' TODO TEMP_CL
	EngineRPMSoundRange=5000
    SoundRadius=255
	SoundVolume=255
	IdleRPM=500
	RevMeterScale=4000

	SteerBoneName="SteeringWheel"
	SteerBoneAxis=AXIS_Z
	SteerBoneMaxAngle=90

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
	ChassisTorqueScale=0.200000

	MinBrakeFriction=1.5
	MaxBrakeTorque=20.0
	MaxSteerAngle=25
	SteerSpeed=110
	StopThreshold=100
	TorqueCurve=(Points=((InVal=0,OutVal=10.0),(InVal=200,OutVal=12.0),(InVal=1800,OutVal=14.0),(InVal=2500,OutVal=0.0)))
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

    ExitPositions(0)=(Y=-315.000000,Z=100.000000)
    ExitPositions(1)=(Y=315.000000,Z=100.000000)
    ExitPositions(2)=(Y=0.000000,Z=-400.000000)
    ExitPositions(3)=(Y=0.000000,Z=400.000000)
    EntryPositions(0)=(Y=265.000000,Z=10.000000)
    EntryPositions(1)=(Y=-265.000000,Z=10.000000)
    
    Begin Object Class=SVehicleWheel Name=SVehicleWheel0
        bPoweredWheel=True
        bHandbrakeWheel=True
        BoneName="RtRear"
        BoneOffset=(X=-25.000000)
        WheelRadius=45
        SupportBoneName="RtRearAxle"
    End Object
    Wheels(0)=SVehicleWheel'SVehicleWheel0'
    Begin Object Class=SVehicleWheel Name=SVehicleWheel1
        bPoweredWheel=True
        bHandbrakeWheel=True
        BoneName="LftRear"
        BoneOffset=(X=25.000000)
        WheelRadius=45
        SupportBoneName="LftRearAxle"
    End Object
    Wheels(1)=SVehicleWheel'SVehicleWheel1'
    Begin Object Class=SVehicleWheel Name=SVehicleWheel2
        bPoweredWheel=True
        SteerType=ST_Steered
        BoneName="RtFront"
        BoneOffset=(X=-25.000000)
        WheelRadius=45
        SupportBoneName="RtFrontAxle"
    End Object
    Wheels(2)=SVehicleWheel'SVehicleWheel2'
    Begin Object Class=SVehicleWheel Name=SVehicleWheel3
        bPoweredWheel=True
        SteerType=ST_Steered
        BoneName="LftFront"
        BoneOffset=(X=25.000000)
        WheelRadius=45
        SupportBoneName="LftFrontAxle"
    End Object
    Wheels(3)=SVehicleWheel'SVehicleWheel3'

    Begin Object Class=KarmaParamsRBFull Name=KarmaParamsRBFull0
        KInertiaTensor(0)=1.000000
        KInertiaTensor(3)=3.000000
        KInertiaTensor(5)=3.500000
        KCOMOffset=(X=0.0000,Z=-1.0)
        KLinearDamping=0.050000
        KAngularDamping=0.050000
        KStartEnabled=True
        bKNonSphericalInertia=True
        bHighDetailOnly=False
        bClientOnly=False
        bKDoubleTickRate=True
        SafeTimeMode=KST_Always
        KFriction=0.500000
        Name="KarmaParamsRBFull0"
    End Object
    KParams=KarmaParamsRBFull'KarmaParamsRBFull0'
}