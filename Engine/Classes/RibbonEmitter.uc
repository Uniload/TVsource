class RibbonEmitter extends ParticleEmitter
	native;

struct native RibbonPoint
{
	var() vector	Location;
	var() vector	AxisNormal;
	var() float		Width;
#if IG_TRIBES3	// rowan: per particle velocity
	var() vector	Velocity;
	var() vector	InterpolatedLocation; // henry: for spline interpolation
#endif
};

enum EGetPointAxis
{
	PAXIS_OwnerX, // owners X axis based on rotation
	PAXIS_OwnerY, // owners Y axis based on rotation
	PAXIS_OwnerZ, // owners Z axis based on rotation
	PAXIS_BoneNormal, // (end - start) or start bone direction if no end bone found
	PAXIS_StartBoneDirection, // start bones direction
	PAXIS_AxisNormal // specified normal
};

// main vars
var(Ribbon) float SampleRate;
var(Ribbon) float DecayRate;
var(Ribbon) int NumPoints;
var(Ribbon) float RibbonWidth;
var(Ribbon) EGetPointAxis GetPointAxisFrom;
var(Ribbon) vector AxisNormal; // used for PAXIS_AxisNormal
var(Ribbon) float MinSampleDist;
var(Ribbon) float MinSampleDot;
var(Ribbon) float PointOriginOffset;

// texture UV scaling
var(RibbonTexture) float RibbonTextureUScale;
var(RibbonTexture) float RibbonTextureVScale;

// axis rotated sheets
var(RibbonSheets) int NumSheets; // number of sheets used
var(RibbonSheets) array<float> SheetScale;
#if IG_TRIBES3	// rowan:
var(RibbonSheets) bool bBillboardSheets;
#endif

// bone vars (emitter must have an actor with a skeletal mesh as its owner)
var(RibbonBones) vector StartBoneOffset;
var(RibbonBones) vector EndBoneOffset;
var(RibbonBones) name BoneNameStart;
var(RibbonBones) name BoneNameEnd;

// ribbon point array
#if IG_TRIBES3	// henry: spline ribbons
var array<RibbonPoint> RibbonPoints;
var(Ribbon) int        RibbonNumSplinePoints "if this is 0, then the usual NumPoints are used, otherwise a spline with this many interpolated points is used";
var(Ribbon) int        RibbonSplineDegree "this can be 2, 3, or 4. The spline's polynomial degree is this degree minus one, (i.e., use 4 for a cubic spline or 3 for a quadratic spline.)"; 
var array<int>         RibbonSplineKnots;
var array<RibbonPoint> RibbonSplinePoints;
#else
var (Ribbon) array<RibbonPoint> RibbonPoints;
#endif

// flags
var(Ribbon) bool bSamplePoints;
var(Ribbon) bool bDecayPoints;
var(Ribbon) bool bDecayPointsWhenStopped;
var(Ribbon) bool bSyncDecayWhenKilled;
#if IG_TRIBES3	// rowan:
var(Ribbon) bool bRemainAttachedWhenStopped;
var(Ribbon) bool bSyncFadeOutWhenKilled;
var(Ribbon) bool bMatchPawnVelocity "This will make a sub-emitter match the velocity of the actor to which the parent emitter is attached"; // henry: match the velocity of the pawn so the ribbon stays attached
var(Ribbon) float VelocityLeadFactor "How much to follow the Pawn's velocity (usually 1.0)"; // henry: how much to follow the velocity by
#endif
var(RibbonTexture) bool bLengthBasedTextureU;
var(RibbonSheets) bool bUseSheetScale;
var(RibbonBones) bool bUseBones;
var(RibbonBones) bool bUseBoneDistance; // get width from distance between start and end bones

// internal vars
var transient float SampleTimer; // sample timer (samples point at SampleTimer >= SampleRate)
var transient float DecayTimer;
var transient float RealSampleRate;
var transient float RealDecayRate;
#if IG_TRIBES3	// rowan:
var transient float RibbonDecayLength;
#endif
var transient int SheetsUsed;
var transient RibbonPoint LastSampledPoint;

var transient bool bKilled; // used to init vars when particle emitter is killed
var transient bool bDecaying;

#if IG_TRIBES3	// henry: spline ribbons
var transient int LastNumSplineKnotPoints;
var transient int LastSplineDegree;
#endif

defaultproperties
{
     SampleRate=0.050000
     DecayRate=0.250000
     NumPoints=20
     RibbonWidth=20.000000
     GetPointAxisFrom=PAXIS_AxisNormal
     AxisNormal=(Z=1.000000)
     MinSampleDist=1.000000
     MinSampleDot=0.995000
     PointOriginOffset=0.500000
     RibbonTextureUScale=1.000000
     RibbonTextureVScale=1.000000
     RibbonSplineDegree=3
     bSamplePoints=True
     bDecayPoints=True
     bMatchPawnVelocity=True
     VelocityLeadFactor=1.000000
     MaxParticles=1
     UseRegularSizeScale=False
     StartSizeRange=(X=(Min=1.000000,Max=1.000000),Y=(Min=1.000000,Max=1.000000),Z=(Min=1.000000,Max=1.000000))
     InitialParticlesPerSecond=10000.000000
     AutomaticInitialSpawning=False
}
