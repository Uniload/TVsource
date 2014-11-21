/*******************************************************************************
 * myHUDIcon 0.1 by Cactusbone
 * 12 november 2004
 *
 * This simply draws a scaled textures on the HUD, you can't specify
 * which part of the texture to use yet
 ******************************************************************************/
class myHUDIcon extends TribesGUI.HUDElement;

var config Material IconMaterial;
var config color DrawColor;

function RenderElement(Canvas c)
{
    local float scaleX, scaleY;
	super.RenderElement(c);

    c.SetPos(c.OrgX, c.OrgY);

    c.DrawColor=DrawColor;

    scaleX=Width/IconMaterial.GetUSize();
    scaleY=Height/IconMaterial.GetVSize();
    c.DrawTileScaled(IconMaterial,scaleX,scaleY);
}

//Removes the corrupt file error
event NotifyLevelChange()
{
    local staticFunctions sF;
    sF.removeElement(self.ParentElement, self);
}

defaultproperties
{
     IconMaterial=Texture'GUITribes.InvButtonSuicide'
     DrawColor=(B=255,G=255,R=255,A=255)
     resFontNames(0)="DefaultSmallFont"
     resFontNames(1)="Tahoma8"
     resFontNames(2)="Tahoma8"
     resFontNames(3)="Tahoma10"
     resFontNames(4)="Tahoma12"
     resFontNames(5)="Tahoma12"
     resFonts(0)=Font'Engine_res.Res_DefaultFont'
     resFonts(1)=Font'TribesFonts.Tahoma8'
     resFonts(2)=Font'TribesFonts.Tahoma8'
     resFonts(3)=Font'TribesFonts.Tahoma10'
     resFonts(4)=Font'TribesFonts.Tahoma12'
     resFonts(5)=Font'TribesFonts.Tahoma12'
}
