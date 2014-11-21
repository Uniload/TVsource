class MPBaseDeviceMessages extends TribesLocalMessage;


var() localized string	friendlyUnderAttack;
var() localized string	friendlyInactive;
var() localized string  friendlyActive;
var() localized string	enemyUnderAttack;
var() localized string	enemyInactive;
var() localized string  enemyActive;
var(EffectEvents) name				globalFriendlyUnderAttackEffectEvent;
var(EffectEvents) name				globalFriendlyInactiveEffectEvent;
var(EffectEvents) name				globalFriendlyActiveEffectEvent;
var(EffectEvents) name				globalEnemyInactiveEffectEvent;
var(EffectEvents) name				globalEnemyActiveEffectEvent;
var(EffectEvents) name				globalEnemyUnderAttackEffectEvent;
var() float				timeBetweenUnderAttackMessages;
var() float				timeBetweenOfflineMessages;
var() float				timeBetweenOnlineMessages;

defaultproperties
{
     timeBetweenUnderAttackMessages=8.000000
     timeBetweenOfflineMessages=2.000000
     timeBetweenOnlineMessages=2.000000
     Announcements(0)=(EffectEvent="BaseDeviceUnderAttack",SpeechTag="DYN_QKC_QCALERTS_01",DebugString="%1 base device is under attack.")
     Announcements(1)=(EffectEvent="BaseDeviceOffline",SpeechTag="DYN_QKC_QCAUTO_09",DebugString="%1 base device offline.")
     Announcements(2)=(EffectEvent="BaseDeviceOnline",SpeechTag="DYN_QKC_QCAUTO_03",DebugString="%1 base device online.")
}
