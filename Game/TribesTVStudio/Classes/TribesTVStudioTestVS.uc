//-----------------------------------------------------------
//
//-----------------------------------------------------------
class TribesTVStudioTesTribesTVStudio extends TribesTVStudioViewSelector;

var string lasttarget;

function PostBeginPlay()
{
	super.postbeginplay ();

    SetTimer (5, true);
}

function Timer ()
{
    local string players[32];
    local int num;
    local PlayerReplicationInfo pri;
    local string tmp;

    foreach Allactors (class'PlayerReplicationInfo', pri) {
        if (!pri.bIsSpectator)
            players[num++] = pri.playername;
    }

    if (num == 0)
        return;

    tmp = players[rand(num)];
    //log ("TribesTVStudio: trying to view from " $ tmp);

    if (lasttarget != tmp) {
        SetCamTarget (tmp, 0.1);
        if (lasttarget != "")
            SetCamTarget (lasttarget, 0);
        lasttarget = tmp;
        UpdateCamTarget ();
    }
}

defaultproperties
{
    description="Change target every 5 secs"
    icon=texture'tviVC5sec'
}
