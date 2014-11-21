//-----------------------------------------------------------
// ViewSelector that tries to watch flagruns
// Adds priority to the flagcarrier
// if a flag is dropped, watches it
//-----------------------------------------------------------
class TribesTVStudioFlagVS extends TribesTVStudioViewSelector;

enum FlagState
{
    FSHome,
    FSHeld,
    FSDropped
};

struct FlagInfo {
    var CTFFlag flag;
    var FlagState cur;
    var string holder;
    var string flagname;
};

var FlagInfo flags[2];

function PostBeginPlay()
{
	super.postbeginplay ();
    //Seems flags are not available here
    //log ("TribesTVStudio: flagvs postbegin");
}

function bool runnable ()
{
	return (level.game.isa ('xCTFGame'));
}

function FindFlags ()
{
    local CTFFlag f;
    local int i;

    i = 0;
    foreach AllActors (class'CTFFlag', f) {
        flags[i].flag = f;
        flags[i].cur = FSHome;

        if (f.isa('xRedFlag'))
            flags[i].flagname = "Red Flag";
        else
            flags[i].flagname = "Blue Flag";

        i++;
    }
}

function Tick (float deltatime)
{
    local int i;
    local CTFFlag cf;
    local FlagState ns;

    if (flags[0].flag == none) {
        FindFlags ();
    }

    for (i = 0; i < 2; ++i) {
        cf = flags[i].flag;

        //Find its current state
        if (cf.bHeld)
            ns = FSHeld;
        else if (cf.bHome)
            ns = FSHome;
        else
            ns = FSDropped;

        if (flags[i].cur != ns) {

            //Act depending on new state
            switch (ns) {
                case FSHeld:
                    flags[i].holder = cf.holder.playerreplicationinfo.playername;
                    SetCamTarget (flags[i].holder, 0.5);
                    break;
                case FSHome:
                    break;
                case FSDropped:
                    SetCamTarget (flags[i].flagname, 0.7);
                    break;
            }

            //and remove effects of last state
            switch (flags[i].cur) {
                case FSHeld:
                    SetCamTarget (flags[i].holder, 0);
                    break;
                case FSHome:
                    break;
                case FSDropped:
                    SetCamTarget (flags[i].flagname, 0);
                    break;
            }

            flags[i].cur = ns;
            UpdateCamTarget ();
        }
    }

}

defaultproperties
{
    description="Follow flagruns"
    icon=texture'tviVCFlag'
}
