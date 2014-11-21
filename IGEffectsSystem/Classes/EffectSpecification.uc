class EffectSpecification extends Core.Object
    native
    abstract;

var config bool AttachToSource;     //should effect attach to object on which it was played
var config name AttachmentBone;            //don't set (ie. leave None) to use owner as base
var config vector LocationOffset;          //default.  may be overridden by TriggerEffectEvent() parameters
var config rotator RotationOffset;         //default.  may be overridden by TriggerEffectEvent() parameters

simulated function Init(EffectsSubsystem EffectsSubsystem);

defaultproperties
{
}
