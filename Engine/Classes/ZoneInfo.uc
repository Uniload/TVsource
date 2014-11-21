//=============================================================================
// ZoneInfo, the built-in Unreal class for defining properties
// of zones.  If you place one ZoneInfo actor in a
// zone you have partioned, the ZoneInfo defines the 
// properties of the zone.
// This is a built-in Unreal class and it shouldn't be modified.
//=============================================================================
class ZoneInfo extends Info
	native
	placeable;

//-----------------------------------------------------------------------------
// Zone properties.

var skyzoneinfo SkyZone; // Optional sky zone containing this zone's sky.
var() name ZoneTag;
var() localized String LocationName; 

//-----------------------------------------------------------------------------
// Zone flags.

var()		bool   bTerrainZone;		// There is terrain in this zone.
var()		bool   bDistanceFog;		// There is distance fog in this zone.
var()		bool   bClearToFogColor;	// Clear to fog color if distance fog is enabled.

var const array<TerrainInfo> Terrains;

//-----------------------------------------------------------------------------
// Zone light.
var            vector AmbientVector;
var(ZoneLight) byte AmbientBrightness, AmbientHue, AmbientSaturation;
#if IG_BUMPMAP	// rowan: control ambient ground ratio for this zone
var(ZoneLight) float AmbientXGroundRatio;
#endif

var(ZoneLight) color DistanceFogColor;
var(ZoneLight) float DistanceFogStart;
var(ZoneLight) float DistanceFogEnd;
var(ZoneLight) float DistanceFogBlendTime;

#if IG_FOG	// rowan: control fog type in zone
var(ZoneLight) enum EFogType
{
	FG_Linear,
	FG_Exponential,
} DistanceFogType;

var(ZoneLight) float DistanceFogExpBias;
var(ZoneLight) float DistanceFogClipBias;	// we can make objects clip out before or after they are fully fogged out

var() bool	bClipToDistanceFog;		// objects should be clipped based on the far distance fog distance
var() bool	bDisableFogScaling;		// disable fog scaling on minspec machines
#endif

var(ZoneLight) const texture EnvironmentMap;
var(ZoneLight) float TexUPanSpeed, TexVPanSpeed;

var(ZoneSound) editinline I3DL2Listener ZoneEffect;

#if IG_SHARED	 // explicitly specify which skyzone we are hooked to
var(ZoneLight) name SkyZoneTag;
#endif

//------------------------------------------------------------------------------

var(ZoneVisibility) bool bLonelyZone;								// This zone is the only one to see or never seen
var(ZoneVisibility) editinline array<ZoneInfo> ManualExcludes;		// No Idea.. just sounded cool

#if IG_EFFECTS
var() array<name> EffectsContexts;
#endif

//=============================================================================
// Iterator functions.

// Iterate through all actors in this zone.
native(308) final iterator function ZoneActors( class<actor> BaseClass, out actor Actor );

simulated function LinkToSkybox()
{
	local skyzoneinfo TempSkyZone;

	// SkyZone.
	foreach AllActors( class 'SkyZoneInfo', TempSkyZone, '' )
		SkyZone = TempSkyZone;
	if(Level.DetailMode == DM_Low)
	{
		foreach AllActors( class 'SkyZoneInfo', TempSkyZone, '' )
			if( !TempSkyZone.bHighDetail && !TempSkyZone.bSuperHighDetail )
				SkyZone = TempSkyZone;
	}
	else if(Level.DetailMode == DM_High)
	{
	foreach AllActors( class 'SkyZoneInfo', TempSkyZone, '' )
			if( !TempSkyZone.bSuperHighDetail )
				SkyZone = TempSkyZone;
	}
	else if(Level.DetailMode == DM_SuperHigh)
	{
		foreach AllActors( class 'SkyZoneInfo', TempSkyZone, '' )
			SkyZone = TempSkyZone;
	}
#if IG_SHARED	// rowan:
	if (SkyZoneTag != '')
	{
		foreach AllActors( class 'SkyZoneInfo', TempSkyZone, '' )
		{
			if (TempSkyZone.ZoneTag == SkyZoneTag)
				SkyZone = TempSkyZone;
		}
	}
#endif
}

//=============================================================================
// Engine notification functions.

simulated function PreBeginPlay()
{
	Super.PreBeginPlay();

	// call overridable function to link this ZoneInfo actor to a skybox
	LinkToSkybox();
}

// When an actor enters this zone.
#if IG_SHARED // Ryan:
event ActorEntered( actor Other )
{
	if (Pawn(Other) != None)
	{
		SLog(Other $ " entered zone " $ self);
		dispatchMessage(new class'MessageZoneEntered'(label, Other.label));

        Other.TriggerEffectEvent('InZone');
	}
}
#else
event ActorEntered( actor Other );
#endif // IG

// When an actor leaves this zone.
#if IG_SHARED // Ryan:
event ActorLeaving( actor Other )
{
	if (Pawn(Other) != None)
	{
		SLog(Other $ " leaving zone " $ self);
		dispatchMessage(new class'MessageZoneExited'(label, Other.label));

        Other.UnTriggerEffectEvent('InZone');
	}
}
#else
event ActorLeaving( actor Other );
#endif // IG

defaultproperties
{
     AmbientSaturation=255
     AmbientXGroundRatio=0.300000
     DistanceFogColor=(B=128,G=128,R=128)
     DistanceFogStart=3000.000000
     DistanceFogEnd=8000.000000
     DistanceFogExpBias=1.000000
     DistanceFogClipBias=1.000000
     TexUPanSpeed=1.000000
     TexVPanSpeed=1.000000
     bStatic=True
     bNoDelete=True
     Texture=Texture'Engine_res.S_ZoneInfo'
}
