class x2FlagThrowerImperial extends GameClasses.FlagThrowerImperial;



/* function ModifyFlagThrowerImp()
{
        local GameClasses.FlagThrowerImperial ImpFlagthrower;
        forEach AllActors(class'GameClasses.FlagThrowerImperial', ImpFlagThrower)
                if (ImpFlagThrower != None)
                {
                ImpFlagThrower.chargeScale = FlagChargeScale; //was .3
		ImpFlagThrower.maxcharge = FlagMaxCharge; // was 1.6
	        ImpFlagThrower.peakChargeMaxHoldTime = FlagPeakMaxHoldTime; //was 2
                ImpFlagThrower.projectileInheritedVelFactor = FlagInheritedVelocity;//was .8
                ImpFlagThrower.projectileVelocity = FlagVelocity;//was 800
	        ImpFlagThrower.releaseDelay = FlagReleaseDelay;//was .1
                ImpFlagThrower.chargeRate *= FlagChargeRate; //was 1
                }
} */


defaultproperties
{
     ammoCount=1
     ammoUsage=1
     animClass=Class'CharacterEquippableAnimator'
     animPrefix="flag"
     attentionFXDuration=0.5000000
     attentionFXMaterial=Texture'BaseObjects.ResupplyStationLum'
     attentionFXSpacing=3.000000
     automaticallyHold=False
     bCanDrop=False
     bFirstPersonUseTrace=True
     bMelee=False
     bNeedIdleFX=False
     bOnlyAffectCurrentZone=False
     bShowChargeOnHUD=True
     chargeAnimation=charge
     chargeRateAccel=0.000000
     chargeScale=0.450000
     droppedElasticity=1500
     emptyMaterials=None
     equipDuration=0.000000
     equippedArmAnim="weapon_flag_hold"
     extraSpawnDistance=100.000000
     fireAnimSubString="flag"
     firstPersonAltMesh=SkeletalMesh'weapons.HeavyFlag'
     firstPersonAltOffset=(X=-22.000000,Y=23.000000,Z=-20.000000)
     firstPersonAltTraceExtent=(X=1.000000,Y=10.000000,Z=1.000000)
     firstPersonAltTraceLength=100
     firstPersonBobMultiplier=0.150000
     firstPersonMesh=SkeletalMesh'weapons.Flag'
     firstPersonOffset=(X=-15.000000,Y=25.000000,Z=-25.000000)
     firstPersonTraceExtent=(X=1.000000,Y=10.000000,Z=1.000000)
     firstPersonTraceLength=100
     hudIcon=Texture'HUD.MPTabs'
     hudIconCoords=(U=102.000000,V=248.000000,UL=80.000000,VL=40.000000)
     hudRefireIcon=Texture'HUD.MPTabs'
     hudRefireIconCoords=(U=102.000000,V=248.000000,UL=80.000000,VL=40.000000)
     hudReticule=Texture'HUD.reticuleDirect'
     hudReticuleCenterX=64.000000
     hudReticuleCenterY=64.000000
     hudReticuleHeight=128
     hudReticuleWidth=128
     initialChargeRate=1.000000
     inventoryIcon=Texture'Engine_res.DefaultTexture'
     Label=None
     localizedName=""
     maxCharge=0.800000
     peakChargeMaxHoldTime=30
     pickupRadius=50
     projectileClass=None
     projectileInheritedVelFactor=0.600000
     projectileSpawnBone=muzzle
     projectileVelocity=1400.000000
     Prompt="Press '%1' to swap your %2 for a %3."
     releaseAnimation="throw"
     releaseDelay=0.0500000
     roundsPerSecond=1.000000
     Skins(1)=Shader'MPGameObjects.FLagImperialShader'
     thirdPersonAltMesh=SkeletalMesh'MPGameObjects.FlagHeld'
     thirdPersonAltStaticMesh=None
     thirdPersonAttachmentBone=Weapon
     thirdPersonAttachmentOffset=(X=17.000000,Y=-2.000000,Z=100.000000)
     thirdPersonMesh=SkeletalMesh'MPGameObjects.FlagHeld'
     thirdPersonStaticMesh=None
     unequipDuration=0.000000
}