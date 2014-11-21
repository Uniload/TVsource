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
	timeBetweenUnderAttackMessages = 8
	timeBetweenOfflineMessages	   = 2
	timeBetweenOnlineMessages	   = 2

	announcements(0)=(effectEvent=BaseDeviceUnderAttack,speechTag=DYN_QKC_QCALERTS_01,debugString="%1 base device is under attack.")
	announcements(1)=(effectEvent=BaseDeviceOffline,speechTag=DYN_QKC_QCAUTO_09,debugString="%1 base device offline.")
	announcements(2)=(effectEvent=BaseDeviceOnline,speechTag=DYN_QKC_QCAUTO_03,debugString="%1 base device online.")
}