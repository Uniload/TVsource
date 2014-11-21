class AnimationManager extends Core.DeleteableObject 
    dependsOn(Rook)
    dependsOn(Character)
    native;
	
import enum AlertnessLevels from Rook;
import enum AnimationStateEnum from Character;
	
var bool firstUpdate;
var bool animationEnabled;

var AnimationStateEnum currentAnimationState;
var AnimationStateEnum desiredAnimationState;
var AnimationStateEnum adjustedAnimationState;

var float currentAnimationStateTime;
var float desiredAnimationStateTime;
var float adjustedAnimationStateTime;

var AnimationStateEnum primaryAnimationLayerState;
var AlertnessLevels	primaryAnimationLayerAlertness;

var AnimationStateEnum secondaryAnimationLayerState;
var AlertnessLevels	secondaryAnimationLayerAlertness;

var AlertnessLevels	currentAlertnessLevel;
var AlertnessLevels adjustedAlertnessLevel;
var AlertnessLevels animationAlertnessLevel;

var bool currentAiming;
var bool previousAiming;

var bool fireAnimationActive;
var bool extraAnimationActive;
var bool upperBodyAnimationActive;
var bool armAnimationActive;
var bool flinchAnimationActive;

var bool extraAnimationPending;
var bool extraAnimationPendingIsLoop;
var float extraAnimationPendingTime;
var String extraAnimationPendingName;

var Character characterOwner;

var Mesh previousMesh;

native function StopAnimating(Character character);
native function StartAnimating(Character character);

native function playAnimation(String animation);
native function loopAnimation(String animation);
native function bool isPlayingAnimation();
native function bool isLoopingAnimation();
native function stopAnimation();

native function playFireAnimation(String weapon);

native function playUpperBodyAnimation(String animation);
native function loopUpperBodyAnimation(String animation);
native function bool isPlayingUpperBodyAnimation();
native function bool isLoopingUpperBodyAnimation();
native function stopUpperBodyAnimation();

native function loopArmAnimation(String animation);
native function bool isLoopingArmAnimation();
native function string getArmAnimation();
native function stopArmAnimation();

native function playFlinchAnimation();


defaultproperties
{
    firstUpdate = true
	animationEnabled = true
    currentAnimationState = AnimationState_None
    desiredAnimationState = AnimationState_None
    adjustedAnimationState = AnimationState_None
    primaryAnimationLayerState = AnimationState_None    
    primaryAnimationLayerAlertness = Alertness_Combat
    secondaryAnimationLayerState = AnimationState_None    
    secondaryAnimationLayerAlertness = Alertness_Combat
    currentAlertnessLevel = ALERTNESS_Combat
    adjustedAlertnessLevel = ALERTNESS_Combat
}