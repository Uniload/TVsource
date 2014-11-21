class HUDDamageIndicator extends HUDElement;

import enum EDirectionType from ClientSideCharacter;

var() config HUDMaterial TopMaterial;
var() config HUDMaterial BottomMaterial;
var() config HUDMaterial LeftMaterial;
var() config HUDMaterial RightMaterial;
var() config float DamageMax;
var() config float DamageMin;
var() config float FadeDurationMax;

function InitElement()
{
	TopMaterial.fadeProgress = 1.0;
	BottomMaterial.fadeProgress = 1.0;
	LeftMaterial.fadeProgress = 1.0;
	RightMaterial.fadeProgress = 1.0;
}

function UpdateData(ClientSideCharacter c)
{
	super.UpdateData(c);

	UpdateDamageMaterial(TopMaterial, c, DAMAGE_Front);
	UpdateDamageMaterial(BottomMaterial, c, DAMAGE_Rear);
	UpdateDamageMaterial(LeftMaterial, c, DAMAGE_Left);
	UpdateDamageMaterial(RightMaterial, c, DAMAGE_Right);
}

function UpdateDamageMaterial(out HUDMaterial material, out ClientSideCharacter c, EDirectionType type)
{
	local float damagePercent;

	if(c.DamageAmounts[type] <= 0)
		return;

	damagePercent = FClamp((c.DamageAmounts[type] + DamageMin) / DamageMax, 0.0, 1.0);

	if((1.0 - damagePercent) <= material.fadeProgress)
	{
		material.fadeProgress = (1.0 - damagePercent);
		material.fadeDuration = damagePercent * FadeDurationMax;
		material.fadeStartTime = TimeSeconds;
	}

	c.DamageAmounts[type] = 0;
}

function RenderElement(Canvas c)
{
	super.RenderElement(c);

	// render all the materials, all the time. Their 
	// visibility will be determined by the fade out
	c.SetPos(0, 0);
	if(TopMaterial.fadeProgress < 1.0)
		RenderHUDMaterial(c, TopMaterial, screenWidth, TopMaterial.Material.GetVSize());
	if(LeftMaterial.fadeProgress < 1.0)
		RenderHUDMaterial(c, LeftMaterial, LeftMaterial.Material.GetUSize(), screenHeight);
	if(BottomMaterial.fadeProgress < 1.0)
	{
		c.SetPos(0, screenHeight - BottomMaterial.Material.GetVSize());
		RenderHUDMaterial(c, BottomMaterial, screenWidth, BottomMaterial.Material.GetVSize());
	}
	if(RightMaterial.fadeProgress < 1.0)
	{
		c.SetPos(screenWidth - RightMaterial.Material.GetUSize(), 0);
		RenderHUDMaterial(c, RightMaterial, RightMaterial.Material.GetUSize(), screenHeight);
	}
}

defaultproperties
{
	bRelativePositioning=true

	FadeDurationMax=1.5
	DamageMax=100
	DamageMin=10

	TopMaterial=(Material=Texture'HUD.HitBoarderTop',DrawColor=(R=255,G=0,B=0,A=255),style=1,bFading=true,FadeDuration=1.7,FadeSourceColor=(R=255,G=0,B=0,A=255),FadeTargetColor=(R=255,G=0,B=0,A=1))
	BottomMaterial=(Material=Texture'HUD.HitBoarderBottom',DrawColor=(R=255,G=0,B=0,A=255),style=1,bFading=true,FadeDuration=1.7,FadeSourceColor=(R=255,G=0,B=0,A=255),FadeTargetColor=(R=255,G=0,B=0,A=1))
	LeftMaterial=(Material=Texture'HUD.HitBoarderLeft',DrawColor=(R=255,G=0,B=0,A=255),style=1,bFading=true,FadeDuration=1.7,FadeSourceColor=(R=255,G=0,B=0,A=255),FadeTargetColor=(R=255,G=0,B=0,A=1))
	RightMaterial=(Material=Texture'HUD.HitBoarderRight',DrawColor=(R=255,G=0,B=0,A=255),style=1,bFading=true,FadeDuration=1.7,FadeSourceColor=(R=255,G=0,B=0,A=255),FadeTargetColor=(R=255,G=0,B=0,A=1))
}