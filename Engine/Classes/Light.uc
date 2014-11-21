//=============================================================================
// The light class.
//=============================================================================
class Light extends Actor
	placeable
	hidecategories(Karma, Force, Collision, Object, Sound)
	native;

var (Corona)	float	MinCoronaSize;
var (Corona)	float	MaxCoronaSize;
var (Corona)	float	CoronaRotation;
var (Corona)	float	CoronaRotationOffset;
var (Corona)	bool	UseOwnFinalBlend;

defaultproperties
{
     MaxCoronaSize=1000.000000
     LightType=LT_Steady
     LightBrightness=64.000000
     LightRadius=64.000000
     LightSaturation=255
     LightPeriod=32
     LightCone=128
     bStatic=True
     bHidden=True
     bNoDelete=True
     Texture=Texture'Engine_res.S_Light'
     bMovable=False
     CollisionRadius=24.000000
     CollisionHeight=24.000000
}
