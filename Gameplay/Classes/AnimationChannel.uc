class AnimationChannel extends Core.DeleteableObject native;
	
enum AnimationChannelIndex
{
	AnimationChannel_Primary,
	AnimationChannel_Primary_Forward,
	AnimationChannel_Primary_Back,
	AnimationChannel_Primary_Left,
	AnimationChannel_Primary_Right,
	AnimationChannel_Primary_Up,
	AnimationChannel_Primary_Down,

	AnimationChannel_Secondary,
	AnimationChannel_Secondary_Forward,
	AnimationChannel_Secondary_Back,
	AnimationChannel_Secondary_Left,
	AnimationChannel_Secondary_Right,
	AnimationChannel_Secondary_Up,
	AnimationChannel_Secondary_Down,

	AnimationChannel_Primary_AimUp,
	AnimationChannel_Primary_AimDown,
	AnimationChannel_Secondary_AimUp,
	AnimationChannel_Secondary_AimDown,
	AnimationChannel_Arm,
	AnimationChannel_Fire,

	AnimationChannel_UpperBody,
    AnimationChannel_Flinch,
	AnimationChannel_Extra,
	
	AnimationChannel_Count
};

var String sequence;
var String processed;
var float alpha;

defaultproperties
{
}
