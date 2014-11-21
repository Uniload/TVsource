/*******************************************************************************
 * myReplicationAccess 0.2 by Cactusbone
 * 25 november 2004
 *
 * This gives access to TribesGameReplicationInfo and TribesReplicationInfo
 * after the first Client tick Ingame
 ******************************************************************************/
class myReplicationAccess extends TribesGUI.HUDElement;

var private bool bDone;

var bool bActorsReady;
var TribesGameReplicationInfo TGRI;
var array<TribesReplicationInfo> TRIs;
var PlayerController PC; //dunno if this is always relevant ...

function InitElement()
{
    if(FindObject("ext_myReplicationAccess", class'HUDstuff.myReplicationAccess')!=none)
    {
        bDone=false;
        log("myReplicationAccess 0.2 - Initialized",'myReplicationAccess');
    }
}

function UpdateData(ClientSideCharacter c)
{
    if(!bDone)
        bVisible=true;
}

function RenderElement(Canvas c)
{
    local TribesReplicationInfo TRI;
    local Pawn p;

    if(!bDone)
    {
        PC = c.Viewport.Actor;
        if(PC!=none)
        {
            foreach PC.DynamicActors( class 'TribesReplicationInfo', TRI )
            {
                TRIs[TRIs.Length]=TRI;
            }

            foreach PC.DynamicActors( class 'TribesGameReplicationInfo', TGRI )
            {
                if (!TGRI.bDeleteMe)
				    break;
            }

            //TGRI = TribesGameReplicationInfo(PC.findByLabel(class 'TribesGameReplicationInfo', 'TribesGameReplicationInfo0'));
            if(TGRI!=none)
            {
                bActorsReady=true;
                log("myReplicationAccess 0.1 - Actors are now available",'myReplicationAccess');
                bDone=true;
                bVisible=false;
            }
        }
    }
}

//Removes the corrupt file error
event NotifyLevelChange()
{
    class'staticFunctions'.static.removeElement(self.ParentElement, self);
}

defaultproperties
{
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
