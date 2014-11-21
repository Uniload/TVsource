//=============================================================================
// Player start location.
//=============================================================================
class PlayerStart extends Info
	native
#if IG_TRIBES3 // david: we use our own derived PlayerStart, this stops designer confusion
;
#else
	placeable;
#endif
	

// Players on different teams are not spawned in areas with the
// same TeamNumber unless there are more teams in the level than
// team numbers.
var() byte TeamNumber;			// what team can spawn at this start
var() bool bSinglePlayer;	// use first start encountered with this true for single player
var() bool bCoop;			// start can be used in coop games	
var() bool bEnabled; 
var() bool bPrimary;		// None primary starts used only if no primary start available
var() float LastSpawnCampTime;	// last time a pawn starting from this spot died within 5 seconds

defaultproperties
{
     bSinglePlayer=True
     bCoop=True
     bEnabled=True
     bPrimary=True
     Texture=Texture'Engine_res.S_Player'
     bDirectional=True
}
