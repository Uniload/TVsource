class ModeCTF extends GameClasses.ModeCTF config(Mapmsg);

defaultproperties
{
     allowedMPActorList(0)=Class'GameClasses.CaptureFlag'
     allowedMPActorList(1)=Class'GameClasses.CaptureStand'
     allowedMPActorList(2)=Class'GameClasses.territory'
     baseDeviceObjectives(0)=Class'BaseObjectClasses.BasePowerGenerator'
     baseDeviceObjectives(1)=Class'BaseObjectClasses.BaseSensor'
     suicideStat=Class'StatClasses.suicideStatCTF'
     killStat=Class'StatClasses.killStatCTF'
     projectileDamageStats(0)=(damageTypeClass=Class'EquipmentClasses.ProjectileDamageTypeSniperRifle',playerDamageStatClass=Class'StatClasses.StatDamageSniperRifle',headShotStatClass=Class'StatClasses.StatHeadShot')
     projectileDamageStats(1)=(damageTypeClass=Class'EquipmentClasses.ProjectileDamageTypeBlaster',playerDamageStatClass=Class'StatClasses.StatDamageBlaster')
     projectileDamageStats(2)=(damageTypeClass=Class'EquipmentClasses.ProjectileDamageTypeBuckler',playerDamageStatClass=Class'StatClasses.StatDamageBuckler')
     projectileDamageStats(3)=(damageTypeClass=Class'EquipmentClasses.ProjectileDamageTypeBurner',playerDamageStatClass=Class'StatClasses.StatDamageBurner')
     projectileDamageStats(4)=(damageTypeClass=Class'EquipmentClasses.ProjectileDamageTypeChaingun',playerDamageStatClass=Class'StatClasses.StatDamageChaingun')
     projectileDamageStats(5)=(damageTypeClass=Class'EquipmentClasses.ProjectileDamageTypeGrenadeLauncher',playerDamageStatClass=Class'StatClasses.StatDamageGrenadeLauncher')
     projectileDamageStats(6)=(damageTypeClass=Class'EquipmentClasses.ProjectileDamageTypeMortar',playerDamageStatClass=Class'StatClasses.StatDamageMortar')
     projectileDamageStats(7)=(damageTypeClass=Class'EquipmentClasses.ProjectileDamageTypeRocketPod',playerDamageStatClass=Class'StatClasses.StatDamageRocketPod')
     projectileDamageStats(8)=(damageTypeClass=Class'EquipmentClasses.ProjectileDamageTypeSpinfusor',playerDamageStatClass=Class'StatClasses.StatDamageSpinfusor')
     extendedProjectileDamageStats(0)=(damageTypeClass=Class'EquipmentClasses.ProjectileDamageTypeSpinfusor',extendedStatClass=Class'StatClasses.ExtendedStatMidairDisc')
     extendedProjectileDamageStats(1)=(damageTypeClass=Class'EquipmentClasses.ProjectileDamageTypeExplosion',extendedStatClass=Class'StatClasses.ExtendedStatFastExplosive')
     baseDeviceDestroyStats(0)=(statClass=Class'StatClasses.StatDestroyGenerator',baseDeviceClass=Class'BaseObjectClasses.BasePowerGenerator')
     baseDeviceDestroyStats(1)=(statClass=Class'StatClasses.StatDestroySensor',baseDeviceClass=Class'BaseObjectClasses.BaseSensor')
     baseDeviceRepairStats(0)=(statClass=Class'StatClasses.StatRepairGenerator',baseDeviceClass=Class'BaseObjectClasses.BasePowerGenerator')
     baseDeviceRepairStats(1)=(statClass=Class'StatClasses.StatRepairSensor',baseDeviceClass=Class'BaseObjectClasses.BaseSensor')
     baseDeviceRepairStats(2)=(statClass=Class'StatClasses.StatRepairInventory',baseDeviceClass=Class'BaseObjectClasses.BaseInventoryStation')
     //roundInfoClass=Class'ModeCTFRoundInfo'
     MapListType="MapMsg.MapList"
     gameHints(0)="DON'T BE A LITTLE DICK EATING FAGGOT!"
     gameHints(1)="Visit www.tribestvdl.com for T:V downloads!"
     GameName="Capture the Flag"
     GameDescription="Retrieve the enemy team's flag and bring it back to your team's flag stand.  Your flag must be at its stand in order to capture their flag."
     Acronym="CTF"
}
