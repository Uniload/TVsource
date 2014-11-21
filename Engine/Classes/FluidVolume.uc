class FluidVolume extends PhysicsVolume
	native;

var (SurfaceTexturing) editinlineuse Cubemap				ReflectionMap;

var (SurfaceColor) byte										Transparency;
var (SurfaceColor) color									BaseColor;
var (SurfaceColor) color									TangentColor;
var (SurfaceColor) color									ReflectionModulator;

var (SurfaceWaves) float									SubdivisionSize;
var (SurfaceWaves) byte										EdgePolyBuffer;
var (SurfaceWaves) float									WaveHeightScaler;
var (SurfaceWaves) float									WaveSpeedScaler;
var (SurfaceWaves) editinlineuse FluidSurfaceParamaters		SurfaceParamaters;

var (SurfaceRipples) editinlineuse Texture					NormalMap;
var (SurfaceRipples) float									RippleScale;
var (SurfaceRipples) byte									RippleStrength;
var (SurfaceRipples) vector									RippleSpeed;

var (SurfaceLowDetail) editinlineuse Texture				Texture;
var (SurfaceLowDetail) float								TextureScale;
var (SurfaceLowDetail) vector								TextureSpeed;	

var const transient private noexport int Interface;	// hidden UFluidVolumeInterface

// these only get called in certain circumstances. need to use ActorEnter, ActorLeaving instead
/*
simulated event Touch(Actor Other)
{
	log("FLUID TOUCHED BY "$Other.Name);
}
simulated event UnTouch(Actor Other)
{
	log("FLUID UNTOUCHED BY "$Other.Name);	
}
*/

simulated event PostBeginPlay()
{
	if (Texture == None)
		Texture = Texture(DynamicLoadObject("water.lowres", class'Texture'));
}

// effect events
simulated event ActorEnteredVolume(Actor Other)
{
	Other.TriggerEffectEvent( 'WaterEnter', None, None, Other.Location, Rotator(Other.Velocity));
}

simulated event ActorLeavingVolume(Actor Other)
{
	Other.TriggerEffectEvent( 'WaterLeave', None, None, Other.Location, Rotator(Other.Velocity));	
}

simulated event PawnEnteredVolume(Pawn Other)
{
	super.PawnEnteredVolume(Other);
	Other.TriggerEffectEvent( 'WaterEnter', None, None, Other.Location, Rotator(Other.Velocity));
}

simulated event PawnLeavingVolume(Pawn Other)
{
	super.PawnLeavingVolume(Other);
	Other.TriggerEffectEvent( 'WaterLeave', None, None, Other.Location, Rotator(Other.Velocity));	
}

defaultproperties
{
     Transparency=127
     BaseColor=(B=255,G=100)
     TangentColor=(B=200,G=150)
     ReflectionModulator=(B=128,G=128,R=128,A=128)
     SubdivisionSize=512.000000
     WaveHeightScaler=0.500000
     WaveSpeedScaler=1.000000
     NormalMap=Texture'Engine_res.Render.SurfaceRipplesNorm'
     RippleScale=2048.000000
     RippleStrength=100
     RippleSpeed=(X=3.000000,Y=3.000000)
     TextureScale=512.000000
     TextureSpeed=(X=20.000000,Y=20.000000)
     FluidFriction=0.450000
     bWaterVolume=True
     KBuoyancy=0.900000
     DrawType=DT_FluidVolume
     bUnlit=True
}
