/*******************************************************************************
 * myHUDValueBar 0.2 by Cactusbone
 * 20 november 2004
 *
 * This is a BAR, it display a partial fullTexture over an emptyTexture,
 * depending on the value/maximulValue ratio
 *
 * NB : bReverse and barStart/EndOffset might be coded reversed ...
 ******************************************************************************/
class myHUDValueBar extends TribesGUI.HUDElement
                    dependsOn(OHUDMaterial);

var config HUDMaterial emptyTexture;        //Default Texture for the empty bar
var config HUDMaterial fullTexture;         //Default Texture for the full bar

var OHUDMaterial emptyTextureObject;        //Using objects because struct only passes by value :/
var OHUDMaterial fullTextureObject;

var OHUDMaterial activeEmptyTexture;        //Texture for the empty bar
var OHUDMaterial activeFullTexture;	        //Texture for the full bar

var config float value;                     //Current value of the bar
var config float maximumValue;              //Max value for the bar

var config float barStartOffset;            //offset (in texture co-ords) of the start of the bar region
var config float barEndOffset;              //offset (in texture co-ords) of the end of the bar region
// those offset DEPENDS on bVertical and bReverse and only apply to the fullTexture

var config float pixelRatio;                //resize ratio

var config bool bReverse;			        //whether to reverse the direction of the value
var config bool bVertical;                  //whether to fill it vertically or horizontally

var bool bLayoutDone;
var float fullWidth;                        //width of the clipped fullTexture to apply ratio to
var float fullHeight;                       //height of the clipped fullTexture to apply ratio to
var float clipableLen;                      //lenght of the Clippable part in FullTexture
var float ratio;                            //ratio current/total
var float fullStartU;                       //where to start in the full texture
var float fullStartV;                       //where to start in the full texture
var float offsetU;                          //offset from empty texture starting
var float offsetV;                          //offset from empty texture starting

function UpdateData(ClientSideCharacter c)
{
    ratio=value/maximumValue;
}

function RenderElement(Canvas c)
{
	super.RenderElement(c);
if(bVisible)
{
	if(!bLayoutDone)
    {
        emptyTextureObject = new class'OHUDMaterial'(emptyTexture);
        fullTextureObject = new class'OHUDMaterial'(fullTexture);
        activeEmptyTexture = emptyTextureObject;
        activeFullTexture = fullTextureObject;

        fullWidth=activeFullTexture.coords.UL;
        fullHeight=activeFullTexture.coords.VL;

        if(bReverse && barStartOffset==0)
        {
            if(bVertical)
                barStartOffset = fullHeight;
            else
                barStartOffset = fullWidth;
        }

        if(!bReverse && barEndOffset==0)
        {
            if(bVertical)
                barEndOffset = fullHeight;
            else
                barEndOffset = fullWidth;
        }

        if((!bReverse && barEndOffset<barStartOffset)|| (bReverse && barEndOffset>barStartOffset))
        {//simple swap
            clipableLen = barStartOffset;
            barStartOffset = barEndOffset;
            barEndOffset = clipableLen;
        }

        if(bReverse)
            clipableLen = barStartOffset-barEndOffset;
        else
            clipableLen = barEndOffset-barStartOffset;

        bLayoutDone=true;
    }

    //need to be done every time because positions are "reseted" when the player die
    class'staticFunctions'.static.calculateHUDElementStartingPosition(self, true);

    //empty Texture
    c.SetOrigin(self.posX,self.posY);

    c.DrawColor=activeEmptyTexture.DrawColor;
    c.Style=activeEmptyTexture.style;
    if(activeEmptyTexture.bFlashing && (timeSeconds - activeEmptyTexture.lastFlashTime)> activeEmptyTexture.flashFrequency)
    {
        activeEmptyTexture.lastFlashTime=timeSeconds;
        c.DrawColor=activeEmptyTexture.getFlashingColor();
    }
    /*
    bFading
	bFadePulse
	fadeSourceColor
	fadeTargetColor
	fadeDuration

    fadeStartTime
	fadeProgress
    */

    c.DrawTile(activeEmptyTexture.Material, activeEmptyTexture.coords.UL*pixelRatio, activeEmptyTexture.coords.VL*pixelRatio, activeEmptyTexture.coords.U,activeEmptyTexture.coords.V,activeEmptyTexture.coords.UL,activeEmptyTexture.coords.VL);

    //full texture
    if(bVertical)
        fullHeight = clipableLen*ratio;
    else
        fullWidth = clipableLen*ratio;

    fullStartU=activeFullTexture.coords.U;
    fullStartV=activeFullTexture.coords.V;

    if(bReverse)
    {
        if(bVertical)
        {
            offsetU = activeFullTexture.coords.UL - fullWidth ;
            offsetV = activeFullTexture.coords.VL - fullHeight - barEndOffset;
        }
        else
        {
            offsetU = activeFullTexture.coords.UL - fullWidth - barEndOffset;
            offsetV = activeFullTexture.coords.VL - fullHeight;
        }
    }
    else
    {//not bReverse
        if(bVertical)
        {
            offsetU = 0;
            offsetV = barStartOffset;
        }
        else
        {
            offsetU = barStartOffset;
            offsetV = 0;
        }
    }

    fullStartU += offsetU;
    fullStartV += offsetV;
    offsetU *= pixelRatio;
    offsetV *= pixelRatio;

    c.SetOrigin(self.posX,self.posY);
    c.DrawColor=activeFullTexture.DrawColor;
    c.Style=activeFullTexture.style;

    if(activeFullTexture.bFlashing)
    {
        if((timeSeconds - activeFullTexture.lastFlashTime)>activeFullTexture.flashFrequency)
        {
            activeFullTexture.lastFlashTime=timeSeconds;
            activeFullTexture.nbFlashed=0;
        }
        if(activeFullTexture.nbFlashed<3)
        {
            c.DrawColor=activeFullTexture.getFlashingColor();
            activeFullTexture.nbFlashed++;
        }
    }
    /*
    bFading
	bFadePulse
	fadeSourceColor
	fadeTargetColor
	fadeDuration

    fadeStartTime
	fadeProgress
    */

    //central part
    c.SetPos(offsetU, offsetV);
    c.DrawTile(activeFullTexture.Material, fullWidth*pixelRatio, fullHeight*pixelRatio, fullStartU, fullStartV, fullWidth, fullHeight);

    //left or top part
    c.SetPos(0, 0);
    if(bReverse)
    {
        if(bVertical)
        {
            c.DrawTile(activeFullTexture.Material, fullWidth*pixelRatio, (activeFullTexture.coords.VL - barStartOffset)*pixelRatio, activeFullTexture.coords.U, activeFullTexture.coords.V, fullWidth, activeFullTexture.coords.VL - barStartOffset);
        }
        else
        {
            c.DrawTile(activeFullTexture.Material, (activeFullTexture.coords.UL - barStartOffset)*pixelRatio, fullHeight*pixelRatio, activeFullTexture.coords.U, activeFullTexture.coords.V, activeFullTexture.coords.UL - barStartOffset, fullHeight);
        }
    }
    else
    {
        if(bVertical)
        {
            c.DrawTile(activeFullTexture.Material, fullWidth*pixelRatio, barStartOffset*pixelRatio, activeFullTexture.coords.U, activeFullTexture.coords.V, fullWidth, barStartOffset);
        }
        else
        {
            c.DrawTile(activeFullTexture.Material, barStartOffset*pixelRatio, fullHeight*pixelRatio, activeFullTexture.coords.U, activeFullTexture.coords.V, barStartOffset, fullHeight);
        }
    }
    //right or bottom part
    if(bReverse)
    {
        if(bVertical)
        {
            c.SetPos(0, (activeFullTexture.coords.VL - barStartOffset + clipableLen)*pixelRatio);
            c.DrawTile(activeFullTexture.Material, fullWidth*pixelRatio, barEndOffset*pixelRatio, activeFullTexture.coords.U, activeFullTexture.coords.V + activeFullTexture.coords.VL - barStartOffset + clipableLen, fullWidth, barEndOffset);
        }
        else
        {
            c.SetPos((activeFullTexture.coords.UL - barStartOffset + clipableLen)*pixelRatio, 0);
            c.DrawTile(activeFullTexture.Material, barEndOffset*pixelRatio, fullHeight*pixelRatio,  activeFullTexture.coords.U + activeFullTexture.coords.UL - barStartOffset + clipableLen, activeFullTexture.coords.V, barEndOffset, fullHeight);
        }
    }
    else
    {
        if(bVertical)
        {
            c.SetPos(0, barEndOffset*pixelRatio);
            c.DrawTile(activeFullTexture.Material, fullWidth*pixelRatio, (activeFullTexture.coords.VL - barEndOffset)*pixelRatio, activeFullTexture.coords.U, activeFullTexture.coords.V + barEndOffset, fullWidth, activeFullTexture.coords.VL - barEndOffset);
        }
        else
        {
            c.SetPos(barEndOffset*pixelRatio, 0);
            c.DrawTile(activeFullTexture.Material, (activeFullTexture.coords.UL - barEndOffset)*pixelRatio, fullHeight*pixelRatio, activeFullTexture.coords.U + barEndOffset, activeFullTexture.coords.V, activeFullTexture.coords.UL - barEndOffset, fullHeight);
        }
    }
}
}

//Removes the corrupt file error
event NotifyLevelChange()
{
    activeEmptyTexture = none; //removing objects created here
    activeFullTexture = none;
    class'staticFunctions'.static.removeElement(self.ParentElement, self);
}

defaultproperties
{
     emptyTexture=(DrawColor=(B=255,G=255,R=255,A=64),Style=1)
     fullTexture=(DrawColor=(B=255,G=255,R=255,A=128),Style=1)
     Value=50.000000
     maximumValue=100.000000
     pixelRatio=1.000000
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
